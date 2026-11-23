import 'dart:convert';

import 'package:material_ui/material_ui.dart';

/// 一节课的时间段。默认按国内高校常见的 45 分钟一节、共 12 节配置。
@immutable
class SectionTime {
  const SectionTime({
    required this.index,
    required this.start,
    required this.end,
  });

  final int index;
  final String start; // HH:mm
  final String end; // HH:mm

  int get startMinutes {
    final parts = start.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  int get endMinutes {
    final parts = end.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String get label => '$start-$end';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'index': index,
        'start': start,
        'end': end,
      };

  static SectionTime? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final index = raw['index'];
    final start = raw['start'];
    final end = raw['end'];
    if (index is! int || start is! String || end is! String) return null;
    return SectionTime(index: index, start: start, end: end);
  }
}

/// 学期配置：第 1 周的周一日期、总周数、每节课时间。
@immutable
class SemesterConfig {
  const SemesterConfig({
    required this.startDate,
    required this.totalWeeks,
    required this.sections,
    this.showWeekend = false,
  });

  /// 第 1 周周一（只保留日期）。
  final DateTime startDate;
  final int totalWeeks;
  final List<SectionTime> sections;
  final bool showWeekend;

  static const List<SectionTime> defaultSections = <SectionTime>[
    SectionTime(index: 1, start: '08:00', end: '08:45'),
    SectionTime(index: 2, start: '08:55', end: '09:40'),
    SectionTime(index: 3, start: '10:00', end: '10:45'),
    SectionTime(index: 4, start: '10:55', end: '11:40'),
    SectionTime(index: 5, start: '14:00', end: '14:45'),
    SectionTime(index: 6, start: '14:55', end: '15:40'),
    SectionTime(index: 7, start: '16:00', end: '16:45'),
    SectionTime(index: 8, start: '16:55', end: '17:40'),
    SectionTime(index: 9, start: '19:00', end: '19:45'),
    SectionTime(index: 10, start: '19:55', end: '20:40'),
    SectionTime(index: 11, start: '20:50', end: '21:35'),
    SectionTime(index: 12, start: '21:45', end: '22:30'),
  ];

  factory SemesterConfig.defaultFor(DateTime now) {
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return SemesterConfig(
      startDate: DateTime(monday.year, monday.month, monday.day),
      totalWeeks: 20,
      sections: defaultSections,
    );
  }

  SectionTime? sectionAt(int index) {
    for (final section in sections) {
      if (section.index == index) return section;
    }
    return null;
  }

  /// 给定日期属于第几周；不在学期内返回 0 或超过 totalWeeks 的值。
  int weekOf(DateTime date) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = day.difference(start).inDays;
    if (diff < 0) return 0;
    return diff ~/ 7 + 1;
  }

  DateTime dateOf(int week, int weekday) {
    return startDate.add(Duration(days: (week - 1) * 7 + weekday - 1));
  }

  int get currentWeek {
    final week = weekOf(DateTime.now());
    if (week < 1) return 1;
    if (week > totalWeeks) return totalWeeks;
    return week;
  }

  List<int> get weekdays =>
      showWeekend ? const <int>[1, 2, 3, 4, 5, 6, 7] : const <int>[1, 2, 3, 4, 5];

  SemesterConfig copyWith({
    DateTime? startDate,
    int? totalWeeks,
    List<SectionTime>? sections,
    bool? showWeekend,
  }) {
    return SemesterConfig(
      startDate: startDate ?? this.startDate,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      sections: sections ?? this.sections,
      showWeekend: showWeekend ?? this.showWeekend,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'totalWeeks': totalWeeks,
        'sections': sections.map((section) => section.toJson()).toList(),
        'showWeekend': showWeekend,
      };

  static SemesterConfig? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final start = raw['startDate'];
    final totalWeeks = raw['totalWeeks'];
    if (start is! String || totalWeeks is! int) return null;
    final startDate = DateTime.tryParse(start);
    if (startDate == null) return null;
    final sections = <SectionTime>[];
    final rawSections = raw['sections'];
    if (rawSections is List) {
      for (final item in rawSections) {
        final section = SectionTime.tryFromJson(item);
        if (section != null) sections.add(section);
      }
    }
    return SemesterConfig(
      startDate: DateTime(startDate.year, startDate.month, startDate.day),
      totalWeeks: totalWeeks.clamp(1, 30),
      sections: sections.isEmpty ? defaultSections : sections,
      showWeekend: raw['showWeekend'] == true,
    );
  }

  String encode() => jsonEncode(toJson());

  static SemesterConfig decode(String? raw) {
    if (raw == null || raw.isEmpty) return SemesterConfig.defaultFor(DateTime.now());
    try {
      return SemesterConfig.tryFromJson(jsonDecode(raw)) ??
          SemesterConfig.defaultFor(DateTime.now());
    } catch (_) {
      return SemesterConfig.defaultFor(DateTime.now());
    }
  }
}
