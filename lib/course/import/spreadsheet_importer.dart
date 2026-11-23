import 'dart:convert';

import 'package:excel/excel.dart';

import 'grid_parser.dart';
import 'import_models.dart';

/// CSV：既支持“课程名/星期/节次/周次/地点/教师”标准列，也支持周几×节次的表格。
CourseImportResult parseCsv(
  List<int> bytes, {
  required int totalWeeks,
}) {
  String text;
  try {
    text = utf8.decode(bytes);
  } catch (_) {
    text = latin1.decode(bytes);
  }
  text = text.replaceFirst('\uFEFF', '');
  final rows = _parseCsvRows(text);
  final header = rows.isEmpty ? <String>[] : rows.first;
  final mapping = _headerMapping(header);
  if (mapping.name != null &&
      mapping.weekday != null &&
      mapping.start != null &&
      mapping.end != null) {
    return _parseTabularRows(rows, mapping, totalWeeks);
  }
  return parseTimetableGrid(rows, totalWeeks: totalWeeks);
}

/// XLSX：读取第一个工作表；支持标准列与表格型课表。
CourseImportResult parseXlsx(
  List<int> bytes, {
  required int totalWeeks,
}) {
  final excel = Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) {
    return const CourseImportResult(courses: <CourseDraft>[], warnings: <String>['Excel 里没有工作表']);
  }
  for (final entry in excel.tables.entries) {
    final table = entry.value;
    final rows = table.rows
        .map((row) => row
            .map((cell) => cell?.value?.toString().trim() ?? '')
            .toList(growable: false))
        .where((row) => row.any((cell) => cell.isNotEmpty))
        .toList(growable: false);
    if (rows.isEmpty) continue;
    final mapping = _headerMapping(rows.first);
    if (mapping.name != null &&
        mapping.weekday != null &&
        mapping.start != null &&
        mapping.end != null) {
      final result = _parseTabularRows(rows, mapping, totalWeeks);
      if (result.courses.isNotEmpty) {
        return CourseImportResult(
          courses: result.courses,
          warnings: <String>[...result.warnings, '工作表：${entry.key}'],
          formatLabel: 'Excel 标准列',
        );
      }
    }
    final result = parseTimetableGrid(rows, totalWeeks: totalWeeks);
    if (result.courses.isNotEmpty) {
      return CourseImportResult(
        courses: result.courses,
        warnings: <String>[...result.warnings, '工作表：${entry.key}'],
        formatLabel: 'Excel 表格',
      );
    }
  }
  return const CourseImportResult(
    courses: <CourseDraft>[],
    warnings: <String>['Excel 中没有识别到课程列或课表表格'],
  );
}

class _ColumnMapping {
  _ColumnMapping({
    this.name,
    this.weekday,
    this.start,
    this.end,
    this.weeks,
    this.teacher,
    this.location,
    this.note,
  });

  final int? name;
  final int? weekday;
  final int? start;
  final int? end;
  final int? weeks;
  final int? teacher;
  final int? location;
  final int? note;
}

_ColumnMapping _headerMapping(List<String> header) {
  int? find(List<String> keys) {
    for (var i = 0; i < header.length; i++) {
      final h = header[i].trim().toLowerCase().replaceAll(' ', '');
      for (final key in keys) {
        if (h == key || h.contains(key)) return i;
      }
    }
    return null;
  }

  return _ColumnMapping(
    name: find(const <String>['课程名称', '课程名', '课程', '科目', 'name', 'course']),
    weekday: find(const <String>['星期', '周几', 'weekday', 'day']),
    start: find(const <String>['开始节次', '起始节次', '开始节', 'start']),
    end: find(const <String>['结束节次', '结束节', 'end']),
    weeks: find(const <String>['上课周次', '周次', '周数', 'weeks']),
    teacher: find(const <String>['任课教师', '教师', '老师', 'teacher']),
    location: find(const <String>['上课地点', '地点', '教室', 'location']),
    note: find(const <String>['备注', 'note']),
  );
}

CourseImportResult _parseTabularRows(
  List<List<String>> rows,
  _ColumnMapping mapping,
  int totalWeeks,
) {
  final drafts = <CourseDraft>[];
  final warnings = <String>[];
  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    String cell(int? index) {
      if (index == null || index < 0 || index >= row.length) return '';
      return TimetableText.cleanLine(row[index]);
    }

    final name = cell(mapping.name);
    if (name.isEmpty) continue;
    final weekday = TimetableText.weekday(cell(mapping.weekday));
    final sections = TimetableText.sections(
      cell(mapping.start).isEmpty
          ? cell(mapping.end)
          : '${cell(mapping.start)}-${cell(mapping.end)}',
    );
    if (weekday == null || sections == null) {
      warnings.add('第 ${i + 1} 行缺少星期或节次，已跳过：$name');
      continue;
    }
    final rawWeeks = cell(mapping.weeks);
    final weeks = TimetableText.weeks(rawWeeks, totalWeeks: totalWeeks) ??
        List<int>.generate(totalWeeks, (index) => index + 1);
    drafts.add(CourseDraft(
      name: name,
      teacher: cell(mapping.teacher),
      location: cell(mapping.location),
      note: cell(mapping.note),
      weekday: weekday,
      startSection: sections.$1,
      endSection: sections.$2,
      weeks: weeks,
      colorIndex: colorForIndex(drafts.length),
    ));
  }
  if (drafts.isEmpty) {
    warnings.add('没有解析到有效课程行，请检查表头是否包含：课程名称、星期、开始节次、结束节次、周次');
  }
  return CourseImportResult(
    courses: drafts,
    warnings: warnings,
    formatLabel: '标准列课表',
  );
}

List<List<String>> _parseCsvRows(String input) {
  final rows = <List<String>>[];
  var row = <String>[];
  final buffer = StringBuffer();
  var inQuotes = false;

  void flushCell() {
    row.add(buffer.toString());
    buffer.clear();
  }

  void flushRow() {
    flushCell();
    rows.add(row);
    row = <String>[];
  }

  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    if (inQuotes) {
      if (char == '"') {
        if (i + 1 < input.length && input[i + 1] == '"') {
          buffer.write('"');
          i++;
        } else {
          inQuotes = false;
        }
      } else {
        buffer.write(char);
      }
      continue;
    }
    if (char == '"') {
      inQuotes = true;
    } else if (char == ',') {
      flushCell();
    } else if (char == '\n') {
      flushRow();
    } else if (char == '\r') {
      // ignore
    } else {
      buffer.write(char);
    }
  }
  if (buffer.isNotEmpty || row.isNotEmpty) flushRow();
  return rows;
}
