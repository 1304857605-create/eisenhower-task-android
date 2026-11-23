import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../models/quadrant.dart';
import '../models/task.dart';
import '../state/settings_store.dart';
import '../state/task_store.dart';
import '../widgets/empty_tasks.dart';
import '../widgets/task_editor_sheet.dart';
import '../widgets/task_tile.dart';

/// 单个象限的完整列表。
class QuadrantScreen extends StatelessWidget {
  const QuadrantScreen({
    super.key,
    required this.quadrant,
    required this.store,
    required this.settings,
  });

  final Quadrant quadrant;
  final TaskStore store;
  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[store, settings]),
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        final tasks = store.tasksFor(quadrant);
        final active = tasks.where((task) => !task.completed).toList();
        final completed = tasks.where((task) => task.completed).toList();
        final showCompleted = settings.showCompleted;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: Row(
              children: <Widget>[
                Container(
                  width: 4,
                  height: 26,
                  decoration: BoxDecoration(
                    color: quadrant.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      quadrant.label,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quadrant.description,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w400,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                tooltip: showCompleted ? '隐藏已完成' : '显示已完成',
                onPressed: () =>
                    settings.setShowCompleted(!settings.showCompleted),
                icon: Icon(
                  showCompleted
                      ? Icons.visibility_rounded
                      : Icons.visibility_outlined,
                  size: 20,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            top: false,
            child: active.isEmpty && (!showCompleted || completed.isEmpty)
                ? EmptyTasks(quadrant: quadrant, compact: false)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
                    children: <Widget>[
                      _SectionHeader(
                        title: '进行中',
                        count: active.length,
                        color: quadrant.color,
                      ),
                      const SizedBox(height: 8),
                      if (active.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            '进行中的任务都处理完了。',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      else
                        ..._taskList(context, active, quadrant),
                      if (completed.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 18),
                        _SectionHeader(
                          title: '已完成',
                          count: completed.length,
                          color: scheme.onSurfaceVariant,
                          trailing: showCompleted
                              ? null
                              : TextButton(
                                  onPressed: () =>
                                      settings.setShowCompleted(true),
                                  style: TextButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    minimumSize: const Size(0, 30),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                  ),
                                  child: const Text(
                                    '显示',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                        ),
                        if (showCompleted) ...<Widget>[
                          const SizedBox(height: 8),
                          ..._taskList(context, completed, quadrant),
                        ],
                      ],
                    ],
                  ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openEditor(context),
            tooltip: '新建任务',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.add_rounded, size: 24),
          ),
        );
      },
    );
  }

  List<Widget> _taskList(
    BuildContext context,
    List<Task> tasks,
    Quadrant quadrant,
  ) {
    return tasks.map((task) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Dismissible(
          key: ValueKey<String>('${quadrant.storageKey}-${task.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: Theme.of(context).colorScheme.error,
              size: 20,
            ),
          ),
          onDismissed: (_) {
            final removed = task;
            store.delete(task.id);
            HapticFeedback.mediumImpact();
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('已删除「${removed.title}」'),
                  action: SnackBarAction(
                    label: '撤销',
                    onPressed: () => store.restore(removed),
                  ),
                ),
              );
          },
          child: TaskTile(
            task: task,
            compact: false,
            onTap: () => _openEditor(context, task: task),
            onToggle: () => store.toggleCompleted(task.id),
          ),
        ),
      );
    }).toList(growable: false);
  }

  Future<void> _openEditor(BuildContext context, {Task? task}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => TaskEditorSheet(
        store: store,
        task: task,
        initialQuadrant: quadrant,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
    this.trailing,
  });

  final String title;
  final int count;
  final Color color;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}
