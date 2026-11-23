import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../course/state/course_settings_store.dart';
import '../course/state/course_store.dart';
import '../models/quadrant.dart';
import '../models/task.dart';
import '../quotes/daily_quote_card.dart';
import '../quotes/quote_store.dart';
import '../state/settings_store.dart';
import '../state/task_store.dart';
import '../utils/date_text.dart';
import '../widgets/quadrant_card.dart';
import '../widgets/task_editor_sheet.dart';
import 'about_screen.dart';
import 'quadrant_screen.dart';
import 'settings_screen.dart';

/// 首页：2×2 四象限总览。
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.store,
    required this.settings,
    required this.courseSettings,
    required this.courseStore,
    required this.quoteStore,
  });

  final TaskStore store;
  final SettingsStore settings;
  final CourseSettingsStore courseSettings;
  final CourseStore courseStore;
  final QuoteStore quoteStore;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        store,
        settings,
        courseSettings,
        quoteStore,
      ]),
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 66,
            title: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('四象限清单'),
                const SizedBox(height: 2),
                Text(
                  DateText.homeDate(DateTime.now()),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                tooltip: '设置',
                onPressed: () => _openSettings(context),
                icon: const Icon(Icons.settings_outlined, size: 21),
              ),
              PopupMenuButton<String>(
                tooltip: '更多',
                icon: const Icon(Icons.more_vert_rounded, size: 21),
                onSelected: (value) {
                  if (value == 'toggle_completed') {
                    settings.setShowCompleted(!settings.showCompleted);
                  } else if (value == 'clear_completed') {
                    _clearCompleted(context);
                  } else if (value == 'about') {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutScreen(),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'toggle_completed',
                    child: Row(
                      children: <Widget>[
                        Icon(
                          settings.showCompleted
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          settings.showCompleted ? '隐藏已完成' : '显示已完成',
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'clear_completed',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.cleaning_services_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('清除已完成'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'about',
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.info_outline_rounded, size: 18),
                        SizedBox(width: 10),
                        Text('关于'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 12, 72),
              child: Column(
                children: <Widget>[
                  if (courseSettings.quoteVisible)
                    DailyQuoteCard(
                      quoteStore: quoteStore,
                      settings: courseSettings,
                    ),
                  if (settings.showDragTip) _DragTipBanner(settings: settings),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(child: _card(context, Quadrant.urgentImportant)),
                              const SizedBox(width: 10),
                              Expanded(child: _card(context, Quadrant.importantNotUrgent)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(child: _card(context, Quadrant.urgentNotImportant)),
                              const SizedBox(width: 10),
                              Expanded(child: _card(context, Quadrant.notUrgentNotImportant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'home_add_task',
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.add_rounded, size: 22),
            label: const Text(
              '新任务',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            highlightElevation: 4,
          ),
        );
      },
    );
  }

  Widget _card(BuildContext context, Quadrant quadrant) {
    return QuadrantCard(
      quadrant: quadrant,
      store: store,
      settings: settings,
      onOpen: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => QuadrantScreen(
            quadrant: quadrant,
            store: store,
            settings: settings,
          ),
        ),
      ),
      onEdit: (task) => _openEditor(context, task: task),
      onAdd: () => _openEditor(context, quadrant: quadrant),
    );
  }

  Future<void> _openEditor(
    BuildContext context, {
    Task? task,
    Quadrant quadrant = Quadrant.importantNotUrgent,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => TaskEditorSheet(
        store: store,
        task: task,
        initialQuadrant: task?.quadrant ?? quadrant,
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          store: store,
          settings: settings,
          courseStore: courseStore,
          courseSettings: courseSettings,
          quoteStore: quoteStore,
        ),
      ),
    );
  }

  Future<void> _clearCompleted(BuildContext context) async {
    if (store.completedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('还没有已完成的任务')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除已完成任务？'),
        content: Text('将删除 ${store.completedCount} 条已完成任务，无法恢复。'),
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
            child: const Text('清除'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    store.clearCompleted();
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已清除完成的任务')),
    );
  }
}

class _DragTipBanner extends StatelessWidget {
  const _DragTipBanner({required this.settings});

  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 5, 4, 5),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.touch_app_outlined,
              size: 15,
              color: scheme.primary.withValues(alpha: 0.85),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                '小提示：长按任务卡片，可以拖到其他象限',
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            IconButton(
              onPressed: settings.dismissDragTip,
              icon: const Icon(Icons.close_rounded, size: 15),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              padding: EdgeInsets.zero,
              tooltip: '不再提示',
            ),
          ],
        ),
      ),
    );
  }
}
