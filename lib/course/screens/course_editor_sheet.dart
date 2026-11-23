import 'package:material_ui/material_ui.dart';

import '../calendar/calendar_bridge.dart';
import '../models/course.dart';
import '../state/course_store.dart';

Future<void> showCourseEditor(
  BuildContext context, {
  required CourseStore store,
  Course? course,
  int? initialWeekday,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) => CourseEditorSheet(
      store: store,
      course: course,
      initialWeekday: initialWeekday,
    ),
  );
}

class CourseEditorSheet extends StatefulWidget {
  const CourseEditorSheet({
    super.key,
    required this.store,
    this.course,
    this.initialWeekday,
  });

  final CourseStore store;
  final Course? course;
  final int? initialWeekday;

  @override
  State<CourseEditorSheet> createState() => _CourseEditorSheetState();
}

class _CourseEditorSheetState extends State<CourseEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _teacher;
  late final TextEditingController _location;
  late final TextEditingController _note;
  late int _weekday;
  late int _startSection;
  late int _endSection;
  late Set<int> _weeks;
  String? _error;

  bool get _isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    _name = TextEditingController(text: course?.name ?? '');
    _teacher = TextEditingController(text: course?.teacher ?? '');
    _location = TextEditingController(text: course?.location ?? '');
    _note = TextEditingController(text: course?.note ?? '');
    _weekday = course?.weekday ?? widget.initialWeekday ?? DateTime.now().weekday.clamp(1, 5);
    _startSection = course?.startSection ?? 1;
    _endSection = course?.endSection ?? 2;
    _weeks = course?.weeks.toSet() ??
        List<int>.generate(widget.store.semester.totalWeeks, (index) => index + 1)
            .toSet();
  }

  @override
  void dispose() {
    _name.dispose();
    _teacher.dispose();
    _location.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final semester = widget.store.semester;
    final sectionCount = semester.sections.length;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isEditing ? '编辑课程' : '添加课程',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  maxLength: 40,
                  decoration: const InputDecoration(
                    hintText: '课程名称',
                    counterText: '',
                    errorText: null,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _teacher,
                        decoration: const InputDecoration(hintText: '教师（可选）'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _location,
                        decoration: const InputDecoration(hintText: '地点（可选）'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _Label('上课日'),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: semester.weekdays.map((day) {
                    final selected = day == _weekday;
                    return _ChoicePill(
                      label: _weekdayName(day),
                      selected: selected,
                      onTap: () => setState(() => _weekday = day),
                    );
                  }).toList(growable: false),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _SectionDropdown(
                        label: '开始节次',
                        value: _startSection,
                        count: sectionCount,
                        onChanged: (value) => setState(() {
                          _startSection = value;
                          if (_endSection < _startSection) _endSection = _startSection;
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SectionDropdown(
                        label: '结束节次',
                        value: _endSection,
                        count: sectionCount,
                        onChanged: (value) => setState(() {
                          _endSection = value;
                          if (_endSection < _startSection) _startSection = _endSection;
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    _Label('上课周次'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() {
                        _weeks = List<int>.generate(semester.totalWeeks, (i) => i + 1).toSet();
                      }),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: const Text('全选'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _weeks = <int>{for (var i = 1; i <= semester.totalWeeks; i++) if (i.isOdd) i};
                      }),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: const Text('单周'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _weeks = <int>{for (var i = 1; i <= semester.totalWeeks; i++) if (i.isEven) i};
                      }),
                      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      child: const Text('双周'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: List<Widget>.generate(semester.totalWeeks, (index) {
                    final week = index + 1;
                    final selected = _weeks.contains(week);
                    return InkWell(
                      onTap: () => setState(() {
                        if (selected) {
                          _weeks.remove(week);
                        } else {
                          _weeks.add(week);
                        }
                      }),
                      borderRadius: BorderRadius.circular(8),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 120),
                        width: 30,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? scheme.primary
                              : scheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$week',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _note,
                  maxLines: 2,
                  maxLength: 100,
                  decoration: const InputDecoration(hintText: '备注（可选）', counterText: ''),
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(_error!, style: TextStyle(fontSize: 11, color: scheme.error)),
                ],
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    if (_isEditing) ...<Widget>[
                      TextButton.icon(
                        onPressed: _delete,
                        icon: Icon(Icons.delete_outline_rounded, size: 17, color: scheme.error),
                        label: Text('删除', style: TextStyle(color: scheme.error)),
                      ),
                      IconButton(
                        tooltip: '加入系统日历',
                        onPressed: _addToCalendar,
                        icon: Icon(
                          Icons.event_available_outlined,
                          size: 19,
                          color: scheme.onSurfaceVariant,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 4),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(90, 42),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      ),
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = '先填写课程名称');
      return;
    }
    if (_weeks.isEmpty) {
      setState(() => _error = '至少选择一个上课周次');
      return;
    }
    final weeks = _weeks.toList()..sort();
    if (_isEditing) {
      widget.store.update(
        widget.course!.copyWith(
          name: _name.text.trim(),
          teacher: _teacher.text.trim(),
          location: _location.text.trim(),
          note: _note.text.trim(),
          weekday: _weekday,
          startSection: _startSection,
          endSection: _endSection,
          weeks: weeks,
        ),
      );
    } else {
      widget.store.add(
        name: _name.text.trim(),
        teacher: _teacher.text.trim(),
        location: _location.text.trim(),
        note: _note.text.trim(),
        weekday: _weekday,
        startSection: _startSection,
        endSection: _endSection,
        weeks: weeks,
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _addToCalendar() async {
    final course = widget.course;
    if (course == null) return;
    final occurrence = widget.store.nextOccurrence(course);
    if (occurrence == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('本学期没有后续课程了')),
      );
      return;
    }
    try {
      final ok = await CalendarBridge.addEvent(
        title: course.name,
        location: course.location,
        description: [
          '第${course.startSection}-${course.endSection}节 · ${course.weeksLabel}',
          if (course.teacher.isNotEmpty) '教师：${course.teacher}',
          if (course.note.isNotEmpty) course.note,
        ].join('\n'),
        start: occurrence.start,
        end: occurrence.end,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? '已打开系统日历，请确认保存' : '没有找到可用的日历应用')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加入日历失败：$error')),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除这门课？'),
        content: Text('「${widget.course!.name}」将从课表中移除。'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.store.delete(widget.course!.id);
    Navigator.of(context).pop();
  }

  static String _weekdayName(int weekday) {
    const names = <String>['一', '二', '三', '四', '五', '六', '日'];
    return '周${names[weekday - 1]}';
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SectionDropdown extends StatelessWidget {
  const _SectionDropdown({
    required this.label,
    required this.value,
    required this.count,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int count;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Label(label),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              items: List<DropdownMenuItem<int>>.generate(
                count,
                (index) => DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text('第 ${index + 1} 节'),
                ),
              ),
              onChanged: (selected) {
                if (selected != null) onChanged(selected);
              },
            ),
          ),
        ),
      ],
    );
  }
}
