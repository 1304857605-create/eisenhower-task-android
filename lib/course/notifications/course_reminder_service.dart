import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/course.dart';
import '../models/semester.dart';
import '../state/course_settings_store.dart';
import '../state/course_store.dart';

/// 课程通知：前一天汇总 + 课前 10/5 分钟提醒。
///
/// 只安排未来 14 天的一次性通知，App 每次启动/课程变化时重新同步；
/// 使用非精确闹钟，避免申请 Android 的精确闹钟特殊权限。
class CourseReminderService {
  CourseReminderService._();

  static final CourseReminderService instance = CourseReminderService._();

  static const String _channelId = 'course_reminders';
  static const String _channelName = '课程提醒';
  static const String _channelDescription = '前一天课程汇总与上课前提醒';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    } catch (error) {
      debugPrint('获取本地时区失败，使用默认时区: $error');
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? true;
  }

  Future<void> sync(
    CourseStore store,
    CourseSettingsStore settings,
  ) async {
    if (!settings.remindersEnabled) {
      await _plugin.cancelAll();
      return;
    }
    await init();
    await _plugin.cancelAll();

    final now = DateTime.now();
    final semester = store.semester;
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    final details = NotificationDetails(android: androidDetails);
    var id = 1000;

    // 1) 未来 7 天的前一天课程汇总。
    if (settings.dailySummaryEnabled) {
      final summaryTime = _timeOfDay(settings.summaryMinutes, now);
      for (var offset = 0; offset <= 7; offset++) {
        final tomorrow = _dateOnly(now.add(Duration(days: offset + 1)));
        final courses = store.coursesForDate(tomorrow);
        if (courses.isEmpty) continue;
        final summaryDate = _dateOnly(now.add(Duration(days: offset)));
        var scheduled = DateTime(
          summaryDate.year,
          summaryDate.month,
          summaryDate.day,
          summaryTime.hour,
          summaryTime.minute,
        );
        if (!scheduled.isAfter(now)) {
          scheduled = scheduled.add(const Duration(days: 1));
        }
        if (scheduled.isAfter(now.add(const Duration(days: 8)))) continue;
        final body = courses
            .take(5)
            .map((course) => '${course.name} 第${course.startSection}-${course.endSection}节')
            .join('；');
        await _plugin.zonedSchedule(
          id++,
          '明天有 ${courses.length} 门课',
          body,
          _toTz(scheduled),
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'timetable',
        );
      }
    }

    // 2) 未来 14 天的课前提醒。
    if (settings.preClass10 || settings.preClass5) {
      final endDate = now.add(const Duration(days: 14));
      for (var dayOffset = 0; dayOffset <= 14; dayOffset++) {
        final date = _dateOnly(now.add(Duration(days: dayOffset)));
        final courses = store.coursesForDate(date);
        for (final course in courses) {
          final start = _courseStart(course, date, semester);
          if (start == null || start.isBefore(now) || start.isAfter(endDate)) {
            continue;
          }
          if (settings.preClass10) {
            await _schedulePreClass(
              id++,
              course,
              start.subtract(const Duration(minutes: 10)),
              now,
              details,
              10,
            );
          }
          if (settings.preClass5) {
            await _schedulePreClass(
              id++,
              course,
              start.subtract(const Duration(minutes: 5)),
              now,
              details,
              5,
            );
          }
        }
      }
    }
  }

  Future<void> _schedulePreClass(
    int id,
    Course course,
    DateTime at,
    DateTime now,
    NotificationDetails details,
    int minutes,
  ) async {
    if (!at.isAfter(now)) return;
    final detailsText = [
      if (course.location.isNotEmpty) course.location,
      if (course.teacher.isNotEmpty) course.teacher,
    ].join(' · ');
    await _plugin.zonedSchedule(
      id,
      '$minutes 分钟后有课：${course.name}',
      detailsText.isEmpty ? '记得提前前往教室' : '$detailsText · 记得提前前往教室',
      _toTz(at),
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'timetable',
    );
  }

  DateTime? _courseStart(Course course, DateTime date, SemesterConfig semester) {
    final section = semester.sectionAt(course.startSection);
    if (section == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      section.startMinutes ~/ 60,
      section.startMinutes % 60,
    );
  }

  static tz.TZDateTime _toTz(DateTime date) {
    return tz.TZDateTime.from(date, tz.local);
  }

  static DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static ({int hour, int minute}) _timeOfDay(int minutes, DateTime now) {
    return (hour: minutes ~/ 60, minute: minutes % 60);
  }
}
