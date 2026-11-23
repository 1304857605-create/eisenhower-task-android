import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/course.dart';
import '../models/semester.dart';

/// 课表数据仓库：课程 + 学期配置，全部保存在本机。
class CourseStore extends ChangeNotifier {
  CourseStore(this._prefs);

  static const String _coursesKey = 'courses_v1';
  static const String _semesterKey = 'semester_v1';

  final SharedPreferences _prefs;
  final List<Course> _courses = <Course>[];
  SemesterConfig _semester = SemesterConfig.defaultFor(DateTime.now());
  Future<void> _saveQueue = Future<void>.value();

  List<Course> get all => List<Course>.unmodifiable(_courses);

  SemesterConfig get semester => _semester;

  int get currentWeek => _semester.currentWeek;

  void load() {
    _semester = SemesterConfig.decode(_prefs.getString(_semesterKey));
    _courses.clear();
    final raw = _prefs.getString(_coursesKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded) {
            final course = Course.tryFromJson(item);
            if (course != null) _courses.add(course);
          }
        }
      } catch (error) {
        debugPrint('读取课表失败: $error');
      }
    }
    _sort();
    notifyListeners();
  }

  List<Course> coursesForWeek(int week) {
    return _courses.where((course) => course.occursInWeek(week)).toList()
      ..sort(_compare);
  }

  List<Course> coursesForDate(DateTime date) {
    final week = _semester.weekOf(date);
    if (week < 1 || week > _semester.totalWeeks) return <Course>[];
    return _courses
        .where((course) =>
            course.weekday == date.weekday && course.occursInWeek(week))
        .toList()
      ..sort(_compare);
  }

  List<Course> coursesForWeekday(int week, int weekday) {
    return _courses
        .where((course) => course.weekday == weekday && course.occursInWeek(week))
        .toList()
      ..sort(_compare);
  }

  Course? byId(String id) {
    for (final course in _courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  Course add({
    required String name,
    required int weekday,
    required int startSection,
    required int endSection,
    required List<int> weeks,
    String teacher = '',
    String location = '',
    String note = '',
    int? colorIndex,
  }) {
    final course = Course(
      id: _newId(),
      name: name.trim(),
      teacher: teacher.trim(),
      location: location.trim(),
      note: note.trim(),
      weekday: weekday,
      startSection: startSection,
      endSection: endSection,
      weeks: _normalizeWeeks(weeks),
      createdAt: DateTime.now(),
      colorIndex: colorIndex ?? _courses.length % Course.palette.length,
    );
    _courses.add(course);
    _sort();
    _persistAndNotify();
    return course;
  }

  void update(Course course) {
    final index = _courses.indexWhere((item) => item.id == course.id);
    if (index == -1) return;
    _courses[index] = course;
    _sort();
    _persistAndNotify();
  }

  void delete(String id) {
    final before = _courses.length;
    _courses.removeWhere((course) => course.id == id);
    if (_courses.length != before) _persistAndNotify();
  }

  /// 导入：追加模式会跳过同一天、同一节次、周次有交集的同名课程。
  /// 返回实际新增数量。
  int importCourses(List<Course> incoming, {bool replace = false}) {
    if (replace) {
      _courses.clear();
    }
    var added = 0;
    for (final course in incoming) {
      final normalized = course.copyWith(weeks: _normalizeWeeks(course.weeks));
      final duplicate = _courses.any((existing) =>
          existing.name == normalized.name &&
          existing.weekday == normalized.weekday &&
          existing.startSection == normalized.startSection &&
          existing.endSection == normalized.endSection &&
          existing.weeks.any(normalized.weeks.contains));
      if (duplicate) continue;
      _courses.add(normalized);
      added++;
    }
    _sort();
    _persistAndNotify();
    return added;
  }

  void clear() {
    if (_courses.isEmpty) return;
    _courses.clear();
    _persistAndNotify();
  }

  void setSemester(SemesterConfig semester) {
    _semester = semester;
    _prefs.setString(_semesterKey, semester.encode());
    notifyListeners();
  }

  /// 距离现在最近的下一次上课（最多向后找 8 周），用于日历/提醒。
  ({DateTime start, DateTime end, Course course})? nextOccurrence(
    Course course, {
    DateTime? from,
  }) {
    final now = from ?? DateTime.now();
    for (var i = 0; i < 8 * 7; i++) {
      final day = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      if (!course.occursOnDate(day, _semester)) continue;
      final startSection = _semester.sectionAt(course.startSection);
      final endSection = _semester.sectionAt(course.endSection);
      if (startSection == null || endSection == null) continue;
      final start = DateTime(
        day.year,
        day.month,
        day.day,
        startSection.startMinutes ~/ 60,
        startSection.startMinutes % 60,
      );
      if (!start.isAfter(now)) continue;
      final end = DateTime(
        day.year,
        day.month,
        day.day,
        endSection.endMinutes ~/ 60,
        endSection.endMinutes % 60,
      );
      return (start: start, end: end, course: course);
    }
    return null;
  }

  List<int> _normalizeWeeks(List<int> weeks) {
    final set = <int>{};
    for (final week in weeks) {
      if (week >= 1 && week <= 30) set.add(week);
    }
    final list = set.toList()..sort();
    return list;
  }

  int _compare(Course a, Course b) {
    final byDay = a.weekday.compareTo(b.weekday);
    if (byDay != 0) return byDay;
    return a.startSection.compareTo(b.startSection);
  }

  void _sort() {
    _courses.sort(_compare);
  }

  String _newId() {
    final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final salt = (_courses.length + DateTime.now().millisecond)
        .toRadixString(36);
    return 'c-$time-$salt';
  }

  void _persistAndNotify() {
    notifyListeners();
    final courses = List<Course>.of(_courses);
    _saveQueue = _saveQueue.then((_) async {
      final raw = jsonEncode(courses.map((course) => course.toJson()).toList());
      await _prefs.setString(_coursesKey, raw);
    }).catchError((Object error) {
      debugPrint('保存课表失败: $error');
    });
  }
}
