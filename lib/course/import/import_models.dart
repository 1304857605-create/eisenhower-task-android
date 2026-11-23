
import 'package:flutter/foundation.dart';

/// 导入时的课程草稿（还没有本地 id）。
@immutable
class CourseDraft {
  const CourseDraft({
    required this.name,
    required this.weekday,
    required this.startSection,
    required this.endSection,
    required this.weeks,
    this.teacher = '',
    this.location = '',
    this.note = '',
    this.colorIndex = 0,
  });

  final String name;
  final String teacher;
  final String location;
  final String note;
  final int weekday;
  final int startSection;
  final int endSection;
  final List<int> weeks;
  final int colorIndex;

  CourseDraft copyWith({
    String? name,
    String? teacher,
    String? location,
    String? note,
    int? weekday,
    int? startSection,
    int? endSection,
    List<int>? weeks,
    int? colorIndex,
  }) {
    return CourseDraft(
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      note: note ?? this.note,
      weekday: weekday ?? this.weekday,
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      weeks: weeks ?? this.weeks,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }
}

/// 一个文件的导入结果。
@immutable
class CourseImportResult {
  const CourseImportResult({
    required this.courses,
    this.warnings = const <String>[],
    this.suggestedStartDate,
    this.suggestedTotalWeeks,
    this.formatLabel = '',
  });

  final List<CourseDraft> courses;
  final List<String> warnings;
  final DateTime? suggestedStartDate;
  final int? suggestedTotalWeeks;
  final String formatLabel;

  bool get isEmpty => courses.isEmpty;
}

@immutable
class ImportInput {
  const ImportInput({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;

  String get extension {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }
}

/// 通用解析工具：星期、节次、周次。
abstract final class TimetableText {
  static const Map<String, int> _weekdays = <String, int>{
    '周一': 1,
    '星期一': 1,
    '一': 1,
    'mon': 1,
    'monday': 1,
    '周二': 2,
    '星期二': 2,
    '二': 2,
    'tue': 2,
    'tuesday': 2,
    '周三': 3,
    '星期三': 3,
    '三': 3,
    'wed': 3,
    'wednesday': 3,
    '周四': 4,
    '星期四': 4,
    '四': 4,
    'thu': 4,
    'thursday': 4,
    '周五': 5,
    '星期五': 5,
    '五': 5,
    'fri': 5,
    'friday': 5,
    '周六': 6,
    '星期六': 6,
    '六': 6,
    'sat': 6,
    'saturday': 6,
    '周日': 7,
    '周天': 7,
    '星期日': 7,
    '星期天': 7,
    '日': 7,
    '七': 7,
    'sun': 7,
    'sunday': 7,
  };

  static int? weekday(String? text) {
    if (text == null) return null;
    final normalized = text.trim().toLowerCase().replaceAll(RegExp(r'[\s:：]'), '');
    if (normalized.isEmpty) return null;
    final direct = _weekdays[normalized];
    if (direct != null) return direct;
    for (final entry in _weekdays.entries) {
      if (normalized.contains(entry.key)) return entry.value;
    }
    return null;
  }

  /// 解析 "1-16周"、"1-16周(单)"、"1,3,5-8周"、"第1-16周" 等。
  /// [totalWeeks] 用于展开单双周与截断超出范围。
  static List<int>? weeks(String? raw, {int totalWeeks = 20}) {
    if (raw == null) return null;
    final text = raw.trim();
    if (text.isEmpty) return null;
    final isOdd = RegExp(r'[（(【\[]?\s*单\s*[）)】\]]?').hasMatch(text);
    final isEven = RegExp(r'[（(【\[]?\s*双\s*[）)】\]]?').hasMatch(text);
    final cleaned = text
        .replaceAll(RegExp(r'第'), '')
        .replaceAll(RegExp(r'周[次]?'), '')
        .replaceAll(RegExp(r'[（(【\[].*?[）)】\]]'), '')
        .replaceAll(RegExp(r'\s'), '');
    if (cleaned.isEmpty) return null;
    final result = <int>{};
    for (final part in cleaned.split(RegExp(r'[,，、;；]'))) {
      if (part.isEmpty) continue;
      final range = RegExp(r'^(\d+)(?:-(\d+))?$').firstMatch(part);
      if (range == null) continue;
      final start = int.parse(range.group(1)!);
      final end = int.parse(range.group(2) ?? range.group(1)!);
      if (end < start) continue;
      for (var week = start; week <= end; week++) {
        if (week < 1 || week > totalWeeks) continue;
        if (isOdd && week.isEven) continue;
        if (isEven && week.isOdd) continue;
        result.add(week);
      }
    }
    if (result.isEmpty) return null;
    final list = result.toList()..sort();
    return list;
  }

  /// 解析 "1-2节"、"第1-2节"、"3,4节"、"1" 等，返回 (start,end)。
  static (int, int)? sections(String? raw) {
    if (raw == null) return null;
    final cleaned = raw
        .replaceAll(RegExp(r'第'), '')
        .replaceAll(RegExp(r'节'), '')
        .replaceAll(RegExp(r'\s'), '');
    final range = RegExp(r'^(\d+)-(\d+)$').firstMatch(cleaned);
    if (range != null) {
      final start = int.parse(range.group(1)!);
      final end = int.parse(range.group(2)!);
      if (start >= 1 && end >= start) return (start, end);
    }
    final single = int.tryParse(cleaned);
    if (single != null && single >= 1) return (single, single);
    return null;
  }

  static RegExp get weekdayPattern => RegExp(
        r'(周[一二三四五六日天]|星期[一二三四五六日天])',
      );

  static String cleanLine(String input) {
    return input
        .replaceAll('\u3000', ' ')
        .replaceAll(RegExp(r'[\t\r]+'), ' ')
        .replaceAll(RegExp(r' +'), ' ')
        .trim();
  }
}
