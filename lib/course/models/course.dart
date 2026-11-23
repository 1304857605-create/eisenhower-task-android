import 'package:material_ui/material_ui.dart';

import 'semester.dart';

/// 一门课程在课表中的一次安排（同一门课不同周次/教室可以建多条）。
@immutable
class Course {
  const Course({
    required this.id,
    required this.name,
    required this.weekday,
    required this.startSection,
    required this.endSection,
    required this.weeks,
    this.teacher = '',
    this.location = '',
    this.note = '',
    required this.createdAt,
    this.colorIndex = 0,
  });

  final String id;
  final String name;
  final String teacher;
  final String location;
  final String note;

  /// 1=周一 … 7=周日
  final int weekday;

  /// 从 1 开始，包含首尾。
  final int startSection;
  final int endSection;

  /// 上课周次，例如 [1,2,…,16]；支持单双周。
  final List<int> weeks;

  final DateTime createdAt;
  final int colorIndex;

  int get sectionSpan => endSection - startSection + 1;

  bool occursInWeek(int week) => weeks.contains(week);

  bool occursOnDate(DateTime date, SemesterConfig semester) {
    if (date.weekday != weekday) return false;
    final week = semester.weekOf(date);
    return week >= 1 && week <= semester.totalWeeks && occursInWeek(week);
  }

  String get weeksLabel => compactWeeks(weeks);

  String timeLabel(SemesterConfig semester) {
    final start = semester.sectionAt(startSection);
    final end = semester.sectionAt(endSection);
    if (start == null || end == null) return '第$startSection-$endSection节';
    return '第$startSection-$endSection节 ${start.start}-${end.end}';
  }

  Course copyWith({
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
    return Course(
      id: id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      note: note ?? this.note,
      weekday: weekday ?? this.weekday,
      startSection: startSection ?? this.startSection,
      endSection: endSection ?? this.endSection,
      weeks: weeks ?? this.weeks,
      createdAt: createdAt,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'teacher': teacher,
        'location': location,
        'note': note,
        'weekday': weekday,
        'startSection': startSection,
        'endSection': endSection,
        'weeks': weeks,
        'createdAt': createdAt.toIso8601String(),
        'colorIndex': colorIndex,
      };

  static Course? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final name = raw['name'];
    final weekday = raw['weekday'];
    final startSection = raw['startSection'];
    final endSection = raw['endSection'];
    if (id is! String || id.isEmpty) return null;
    if (name is! String || name.trim().isEmpty) return null;
    if (weekday is! int || weekday < 1 || weekday > 7) return null;
    if (startSection is! int || endSection is! int) return null;
    if (startSection < 1 || endSection < startSection) return null;
    final weeks = <int>[];
    final rawWeeks = raw['weeks'];
    if (rawWeeks is List) {
      for (final week in rawWeeks) {
        if (week is int && week >= 1 && week <= 30) weeks.add(week);
      }
    }
    if (weeks.isEmpty) return null;
    weeks.sort();
    final createdAt =
        DateTime.tryParse(raw['createdAt'] as String? ?? '') ?? DateTime.now();
    return Course(
      id: id,
      name: name.trim(),
      teacher: (raw['teacher'] as String? ?? '').trim(),
      location: (raw['location'] as String? ?? '').trim(),
      note: (raw['note'] as String? ?? '').trim(),
      weekday: weekday,
      startSection: startSection,
      endSection: endSection,
      weeks: List<int>.unmodifiable(weeks),
      createdAt: createdAt,
      colorIndex: raw['colorIndex'] is int ? raw['colorIndex'] as int : 0,
    );
  }

  /// 把 [1,2,3,5,6,9] 压缩成 "1-3,5-6,9周"。
  static String compactWeeks(List<int> weeks) {
    if (weeks.isEmpty) return '未设置周次';
    final sorted = List<int>.from(weeks)..sort();
    final parts = <String>[];
    var rangeStart = sorted.first;
    var previous = sorted.first;
    for (var i = 1; i <= sorted.length; i++) {
      final current = i < sorted.length ? sorted[i] : null;
      if (current != null && current == previous + 1) {
        previous = current;
        continue;
      }
      if (rangeStart == previous) {
        parts.add('$rangeStart');
      } else {
        parts.add('$rangeStart-$previous');
      }
      if (current != null) {
        rangeStart = current;
        previous = current;
      }
    }
    return '${parts.join(',')}周';
  }

  static const List<Color> palette = <Color>[
    Color(0xFF5B8DEF),
    Color(0xFFE07A5F),
    Color(0xFF3D9970),
    Color(0xFFB07AA1),
    Color(0xFFE0A458),
    Color(0xFF4C9A9A),
    Color(0xFF8E7CC3),
    Color(0xFFD96C8A),
  ];

  Color get color => palette[colorIndex % palette.length];
}
