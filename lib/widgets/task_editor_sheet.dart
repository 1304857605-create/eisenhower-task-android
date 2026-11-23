import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../models/quadrant.dart';
import '../models/task.dart';
import '../state/task_store.dart';
import '../utils/date_text.dart';

/// 新建 / 编辑待办的面板。从底部弹出，保存后自动关闭。
class TaskEditorSheet extends StatefulWidget {
  const TaskEditorSheet({
    super.key,
    required this.store,
    this.task,
    this.initialQuadrant = Quadrant.urgentImportant,
  });

  final TaskStore store;
  final Task? task;
  final Quadrant initialQuadrant;

  bool get isEditing => task != null;

  @override
  State<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends State<TaskEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late Quadrant _quadrant;
  DateTime? _dueDate;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _noteController = TextEditingController(text: task?.note ?? '');
    _quadrant = task?.quadrant ?? widget.initialQuadrant;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = '先写下要做的事');
      return;
    }

    final task = widget.task;
    if (task == null) {
      widget.store.add(
        title: title,
        note: _noteController.text,
        quadrant: _quadrant,
        dueDate: _dueDate,
      );
    } else {
      widget.store.update(
        task.copyWith(
          title: title,
          note: _noteController.text.trim(),
          quadrant: _quadrant,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
        ),
      );
    }
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 10),
      helpText: '选择截止日期',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked == null) return;
    setState(() {
      _dueDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _delete() async {
    final task = widget.task;
    if (task == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除这条任务？'),
        content: Text('「${task.title}」将被删除，删除后无法恢复。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    widget.store.delete(task.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
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
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.isEditing ? '编辑任务' : '新建任务',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      visualDensity: VisualDensity.compact,
                      tooltip: '关闭',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _titleController,
                  autofocus: !widget.isEditing,
                  maxLength: 80,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: '要做什么？',
                    counterText: '',
                    errorText: _titleError,
                  ),
                  onChanged: (_) {
                    if (_titleError != null) {
                      setState(() => _titleError = null);
                    }
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    hintText: '备注（可选）',
                    counterText: '',
                  ),
                ),
                const SizedBox(height: 18),
                _SectionLabel(text: '放进哪个象限'),
                const SizedBox(height: 8),
                _QuadrantPicker(
                  selected: _quadrant,
                  onChanged: (quadrant) => setState(() => _quadrant = quadrant),
                ),
                const SizedBox(height: 16),
                _SectionLabel(text: '截止日期'),
                const SizedBox(height: 8),
                _DateField(
                  date: _dueDate,
                  onTap: _pickDate,
                  onClear: () => setState(() => _dueDate = null),
                ),
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    if (widget.isEditing)
                      TextButton.icon(
                        onPressed: _delete,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: scheme.error,
                        ),
                        label: Text(
                          '删除',
                          style: TextStyle(color: scheme.error),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 6),
                    FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(96, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(widget.isEditing ? '保存' : '添加'),
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
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Theme.of(context)
            .colorScheme
            .onSurfaceVariant
            .withValues(alpha: 0.9),
      ),
    );
  }
}

class _QuadrantPicker extends StatelessWidget {
  const _QuadrantPicker({required this.selected, required this.onChanged});

  final Quadrant selected;
  final ValueChanged<Quadrant> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final width = (constraints.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: Quadrant.values.map((quadrant) {
            final isSelected = quadrant == selected;
            return SizedBox(
              width: width,
              child: InkWell(
                onTap: () => onChanged(quadrant),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 140),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? quadrant.color.withValues(alpha: 0.13)
                        : scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? quadrant.color.withValues(alpha: 0.8)
                          : scheme.outlineVariant.withValues(alpha: 0.7),
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: quadrant.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              quadrant.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              quadrant.action,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 9.5,
                                color: scheme.onSurfaceVariant
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          size: 15,
                          color: quadrant.color,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.onTap,
    required this.onClear,
  });

  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasDate = date != null;
    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.event_rounded,
                size: 17,
                color: hasDate ? scheme.primary : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  hasDate ? DateText.fullDate(date!) : '不设置截止日期',
                  style: TextStyle(
                    fontSize: 13,
                    color: hasDate
                        ? scheme.onSurface
                        : scheme.onSurfaceVariant.withValues(alpha: 0.75),
                  ),
                ),
              ),
              if (hasDate)
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 16),
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(
                    minWidth: 30,
                    minHeight: 30,
                  ),
                  padding: EdgeInsets.zero,
                  tooltip: '清除日期',
                )
              else
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
