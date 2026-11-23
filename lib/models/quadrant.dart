import 'package:material_ui/material_ui.dart';

/// 四象限：以「重要 / 紧急」两个维度把待办分成四类。
enum Quadrant {
  urgentImportant(
    label: '重要且紧急',
    action: '马上做',
    storageKey: 'urgent_important',
    color: Color(0xFFE5484D),
  ),
  importantNotUrgent(
    label: '重要不紧急',
    action: '计划做',
    storageKey: 'important_not_urgent',
    color: Color(0xFF3B82F6),
  ),
  urgentNotImportant(
    label: '紧急不重要',
    action: '委托做',
    storageKey: 'urgent_not_important',
    color: Color(0xFFE8A33D),
  ),
  notUrgentNotImportant(
    label: '不重要不紧急',
    action: '可以不做',
    storageKey: 'not_urgent_not_important',
    color: Color(0xFF8B8D98),
  );

  const Quadrant({
    required this.label,
    required this.action,
    required this.storageKey,
    required this.color,
  });

  final String label;
  final String action;
  final String storageKey;
  final Color color;

  String get description => switch (this) {
        Quadrant.urgentImportant => '先处理，别拖延',
        Quadrant.importantNotUrgent => '留出时间，长期投入',
        Quadrant.urgentNotImportant => '尽快处理或交给别人',
        Quadrant.notUrgentNotImportant => '有空再说，学会放下',
      };

  static Quadrant fromStorage(String? key, {Quadrant fallback = Quadrant.urgentImportant}) {
    for (final quadrant in Quadrant.values) {
      if (quadrant.storageKey == key) return quadrant;
    }
    return fallback;
  }
}
