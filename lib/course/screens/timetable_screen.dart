import 'package:material_ui/material_ui.dart';

import '../models/course.dart';
import '../models/semester.dart';
import '../notifications/course_reminder_service.dart';
import '../state/course_settings_store.dart';
import '../state/course_store.dart';
import 'course_editor_sheet.dart';
import 'semester_settings_sheet.dart';
import 'timetable_import_screen.dart';

enum _TimetableMode { week, day }

/// 课表页：周视图 / 日视图，左右滑动切换周或天。
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({
    super.key,
    required this.store,
    required this.settings,
  });

  final CourseStore store;
  final CourseSettingsStore settings;

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  _TimetableMode _mode = _TimetableMode.week;
  late int _week;
  late PageController _weekController;
  late PageController _dayController;

  SemesterConfig get _semester => widget.store.semester;

  @override
  void initState() {
    super.initState();
    _week = _semester.currentWeek;
    _weekController = PageController(initialPage: _week - 1);
    _dayController = PageController(initialPage: _todayPageIndex());
  }

  int _todayPageIndex() {
    final now = DateTime.now();
    final index = _semester.weekOf(now) * 7 + now.weekday - 8;
    return index.clamp(0, _semester.totalWeeks * 7 - 1);
  }

  @override
  void dispose() {
    _weekController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[widget.store, widget.settings]),
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final courses = widget.store.all;
        return Scaffold(
          appBar: AppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('课表'),
                const SizedBox(height: 2),
                Text(
                  _mode == _TimetableMode.week
                      ? '第 $_week 周 · ${_dateRange(_week)}'
                      : _dayTitle(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                tooltip: _mode == _TimetableMode.week ? '按天查看' : '按周查看',
                onPressed: () {
                  setState(() {
                    _mode = _mode == _TimetableMode.week
                        ? _TimetableMode.day
                        : _TimetableMode.week;
                  });
                },
                icon: Icon(
                  _mode == _TimetableMode.week
                      ? Icons.view_day_outlined
                      : Icons.calendar_view_week_outlined,
                  size: 20,
                ),
              ),
              IconButton(
                tooltip: '回到今天',
                onPressed: _goToday,
                icon: const Icon(Icons.today_outlined, size: 20),
              ),
              PopupMenuButton<String>(
                tooltip: '更多',
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (value) {
                  if (value == 'import') {
                    Navigator.of(context)
                        .push(MaterialPageRoute<void>(
                          builder: (_) => TimetableImportScreen(store: widget.store),
                        ))
                        .then((_) { setState(() {}); _syncReminders(); });
                  } else if (value == 'semester') {
                    showSemesterSettings(context, widget.store).then((_) {
                      if (mounted) setState(() {});
                    });
                  } else if (value == 'clear') {
                    _clearCourses();
                  }
                },
                itemBuilder: (context) => const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'import',
                    child: Row(children: <Widget>[
                      Icon(Icons.upload_file_rounded, size: 18),
                      SizedBox(width: 9),
                      Text('导入课表'),
                    ]),
                  ),
                  PopupMenuItem<String>(
                    value: 'semester',
                    child: Row(children: <Widget>[
                      Icon(Icons.date_range_outlined, size: 18),
                      SizedBox(width: 9),
                      Text('学期设置'),
                    ]),
                  ),
                  PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'clear',
                    child: Row(children: <Widget>[
                      Icon(Icons.delete_sweep_outlined, size: 18),
                      SizedBox(width: 9),
                      Text('清空课表'),
                    ]),
                  ),
                ],
              ),
              const SizedBox(width: 2),
            ],
          ),
          body: SafeArea(
            top: false,
            child: courses.isEmpty
                ? _EmptyTimetable(
                    onImport: () => Navigator.of(context)
                        .push(MaterialPageRoute<void>(
                          builder: (_) => TimetableImportScreen(store: widget.store),
                        ))
                        .then((_) { setState(() {}); _syncReminders(); }),
                    onAdd: () => _addCourse(),
                  )
                : (_mode == _TimetableMode.week ? _buildWeekView() : _buildDayView()),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'timetable_add_course',
            onPressed: _addCourse,
            tooltip: '添加课程',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.add_rounded, size: 24),
          ),
        );
      },
    );
  }

  Widget _buildWeekView() {
    return PageView.builder(
      controller: _weekController,
      itemCount: _semester.totalWeeks,
      onPageChanged: (index) {
        setState(() => _week = index + 1);
      },
      itemBuilder: (context, index) {
        final week = index + 1;
        return _WeekView(
          week: week,
          semester: _semester,
          courses: widget.store.coursesForWeek(week),
          onCourseTap: _editCourse,
          onEmptyTap: _addCourse,
        );
      },
    );
  }

  Widget _buildDayView() {
    final totalDays = _semester.totalWeeks * 7;
    return PageView.builder(
      controller: _dayController,
      itemCount: totalDays,
      onPageChanged: (index) {
        setState(() {
          _week = index ~/ 7 + 1;
        });
      },
      itemBuilder: (context, index) {
        final date = _semester.startDate.add(Duration(days: index));
        final courses = widget.store.coursesForDate(date);
        return _DayView(
          date: date,
          courses: courses,
          onCourseTap: _editCourse,
          onAdd: () => _addCourse(initialWeekday: date.weekday),
        );
      },
    );
  }

  void _goToday() {
    final week = _semester.currentWeek;
    setState(() => _week = week);
    if (_weekController.hasClients) {
      _weekController.jumpToPage(week - 1);
    }
    if (_dayController.hasClients) {
      _dayController.jumpToPage(_todayPageIndex());
    }
  }

  void _syncReminders() {
    CourseReminderService.instance.sync(widget.store, widget.settings);
  }

  Future<void> _addCourse({int? initialWeekday}) async {
    await showCourseEditor(
      context,
      store: widget.store,
      initialWeekday: initialWeekday,
    );
    _syncReminders();
  }

  Future<void> _editCourse(Course course) async {
    await showCourseEditor(context, store: widget.store, course: course);
    _syncReminders();
  }

  Future<void> _clearCourses() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空课表？'),
        content: Text('将删除全部 ${widget.store.all.length} 门课程，无法恢复。'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('清空'),
          ),
        ],
      ),
    );
    if (confirmed == true) widget.store.clear();
  }

  String _dateRange(int week) {
    final start = _semester.dateOf(week, 1);
    final end = _semester.dateOf(week, _semester.showWeekend ? 7 : 5);
    return '${start.month}/${start.day} - ${end.month}/${end.day}';
  }

  String _dayTitle() {
    final page = _dayController.hasClients ? _dayController.page?.round() : null;
    final date = page == null
        ? DateTime.now()
        : _semester.startDate.add(Duration(days: page));
    return '第 ${_semester.weekOf(date)} 周 · ${_weekdayName(date.weekday)} '
        '${date.month}月${date.day}日';
  }

  static String _weekdayName(int weekday) {
    const names = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return names[(weekday - 1).clamp(0, 6)];
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.week,
    required this.semester,
    required this.courses,
    required this.onCourseTap,
    required this.onEmptyTap,
  });

  final int week;
  final SemesterConfig semester;
  final List<Course> courses;
  final ValueChanged<Course> onCourseTap;
  final VoidCallback onEmptyTap;

  @override
  Widget build(BuildContext context) {
    final days = semester.weekdays;
    final today = DateTime.now();
    final todayWeek = semester.weekOf(today);
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 34),
              for (final day in days)
                Expanded(
                  child: _DayHeader(
                    weekday: day,
                    date: semester.dateOf(week, day),
                    isToday: todayWeek == week && today.weekday == day,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 90),
            child: _WeekGrid(
              week: week,
              semester: semester,
              courses: courses,
              onCourseTap: onCourseTap,
              onEmptyTap: onEmptyTap,
            ),
          ),
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.weekday, required this.date, required this.isToday});

  final int weekday;
  final DateTime date;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const names = <String>['一', '二', '三', '四', '五', '六', '日'];
    return Column(
      children: <Widget>[
        Text(
          '周${names[weekday - 1]}',
          style: TextStyle(
            fontSize: 10,
            color: isToday ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 23,
          height: 23,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isToday ? scheme.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              color: isToday ? scheme.onPrimary : scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeekGrid extends StatelessWidget {
  const _WeekGrid({
    required this.week,
    required this.semester,
    required this.courses,
    required this.onCourseTap,
    required this.onEmptyTap,
  });

  final int week;
  final SemesterConfig semester;
  final List<Course> courses;
  final ValueChanged<Course> onCourseTap;
  final VoidCallback onEmptyTap;

  static const double _rowHeight = 52;
  static const double _timeWidth = 34;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = semester.weekdays;
    final sections = semester.sections;
    return LayoutBuilder(
      builder: (context, constraints) {
        final dayWidth = (constraints.maxWidth - _timeWidth) / days.length;
        final totalHeight = sections.length * _rowHeight;
        return SizedBox(
          height: totalHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: _timeWidth,
                child: Column(
                  children: sections.map((section) {
                    return SizedBox(
                      height: _rowHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${section.index}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            section.start,
                            style: TextStyle(
                              fontSize: 7.5,
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onEmptyTap,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GridPainter(
                            dayCount: days.length,
                            rowCount: sections.length,
                            color: scheme.outlineVariant.withValues(alpha: 0.55),
                          ),
                        ),
                      ),
                      for (final course in courses)
                        Positioned(
                          left: (days.indexOf(course.weekday)) * dayWidth + 1,
                          top: (course.startSection - 1) * _rowHeight + 1,
                          width: dayWidth - 2,
                          height: course.sectionSpan * _rowHeight - 2,
                          child: _CourseBlock(
                            course: course,
                            onTap: () => onCourseTap(course),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.dayCount, required this.rowCount, required this.color});

  final int dayCount;
  final int rowCount;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.6;
    final dayWidth = size.width / dayCount;
    final rowHeight = size.height / rowCount;
    for (var i = 0; i <= dayCount; i++) {
      final x = i * dayWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var i = 0; i <= rowCount; i++) {
      final y = i * rowHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.dayCount != dayCount ||
      oldDelegate.rowCount != rowCount;
}

class _CourseBlock extends StatelessWidget {
  const _CourseBlock({required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = course.color;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: scheme.brightness == Brightness.dark ? 0.26 : 0.14),
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              course.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.5,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            if (course.location.isNotEmpty)
              Text(
                course.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayView extends StatelessWidget {
  const _DayView({
    required this.date,
    required this.courses,
    required this.onCourseTap,
    required this.onAdd,
  });

  final DateTime date;
  final List<Course> courses;
  final ValueChanged<Course> onCourseTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const weekdays = <String>['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      children: <Widget>[
        Text(
          '${date.month}月${date.day}日 · ${weekdays[date.weekday - 1]}',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (courses.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 34),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Icon(Icons.wb_sunny_outlined, size: 28, color: scheme.primary.withValues(alpha: 0.55)),
                const SizedBox(height: 8),
                Text(
                  '今天没有课，放松一下',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('添加课程'),
                ),
              ],
            ),
          )
        else
          for (final course in courses) _DayCourseCard(course: course, onTap: () => onCourseTap(course)),
      ],
    );
  }
}

class _DayCourseCard extends StatelessWidget {
  const _DayCourseCard({required this.course, required this.onTap});

  final Course course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = course.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 4,
                height: 42,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      course.name,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '第${course.startSection}-${course.endSection}节 · ${course.weeksLabel}',
                      style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                    ),
                    if (course.location.isNotEmpty || course.teacher.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        [
                          if (course.location.isNotEmpty) course.location,
                          if (course.teacher.isNotEmpty) course.teacher,
                        ].join(' · '),
                        style: TextStyle(fontSize: 10, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTimetable extends StatelessWidget {
  const _EmptyTimetable({required this.onImport, required this.onAdd});

  final VoidCallback onImport;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.calendar_month_outlined, size: 34, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              '还没有课表',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: scheme.onSurface),
            ),
            const SizedBox(height: 6),
            Text(
              '从教务系统导出的 ICS / Excel / Word / PDF 文件，或手动添加课程。\n文件只在本机解析。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, height: 1.7, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.upload_file_rounded, size: 18),
              label: const Text('导入课表'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(150, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: onAdd, child: const Text('手动添加一门课')),
          ],
        ),
      ),
    );
  }
}
