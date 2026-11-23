import 'dart:convert';


import '../models/semester.dart';
import 'grid_parser.dart';
import 'import_models.dart';

/// 解析 .ics 日历文件（学校教务系统大多支持导出 ICS，或从手机日历导出）。
CourseImportResult parseIcs(
  List<int> bytes, {
  required SemesterConfig semester,
}) {
  final warnings = <String>[];
  String text;
  try {
    text = utf8.decode(bytes);
  } catch (_) {
    text = latin1.decode(bytes);
  }
  final events = _parseEvents(text);
  if (events.isEmpty) {
    return const CourseImportResult(
      courses: <CourseDraft>[],
      warnings: <String>['没有在文件里找到日历事件（VEVENT）'],
    );
  }

  final drafts = <CourseDraft>[];
  for (final event in events) {
    final summary = _unescape(event['SUMMARY'] ?? '');
    final dtStart = _parseIcsDate(event['DTSTART']);
    if (summary.isEmpty || dtStart == null) continue;
    final dtEnd = _parseIcsDate(event['DTEND']) ??
        dtStart.add(const Duration(minutes: 45));
    if (dtStart.hour == 0 && dtStart.minute == 0 && dtEnd.hour == 0) {
      warnings.add('跳过全天事件：$summary');
      continue;
    }

    final weekday = dtStart.weekday;
    final startSection = _sectionForTime(semester, dtStart, isStart: true);
    final endSection = _sectionForTime(semester, dtEnd, isStart: false);
    final weeks = _weeksForEvent(event, dtStart, semester);
    if (weeks.isEmpty) {
      warnings.add('事件不在学期周次内，已跳过：$summary');
      continue;
    }

    final location = _unescape(event['LOCATION'] ?? '');
    final description = _unescape(event['DESCRIPTION'] ?? '');
    drafts.add(CourseDraft(
      name: summary,
      teacher: _guessTeacher(description),
      location: location,
      note: description.replaceAll(RegExp(r'\s+'), ' ').trim(),
      weekday: weekday,
      startSection: startSection,
      endSection: endSection.clamp(startSection, semester.sections.length),
      weeks: weeks,
      colorIndex: colorForIndex(drafts.length),
    ));
  }

  if (drafts.isEmpty) {
    warnings.add('日历事件里没有可用的课程信息');
  } else {
    warnings.add('已从 .ics 识别 ${drafts.length} 个课程安排，请核对时间与周次');
  }
  return CourseImportResult(
    courses: drafts,
    warnings: warnings,
    formatLabel: 'ICS 日历',
  );
}

class _IcsEvent {
  _IcsEvent(this.values);

  final Map<String, String> values;
  String? operator [](String key) => values[key];
}

List<_IcsEvent> _parseEvents(String input) {
  final unfolded = <String>[];
  for (final rawLine in input.split(RegExp(r'\r?\n'))) {
    if ((rawLine.startsWith(' ') || rawLine.startsWith('\t')) &&
        unfolded.isNotEmpty) {
      unfolded[unfolded.length - 1] += rawLine.substring(1);
    } else {
      unfolded.add(rawLine);
    }
  }

  final events = <_IcsEvent>[];
  Map<String, String>? current;
  for (final line in unfolded) {
    if (line == 'BEGIN:VEVENT') {
      current = <String, String>{};
      continue;
    }
    if (line == 'END:VEVENT') {
      if (current != null) events.add(_IcsEvent(current));
      current = null;
      continue;
    }
    if (current == null) continue;
    final colon = line.indexOf(':');
    if (colon <= 0) continue;
    final keyPart = line.substring(0, colon);
    final value = line.substring(colon + 1);
    final key = keyPart.split(';').first.toUpperCase();
    // 保留同名字段的第一条（DESCRIPTION 可能很长，够用）。
    current.putIfAbsent(key, () => value);
  }
  return events;
}

DateTime? _parseIcsDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  var value = raw.trim();
  // 去掉 TZID=...: 前缀
  final colon = value.lastIndexOf(':');
  if (value.contains('TZID') && colon > 0) {
    value = value.substring(colon + 1);
  }
  value = value.replaceAll('-', '').replaceAll(':', '');
  final isUtc = value.endsWith('Z');
  if (isUtc) value = value.substring(0, value.length - 1);

  if (value.contains('T')) {
    final parts = value.split('T');
    final date = parts[0];
    final time = parts[1];
    if (date.length < 8 || time.length < 4) return null;
    final parsed = DateTime(
      int.parse(date.substring(0, 4)),
      int.parse(date.substring(4, 6)),
      int.parse(date.substring(6, 8)),
      int.parse(time.substring(0, 2)),
      int.parse(time.substring(2, 4)),
      time.length >= 6 ? int.parse(time.substring(4, 6)) : 0,
    );
    return isUtc ? parsed.toLocal() : parsed;
  }
  if (value.length >= 8) {
    return DateTime(
      int.parse(value.substring(0, 4)),
      int.parse(value.substring(4, 6)),
      int.parse(value.substring(6, 8)),
    );
  }
  return null;
}

int _sectionForTime(SemesterConfig semester, DateTime time, {required bool isStart}) {
  final minutes = time.hour * 60 + time.minute;
  int? best;
  var bestDiff = 1 << 30;
  for (final section in semester.sections) {
    final diff = isStart
        ? (minutes - section.startMinutes).abs()
        : (minutes - section.endMinutes).abs();
    if (diff < bestDiff) {
      bestDiff = diff;
      best = section.index;
    }
  }
  return (best ?? 1).clamp(1, semester.sections.length);
}

List<int> _weeksForEvent(
  _IcsEvent event,
  DateTime dtStart,
  SemesterConfig semester,
) {
  final rule = event['RRULE'];
  final startWeek = semester.weekOf(dtStart);
  if (startWeek < 1 || startWeek > semester.totalWeeks) return <int>[];

  if (rule == null || rule.isEmpty) {
    return <int>[startWeek];
  }

  final parts = <String, String>{};
  for (final item in rule.split(';')) {
    final eq = item.indexOf('=');
    if (eq > 0) {
      parts[item.substring(0, eq).toUpperCase()] = item.substring(eq + 1);
    }
  }
  final interval = int.tryParse(parts['INTERVAL'] ?? '1') ?? 1;
  final count = int.tryParse(parts['COUNT'] ?? '');
  final until = _parseIcsDate(parts['UNTIL']);

  final weeks = <int>[];
  var week = startWeek;
  var generated = 0;
  while (week <= semester.totalWeeks && weeks.length < 60) {
    if (count != null && generated >= count) break;
    if (until != null) {
      final date = semester.dateOf(week, dtStart.weekday);
      if (date.isAfter(until)) break;
    }
    weeks.add(week);
    generated++;
    week += interval;
  }
  return weeks;
}

String _guessTeacher(String description) {
  final match = RegExp(r'(?:教师|老师|授课教师)[:：]?\s*([^\s,，;；]{1,20})')
      .firstMatch(description);
  return match?.group(1)?.trim() ?? '';
}

String _unescape(String value) {
  return value
      .replaceAll('\\n', '\n')
      .replaceAll('\\N', '\n')
      .replaceAll('\\,', ',')
      .replaceAll('\\;', ';')
      .replaceAll('\\\\', '\\')
      .trim();
}
