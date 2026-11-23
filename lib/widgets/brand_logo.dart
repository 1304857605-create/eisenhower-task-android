import 'package:material_ui/material_ui.dart';

import '../models/quadrant.dart';

/// 用代码画的小 Logo：2×2 圆角方块。避免额外图片资源。
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 72, this.radius = 18});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final gap = size * 0.075;
    final tile = (size - 2 * gap) / 2;
    final tileRadius = BorderRadius.circular(size * 0.09);
    Widget cell(Quadrant quadrant) {
      return Container(
        width: tile,
        height: tile,
        decoration: BoxDecoration(
          color: quadrant.color,
          borderRadius: tileRadius,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(gap / 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              cell(Quadrant.urgentImportant),
              SizedBox(width: gap),
              cell(Quadrant.importantNotUrgent),
            ],
          ),
          SizedBox(height: gap),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              cell(Quadrant.urgentNotImportant),
              SizedBox(width: gap),
              cell(Quadrant.notUrgentNotImportant),
            ],
          ),
        ],
      ),
    );
  }
}
