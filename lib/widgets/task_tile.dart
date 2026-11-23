import 'package:material_ui/material_ui.dart';

import '../models/task.dart';
import '../utils/date_text.dart';

/// 待办条目。首页用紧凑版，象限详情页用完整版。
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    this.compact = true,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dueColor = task.completed
        ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
        : DateText.isOverdue(task.dueDate ?? DateTime(2100))
            ? const Color(0xFFD93A3F)
            : scheme.onSurfaceVariant;

    final titleStyle = TextStyle(
      fontSize: compact ? 13 : 14.5,
      height: 1.3,
      fontWeight: FontWeight.w500,
      color: task.completed
          ? scheme.onSurfaceVariant.withValues(alpha: 0.65)
          : scheme.onSurface,
      decoration: task.completed ? TextDecoration.lineThrough : null,
      decorationColor: scheme.onSurfaceVariant.withValues(alpha: 0.7),
    );

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _RoundCheckbox(
          checked: task.completed,
          onTap: onToggle,
          color: scheme.primary,
        ),
        SizedBox(width: compact ? 7 : 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                task.title,
                maxLines: compact ? 2 : 3,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
              if (!compact && task.hasNote) ...<Widget>[
                const SizedBox(height: 3),
                Text(
                  task.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                  ),
                ),
              ],
              if (task.dueDate != null) ...<Widget>[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.event_rounded, size: 11, color: dueColor),
                    const SizedBox(width: 3),
                    Text(
                      DateText.compactDate(task.dueDate!),
                      style: TextStyle(
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w500,
                        color: dueColor,
                      ),
                    ),
                    if (!task.completed &&
                        DateText.isOverdue(task.dueDate!)) ...<Widget>[
                      const SizedBox(width: 4),
                      Text(
                        '已逾期',
                        style: TextStyle(
                          fontSize: compact ? 9 : 10,
                          color: dueColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
        if (!compact)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.45),
            ),
          ),
      ],
    );

    return Semantics(
      button: true,
      checked: task.completed,
      label: '${task.title}${task.completed ? '，已完成' : ''}',
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(compact ? 11 : 14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(compact ? 11 : 14),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 7 : 12,
              vertical: compact ? 7 : 11,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(compact ? 11 : 14),
              border: Border.all(
                color: scheme.outlineVariant.withValues(
                  alpha: scheme.brightness == Brightness.dark ? 0.55 : 0.8,
                ),
              ),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _RoundCheckbox extends StatelessWidget {
  const _RoundCheckbox({
    required this.checked,
    required this.onTap,
    required this.color,
  });

  final bool checked;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      checked: checked,
      label: checked ? '标记为未完成' : '标记为已完成',
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        containedInkWell: false,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: checked ? color : Colors.transparent,
              border: Border.all(
                color: checked
                    ? color
                    : scheme.onSurfaceVariant.withValues(alpha: 0.55),
                width: 1.5,
              ),
            ),
            child: checked
                ? Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: scheme.onPrimary,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
