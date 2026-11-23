import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../app_info.dart';
import '../state/settings_store.dart';
import '../state/task_store.dart';
import 'about_screen.dart';
import 'privacy_screen.dart';

/// 设置页：主题、显示、数据管理、关于。
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.store,
    required this.settings,
  });

  final TaskStore store;
  final SettingsStore settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[store, settings]),
      builder: (context, _) {
        final scheme = Theme.of(context).colorScheme;
        return Scaffold(
          appBar: AppBar(title: const Text('设置')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: <Widget>[
              _SettingsSection(
                title: '外观',
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.brightness_6_outlined,
                          size: 20,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            '主题',
                            style: TextStyle(
                              fontSize: 13.5,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        _ThemeModeSelector(
                          value: settings.themeMode,
                          onChanged: settings.setThemeMode,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 48),
                  SwitchListTile(
                    value: settings.showCompleted,
                    onChanged: settings.setShowCompleted,
                    title: Text(
                      '显示已完成任务',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: scheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      '关闭时，已勾选的任务会从象限中隐藏',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    secondary: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  const Divider(height: 1, indent: 48),
                  ListTile(
                    onTap: settings.resetDragTip,
                    leading: Icon(
                      Icons.touch_app_outlined,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    title: Text(
                      '重新显示拖动提示',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: scheme.onSurface,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ],
              ),
              _SettingsSection(
                title: '数据',
                children: <Widget>[
                  _SettingsTile(
                    icon: Icons.ios_share_rounded,
                    title: '导出数据',
                    subtitle: '复制 JSON 到剪贴板，共 ${store.all.length} 条任务',
                    onTap: () => _export(context),
                  ),
                  const Divider(height: 1, indent: 48),
                  _SettingsTile(
                    icon: Icons.file_download_outlined,
                    title: '导入数据',
                    subtitle: '粘贴之前导出的 JSON，同 ID 覆盖',
                    onTap: () => _import(context),
                  ),
                  const Divider(height: 1, indent: 48),
                  _SettingsTile(
                    icon: Icons.cleaning_services_outlined,
                    title: '清除已完成',
                    subtitle: '当前有 ${store.completedCount} 条已完成任务',
                    onTap: store.completedCount == 0
                        ? null
                        : () => _clearCompleted(context),
                  ),
                  const Divider(height: 1, indent: 48),
                  _SettingsTile(
                    icon: Icons.delete_forever_outlined,
                    title: '清空所有任务',
                    subtitle: '删除本机全部任务，无法恢复',
                    danger: true,
                    onTap: store.all.isEmpty ? null : () => _clearAll(context),
                  ),
                ],
              ),
              _SettingsSection(
                title: '关于',
                children: <Widget>[
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: '关于四象限清单',
                    subtitle: AppInfo.tagline,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutScreen(),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 48),
                  _SettingsTile(
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
                  _SettingsTile(
                    icon: Icons.code_rounded,
                    title: '开源地址',
                    subtitle: AppInfo.repoUrl,
                    onTap: () => _copy(
                      context,
                      AppInfo.repoUrl,
                      '已复制 GitHub 地址',
                    ),
                  ),
                  const Divider(height: 1, indent: 48),
                  _SettingsTile(
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
                  ListTile(
                    leading: Icon(
                      Icons.tag_rounded,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    title: Text(
                      '版本',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: scheme.onSurface,
                      ),
                    ),
                    trailing: Text(
                      'v${AppInfo.version}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    dense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '数据只保存在本机 · 无广告 · 无统计',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _export(BuildContext context) async {
    if (store.all.isEmpty) {
      _toast(context, '还没有任务可以导出');
      return;
    }
    await Clipboard.setData(ClipboardData(text: store.exportJson()));
    if (!context.mounted) return;
    _toast(context, '已复制 ${store.all.length} 条任务到剪贴板');
  }

  Future<void> _import(BuildContext context) async {
    final raw = await showDialog<String>(
      context: context,
      builder: (_) => const _ImportDialog(),
    );
    if (raw == null || raw.trim().isEmpty || !context.mounted) return;
    try {
      final count = store.importJson(raw);
      if (!context.mounted) return;
      _toast(context, '已导入 $count 条任务');
    } on FormatException catch (error) {
      if (!context.mounted) return;
      _toast(context, '导入失败：${error.message}');
    } catch (_) {
      if (!context.mounted) return;
      _toast(context, '导入失败：请检查 JSON 格式');
    }
  }

  Future<void> _clearCompleted(BuildContext context) async {
    final confirmed = await _confirm(
      context,
      title: '清除已完成任务？',
      message: '将删除 ${store.completedCount} 条已完成任务，无法恢复。',
      confirmText: '清除',
    );
    if (confirmed != true || !context.mounted) return;
    store.clearCompleted();
    _toast(context, '已清除完成的任务');
  }

  Future<void> _clearAll(BuildContext context) async {
    final confirmed = await _confirm(
      context,
      title: '清空所有任务？',
      message: '本机保存的 ${store.all.length} 条任务将全部删除，无法恢复。'
          '建议先导出备份。',
      confirmText: '清空',
    );
    if (confirmed != true || !context.mounted) return;
    store.clearAll();
    _toast(context, '已清空所有任务');
  }

  Future<bool?> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
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
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  Future<void> _copy(BuildContext context, String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    _toast(context, message);
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 7),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ),
          ),
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
                for (var i = 0; i < children.length; i++) ...<Widget>[
                  children[i],
                  if (i != children.length - 1)
                    Divider(
                      height: 1,
                      indent: 48,
                      endIndent: 14,
                      color: scheme.outlineVariant.withValues(alpha: 0.55),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = danger ? scheme.error : scheme.onSurfaceVariant;
    return ListTile(
      onTap: onTap,
      enabled: onTap != null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14),
      leading: Icon(icon, size: 20, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13.5,
          color: danger ? scheme.error : scheme.onSurface,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
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

class _ImportDialog extends StatefulWidget {
  const _ImportDialog();

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('导入数据'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '把之前导出的 JSON 粘贴到下面。任务会与现有数据合并，'
              '相同 ID 的任务会被覆盖。',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 6,
              maxLines: 10,
              autofocus: true,
              style: const TextStyle(fontSize: 11, height: 1.4),
              decoration: const InputDecoration(
                hintText: '{ "tasks": [ ... ] }',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('导入'),
        ),
      ],
    );
  }
}

/// 轻量的三段式主题选择器，避免 SegmentedButton 在不同字体环境下出现样式差异。
class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  static const List<(ThemeMode, String)> _options = <(ThemeMode, String)>[
    (ThemeMode.system, '跟随系统'),
    (ThemeMode.light, '浅色'),
    (ThemeMode.dark, '深色'),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _options.map(((ThemeMode, String) option) {
          final selected = option.$1 == value;
          return InkWell(
            onTap: () => onChanged(option.$1),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? scheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                option.$2,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected
                      ? scheme.onPrimary
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

