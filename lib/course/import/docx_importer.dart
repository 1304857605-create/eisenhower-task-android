import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

import 'grid_parser.dart';
import 'import_models.dart';

/// 解析 Word .docx 里的课表表格。只处理 .docx（Word 2007+），不支持旧 .doc。
CourseImportResult parseDocx(
  List<int> bytes, {
  required int totalWeeks,
}) {
  final warnings = <String>[];
  final archive = ZipDecoder().decodeBytes(bytes);
  ArchiveFile? documentFile;
  for (final file in archive.files) {
    if (file.name == 'word/document.xml') {
      documentFile = file;
      break;
    }
  }
  if (documentFile == null) {
    return const CourseImportResult(
      courses: <CourseDraft>[],
      warnings: <String>['不是有效的 .docx 文件（缺少 word/document.xml）'],
    );
  }

  final xmlText = utf8.decode(documentFile.content as List<int>, allowMalformed: true);
  final document = XmlDocument.parse(xmlText);
  final tables = document.descendants.whereType<XmlElement>().where(
        (element) => element.name.local == 'tbl',
      );

  final candidateRows = <List<List<String>>>[];
  for (final table in tables) {
    final rows = <List<String>>[];
    for (final rowElement in table.descendants.whereType<XmlElement>().where(
          (element) => element.name.local == 'tr',
        )) {
      final cells = <String>[];
      for (final cellElement in rowElement.children.whereType<XmlElement>().where(
            (element) => element.name.local == 'tc',
          )) {
        final paragraphs = cellElement.descendants
            .whereType<XmlElement>()
            .where((element) => element.name.local == 'p')
            .map((element) => element.descendants
                .whereType<XmlElement>()
                .where((child) => child.name.local == 't')
                .map((child) => child.innerText)
                .join())
            .where((text) => text.trim().isNotEmpty)
            .toList();
        final text = paragraphs.isEmpty
            ? cellElement.descendants
                .whereType<XmlElement>()
                .where((element) => element.name.local == 't')
                .map((element) => element.innerText)
                .join(' ')
            : paragraphs.join('\n');
        cells.add(TimetableText.cleanLine(text));
      }
      if (cells.isNotEmpty) rows.add(cells);
    }
    if (rows.isNotEmpty) candidateRows.add(rows);
  }

  // 选星期表头最多的一张表。
  candidateRows.sort((a, b) => _dayHeaderCount(b).compareTo(_dayHeaderCount(a)));
  for (final rows in candidateRows) {
    if (_dayHeaderCount(rows) < 3) continue;
    final result = parseTimetableGrid(rows, totalWeeks: totalWeeks);
    if (result.courses.isNotEmpty) {
      return CourseImportResult(
        courses: result.courses,
        warnings: <String>[...result.warnings, '来自 Word 表格，请核对合并单元格是否解析正确'],
        formatLabel: 'Word 课表',
      );
    }
  }

  // 没有表格时，退化为按段落行解析（部分学校导出的是文本课表）。
  final paragraphs = <String>[];
  for (final paragraph in document.descendants.whereType<XmlElement>().where(
        (element) => element.name.local == 'p',
      )) {
    final text = paragraph.descendants
        .whereType<XmlElement>()
        .where((element) => element.name.local == 't')
        .map((element) => element.innerText)
        .join()
        .trim();
    if (text.isNotEmpty) paragraphs.add(text);
  }
  if (paragraphs.isNotEmpty) {
    final result = parseTextLines(paragraphs, totalWeeks: totalWeeks);
    return CourseImportResult(
      courses: result.courses,
      warnings: <String>[...result.warnings, ...warnings],
      formatLabel: 'Word 文本',
    );
  }

  return const CourseImportResult(
    courses: <CourseDraft>[],
    warnings: <String>['Word 文档中没有找到课表表格或课程文本'],
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
