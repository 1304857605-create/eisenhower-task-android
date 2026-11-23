import 'package:material_ui/material_ui.dart';

import '../course/state/course_settings_store.dart';
import '../quotes/quote_store.dart';

/// 首页顶部的每日一句。默认显示，用户可在设置里关闭或开启联网更新。
class DailyQuoteCard extends StatelessWidget {
  const DailyQuoteCard({
    super.key,
    required this.quoteStore,
    required this.settings,
  });

  final QuoteStore quoteStore;
  final CourseSettingsStore settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final quote = quoteStore.todayQuote;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(13, 9, 8, 9),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                Icons.format_quote_rounded,
                size: 15,
                color: scheme.primary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    quote.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    quote.attribution,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
            ),
            if (settings.quoteOnlineEnabled)
              IconButton(
                tooltip: '换一句',
                onPressed: quoteStore.isLoading
                    ? null
                    : () => quoteStore.refreshOnline(),
                icon: quoteStore.isLoading
                    ? SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        size: 15,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.65),
                      ),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}
