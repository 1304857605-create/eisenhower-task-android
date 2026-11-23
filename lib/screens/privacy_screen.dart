import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../app_info.dart';

/// 应用内隐私政策，与仓库 PRIVACY.md / docs/privacy.html 保持一致。
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const String _updatedAt = '2026年11月22日';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
        actions: <Widget>[
          IconButton(
            tooltip: '复制在线链接',
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(text: AppInfo.privacyUrl),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已复制隐私政策链接')),
              );
            },
            icon: const Icon(Icons.link_rounded, size: 20),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Text(
            '生效日期：$_updatedAt',
            style: TextStyle(
              fontSize: 11,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 18),
          const _Paragraph(
            '「${AppInfo.name}」是一款无广告、零权限、纯本地的四象限待办应用。'
            '我们不需要你的账号，也不想知道你是谁。',
          ),
          const _Section(
            title: '一、我们收集哪些信息',
            body: '不收集任何个人信息。应用没有网络权限，无法向任何服务器发送数据；'
                '没有账号体系，不需要手机号、邮箱或第三方登录。',
          ),
          const _Section(
            title: '二、你的数据保存在哪里',
            body: '你创建的任务、备注、截止日期和设置，只保存在本机的应用私有存储中。'
                '其他应用无法读取，我们同样无法访问。卸载应用或在系统设置中清除应用数据，'
                '这些内容会被一并删除。',
          ),
          const _Section(
            title: '三、权限说明',
            body: '应用不声明任何 Android 权限，不读取通讯录、位置、相册、麦克风、相机，'
                '也不发送通知。因此不会出现「要权限才给用」的情况。',
          ),
          const _Section(
            title: '四、第三方组件',
            body: '应用基于 Flutter 构建，仅使用官方本地存储插件 shared_preferences。'
                '这些组件不包含广告、统计或崩溃上报 SDK，不会收集或上传你的数据。',
          ),
          const _Section(
            title: '五、导出与导入',
            body: '导出功能由你主动触发，内容只会写入系统剪贴板，方便你粘贴到自己的'
                '备忘录或网盘中备份；导入同样由你主动粘贴完成。整个过程不经过网络。',
          ),
          const _Section(
            title: '六、未成年人保护',
            body: '应用不收集任何个人信息，也不含广告或付费内容，未成年人可以在监护人'
                '指导下放心使用。',
          ),
          const _Section(
            title: '七、政策更新',
            body: '如果未来功能变化导致本政策调整，我们会更新应用内和仓库中的政策文本，'
                '并标注新的生效日期。当前版本不会发生数据上传行为。',
          ),
          const _Section(
            title: '八、联系我们',
            body: '如有疑问或建议，欢迎通过邮箱 ${AppInfo.contactEmail} 联系，'
                '或在 GitHub 仓库提交 Issue。',
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.public_rounded,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppInfo.privacyUrl,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: scheme.onSurfaceVariant,
                    ),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.75,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        height: 1.8,
        color: scheme.onSurface,
      ),
    );
  }
}
