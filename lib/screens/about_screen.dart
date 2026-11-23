import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../app_info.dart';
import '../models/quadrant.dart';
import '../widgets/brand_logo.dart';
import 'privacy_screen.dart';

/// 关于页：版本、理念、链接。
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          const SizedBox(height: 10),
          const Center(
            child: BrandLogo(size: 84, radius: 22),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              AppInfo.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: scheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${AppInfo.tagline} · v${AppInfo.version}',
              style: TextStyle(
                fontSize: 11.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            '把待办按「重要」和「紧急」分成四格，先做该做的，'
            '放下可以放下的。没有广告、没有账号、不联网，打开就能用。',
            style: TextStyle(
              fontSize: 13,
              height: 1.75,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 22),
          _FeatureRow(
            icon: Icons.grid_view_rounded,
            color: Quadrant.urgentImportant.color,
            title: '四象限分类',
            subtitle: '重要 / 紧急两个维度，一屏看清轻重缓急',
          ),
          _FeatureRow(
            icon: Icons.drag_indicator_rounded,
            color: Quadrant.importantNotUrgent.color,
            title: '拖动换象限',
            subtitle: '长按任务卡片，拖到其他象限即可重新分类',
          ),
          _FeatureRow(
            icon: Icons.dark_mode_outlined,
            color: Quadrant.urgentNotImportant.color,
            title: '深色模式',
            subtitle: '跟随系统，或手动选择浅色 / 深色',
          ),
          _FeatureRow(
            icon: Icons.lock_outline_rounded,
            color: Quadrant.notUrgentNotImportant.color,
            title: '数据在你手里',
            subtitle: '只保存在本机，支持 JSON 导出与导入',
          ),
          const SizedBox(height: 18),
          Material(
            color: scheme.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: scheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Column(
              children: <Widget>[
                _LinkTile(
                  icon: Icons.code_rounded,
                  title: '开源地址',
                  subtitle: 'GitHub · ${AppInfo.license}',
                  onTap: () => _copy(
                    context,
                    AppInfo.repoUrl,
                    '已复制 GitHub 地址',
                  ),
                ),
                const Divider(height: 1, indent: 48),
                _LinkTile(
                  icon: Icons.privacy_tip_outlined,
                  title: '隐私政策',
                  subtitle: '不收集任何个人信息',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacyScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 48),
                _LinkTile(
                  icon: Icons.description_outlined,
                  title: '开源许可',
                  subtitle: 'Flutter 与第三方组件许可',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppInfo.name,
                    applicationVersion: AppInfo.version,
                    applicationLegalese:
                        '© 2026 ${AppInfo.name} · ${AppInfo.license}',
                  ),
                ),
                const Divider(height: 1, indent: 48),
                _LinkTile(
                  icon: Icons.mail_outline_rounded,
                  title: '联系我',
                  subtitle: AppInfo.contactEmail,
                  onTap: () => _copy(
                    context,
                    AppInfo.contactEmail,
                    '已复制邮箱',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© 2026 ${AppInfo.name} · ${AppInfo.license}\n'
              '因为简单，所以长久。',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.6,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      dense: true,
    );
  }
}
