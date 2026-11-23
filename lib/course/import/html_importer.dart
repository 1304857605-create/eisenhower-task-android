import 'dart:convert';

import 'package:html/parser.dart' as html_parser;

import 'grid_parser.dart';
import 'import_models.dart';

/// 解析从教务系统“另存为网页”得到的 .html 课表。
CourseImportResult parseHtml(
  List<int> bytes, {
  required int totalWeeks,
}) {
  String text;
  try {
    text = utf8.decode(bytes);
  } catch (_) {
    text = latin1.decode(bytes);
  }
  final document = html_parser.parse(text);
  final tables = document.querySelectorAll('table');
  final candidates = <List<List<String>>>[];
  for (final table in tables) {
    final rows = <List<String>>[];
    for (final row in table.querySelectorAll('tr')) {
      final cells = <String>[];
      for (final cell in row.querySelectorAll('td,th')) {
        // 保留单元格内的换行，便于识别“课程/教师/地点/周次”多行内容。
        final withBreaks = cell.innerHtml.replaceAll(
          RegExp(r'<br\s*/?>', caseSensitive: false),
          '\n',
        );
        final cellText = html_parser.parseFragment(withBreaks).text ?? '';
        cells.add(TimetableText.cleanLine(cellText));
      }
      if (cells.isNotEmpty) rows.add(cells);
    }
    if (rows.isNotEmpty) candidates.add(rows);
  }
  candidates.sort((a, b) => _dayHeaderCount(b).compareTo(_dayHeaderCount(a)));
  for (final rows in candidates) {
    if (_dayHeaderCount(rows) < 3) continue;
    final result = parseTimetableGrid(rows, totalWeeks: totalWeeks);
    if (result.courses.isNotEmpty) {
      return CourseImportResult(
        courses: result.courses,
        warnings: <String>[...result.warnings, '来自网页表格，请核对后保存'],
        formatLabel: 'HTML 课表',
      );
    }
  }

  final bodyText = document.body?.text ?? '';
  final result = parseTextLines(
    bodyText.split(RegExp(r'\n')),
    totalWeeks: totalWeeks,
  );
  return CourseImportResult(
    courses: result.courses,
    warnings: <String>[...result.warnings, '没有找到课表表格，已尝试按文本识别'],
    formatLabel: 'HTML 文本',
  );
}

int _dayHeaderCount(List<List<String>> rows) {
  var max = 0;
  for (final row in rows) {
    var count = 0;
    for (final cell in row) {
      if (TimetableText.weekday(cell) != null) count++;
    }
    if (count > max) max = count;
  }
  return max;
}
