import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quadrant_list/course/import/html_importer.dart';
import 'package:quadrant_list/course/import/ics_importer.dart';
import 'package:quadrant_list/course/import/import_models.dart';
import 'package:quadrant_list/course/import/spreadsheet_importer.dart';
import 'package:quadrant_list/course/models/course.dart';
import 'package:quadrant_list/course/models/semester.dart';
import 'package:quadrant_list/course/state/course_settings_store.dart';
import 'package:quadrant_list/course/state/course_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final semester = SemesterConfig(
    startDate: DateTime(2026, 9, 7),
    totalWeeks: 20,
    sections: SemesterConfig.defaultSections,
  );

  test('学期周次计算', () {
    expect(semester.weekOf(DateTime(2026, 9, 7)), 1);
    expect(semester.weekOf(DateTime(2026, 9, 13)), 1);
    expect(semester.weekOf(DateTime(2026, 9, 14)), 2);
    expect(semester.dateOf(2, 1), DateTime(2026, 9, 14));
  });

  test('周次解析支持单双周与范围', () {
    expect(TimetableText.weeks('1-16周', totalWeeks: 20), List<int>.generate(16, (i) => i + 1));
    expect(TimetableText.weeks('1-8周(单)', totalWeeks: 20), <int>[1, 3, 5, 7]);
    expect(TimetableText.weeks('第1-4,6周', totalWeeks: 20), <int>[1, 2, 3, 4, 6]);
  });

  test('节次解析', () {
    expect(TimetableText.sections('第1-2节'), (1, 2));
    expect(TimetableText.sections('3'), (3, 3));
    expect(TimetableText.sections(''), isNull);
  });

  test('CSV 标准列导入', () {
    final csv = '课程名称,星期,开始节次,结束节次,周次,教师,地点\n'
        '高等数学,周一,1,2,1-16周,李老师,教1-201\n'
        '大学英语,周三,3,4,1-8周,Amy,外语楼302\n';
    final result = parseCsv(utf8.encode(csv), totalWeeks: 20);
    expect(result.courses, hasLength(2));
    expect(result.courses.first.name, '高等数学');
    expect(result.courses.first.weekday, 1);
    expect(result.courses.first.startSection, 1);
    expect(result.courses.first.endSection, 2);
    expect(result.courses.first.teacher, '李老师');
    expect(result.courses.first.location, '教1-201');
    expect(result.courses.last.weeks, hasLength(8));
  });

  test('HTML 表格课表导入', () {
    const html = '''
<html><body><table>
<tr><th>节次</th><th>周一</th><th>周二</th><th>周三</th></tr>
<tr><td>1</td><td>高等数学<br/>李老师<br/>教1-201<br/>1-16周</td><td></td><td></td></tr>
<tr><td>2</td><td>高等数学<br/>李老师<br/>教1-201<br/>1-16周</td><td></td><td></td></tr>
<tr><td>3</td><td></td><td></td><td>大学英语<br/>外语楼302<br/>1-8周</td></tr>
</table></body></html>
''';
    final result = parseHtml(utf8.encode(html), totalWeeks: 20);
    expect(result.courses, isNotEmpty);
    final math = result.courses.firstWhere((course) => course.name == '高等数学');
    expect(math.weekday, 1);
    expect(math.weeks.first, 1);
  });

  test('ICS 重复课程导入', () {
    final ics = '''BEGIN:VCALENDAR
VERSION:2.0
BEGIN:VEVENT
SUMMARY:高等数学
LOCATION:教1-201
DTSTART:20260907T080000
DTEND:20260907T094000
RRULE:FREQ=WEEKLY;COUNT=3
END:VEVENT
END:VCALENDAR
''';
    final result = parseIcs(utf8.encode(ics), semester: semester);
    expect(result.courses, hasLength(1));
    final course = result.courses.first;
    expect(course.name, '高等数学');
    expect(course.weekday, 1);
    expect(course.weeks, <int>[1, 2, 3]);
    expect(course.startSection, 1);
  });

  test('Course.compactWeeks 压缩连续周次', () {
    expect(Course.compactWeeks(<int>[1, 2, 3, 5, 6, 9]), '1-3,5-6,9周');
    expect(Course.compactWeeks(<int>[1]), '1周');
  });

  test('CourseStore 导入去重与持久化', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final store = CourseStore(prefs)..load();
    store.setSemester(semester);
    expect(store.all, isEmpty);

    final course = Course(
      id: 'c1',
      name: '高等数学',
      weekday: 1,
      startSection: 1,
      endSection: 2,
      weeks: <int>[1, 2, 3],
      createdAt: DateTime(2026, 9, 1),
    );
    expect(store.importCourses(<Course>[course]), 1);
    expect(store.importCourses(<Course>[course]), 0);
    expect(store.all, hasLength(1));
    expect(store.coursesForDate(DateTime(2026, 9, 7)), hasLength(1));

    await Future<void>.delayed(const Duration(milliseconds: 30));
    final reloaded = CourseStore(prefs)..load();
    expect(reloaded.all, hasLength(1));
  });

  test('CourseSettingsStore 默认值与开关持久化', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final settings = CourseSettingsStore(prefs)..load();
    expect(settings.remindersEnabled, isFalse);
    expect(settings.quoteVisible, isTrue);
    settings.setRemindersEnabled(true);
    settings.setQuoteOnlineEnabled(true);
    final reloaded = CourseSettingsStore(prefs)..load();
    expect(reloaded.remindersEnabled, isTrue);
    expect(reloaded.quoteOnlineEnabled, isTrue);
  });
}
