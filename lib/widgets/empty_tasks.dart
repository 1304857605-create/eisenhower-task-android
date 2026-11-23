import 'package:material_ui/material_ui.dart';

import '../models/quadrant.dart';

/// 象限卡片/详情页的空状态，尺寸克制，不抢视觉重心。
class EmptyTasks extends StatelessWidget {
  const EmptyTasks({
    super.key,
    required this.quadrant,
    this.compact = true,
  });

  final Quadrant quadrant;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = quadrant.color.withValues(alpha: 0.75);
    if (compact) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.check_circle_outline_rounded, size: 22, color: color),
              const SizedBox(height: 6),
              Text(
                '这里还空着',
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: quadrant.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 30,
                color: quadrant.color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '「${quadrant.label}」还没有任务',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '想到什么就先记下来，再去判断轻重缓急。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
