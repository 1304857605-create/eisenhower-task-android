import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../models/quadrant.dart';
import '../models/task.dart';
import '../state/settings_store.dart';
import '../state/task_store.dart';
import 'empty_tasks.dart';
import 'task_tile.dart';

/// 首页的一张象限卡片：标题、计数、任务列表、添加入口，并接收拖拽。
class QuadrantCard extends StatelessWidget {
  const QuadrantCard({
    super.key,
    required this.quadrant,
    required this.store,
    required this.settings,
    required this.onOpen,
    required this.onEdit,
    required this.onAdd,
  });

  final Quadrant quadrant;
  final TaskStore store;
  final SettingsStore settings;
  final VoidCallback onOpen;
  final ValueChanged<Task> onEdit;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final tasks = store.tasksFor(quadrant);
    final active = tasks.where((task) => !task.completed).toList();
    final completed = tasks.where((task) => task.completed).toList();
    final visible = settings.showCompleted
        ? <Task>[...active, ...completed]
        : active;
    final accent = quadrant.color;

    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) =>
          details.data.quadrant != quadrant && !details.data.completed,
      onAcceptWithDetails: (details) {
        store.moveToQuadrant(details.data.id, quadrant);
        HapticFeedback.lightImpact();
        ScaffoldMessenger.maybeOf(context)
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('已移到「${quadrant.label}」'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: '撤销',
                onPressed: () => store.moveToQuadrant(
                  details.data.id,
                  details.data.quadrant,
                ),
              ),
            ),
          );
      },
      builder: (context, candidate, rejected) {
        final highlighted = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.11 : 0.055),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: highlighted
                  ? accent.withValues(alpha: 0.85)
                  : accent.withValues(alpha: isDark ? 0.24 : 0.16),
              width: highlighted ? 1.6 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Header(
                  quadrant: quadrant,
                  count: store.activeCountFor(quadrant),
                  onTap: onOpen,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: visible.isEmpty
                        ? EmptyTasks(quadrant: quadrant)
                        : ListView.separated(
                            padding: const EdgeInsets.only(top: 2, bottom: 4),
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            itemCount: visible.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 6),
                            itemBuilder: (context, index) {
                              final task = visible[index];
                              final tile = TaskTile(
                                task: task,
                                compact: true,
                                onTap: () => onEdit(task),
                                onToggle: () =>
                                    store.toggleCompleted(task.id),
                              );
                              if (task.completed) return tile;
                              return LongPressDraggable<Task>(
                                data: task,
                                dragAnchorStrategy: childDragAnchorStrategy,
                                hapticFeedbackOnStart: true,
                                feedback: _TaskDragFeedback(task: task),
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: tile,
                                ),
                                child: tile,
                              );
                            },
                          ),
                  ),
                ),
                _Footer(
                  quadrant: quadrant,
                  hiddenCompleted: settings.showCompleted
                      ? 0
                      : completed.length,
                  onAdd: onAdd,
                  onShowCompleted: () =>
                      settings.setShowCompleted(!settings.showCompleted),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.quadrant,
    required this.count,
    required this.onTap,
  });

  final Quadrant quadrant;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 11, 11, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 3,
              height: 33,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: quadrant.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          quadrant.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      _CountBadge(
                        count: count,
                        color: quadrant.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    quadrant.action,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.2,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final empty = count == 0;
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 19,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: empty
            ? scheme.surfaceContainerHighest.withValues(alpha: 0.55)
            : color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(9.5),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: empty
              ? scheme.onSurfaceVariant.withValues(alpha: 0.7)
              : color,
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.quadrant,
    required this.hiddenCompleted,
    required this.onAdd,
    required this.onShowCompleted,
  });

  final Quadrant quadrant;
  final int hiddenCompleted;
  final VoidCallback onAdd;
  final VoidCallback onShowCompleted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 0, 6, 4),
      child: Row(
        children: <Widget>[
          TextButton.icon(
            onPressed: onAdd,
            icon: Icon(Icons.add_rounded, size: 15, color: quadrant.color),
            label: Text(
              '添加',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: quadrant.color,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: quadrant.color,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 28),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const Spacer(),
          if (hiddenCompleted > 0)
            GestureDetector(
              onTap: onShowCompleted,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                child: Text(
                  '另有 $hiddenCompleted 项已完成',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskDragFeedback extends StatelessWidget {
  const _TaskDragFeedback({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task.quadrant.color.withValues(alpha: 0.5),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: task.quadrant.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
