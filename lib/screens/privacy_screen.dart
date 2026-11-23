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
            '「${AppInfo.name}」是一款无广告的四象限待办与课表应用。'
            '我们不需要你的账号，也不收集你的待办内容；网络和通知都是可选能力。',
          ),
          const _Section(
            title: '一、我们收集哪些信息',
            body: '不收集、不出售、不共享任何个人信息。待办、课表、备注和设置只保存在本机。'
                '只有在你主动开启“联网更新金句”时，应用才会请求今日诗词 API：'
                '请求中不包含你的任务、课表、账号或身份信息，但对方服务器会接收到常规网络信息'
                '（如 IP 地址）。关闭该开关后应用不会发起任何网络请求。',
          ),
          const _Section(
            title: '二、你的数据保存在哪里',
            body: '你创建的任务、课程、备注、周次和设置，只保存在本机的应用私有存储中。'
                '其他应用无法读取，我们同样无法访问。卸载应用或在系统设置中清除应用数据，'
                '这些内容会被一并删除。',
          ),
          const _Section(
            title: '三、权限说明',
            body: '为了可选功能，应用会声明以下权限；它们都不会被用来读取你的通讯录、位置、'
                '相册、麦克风、相机或日历：\n'
                '· 网络（INTERNET）：仅用于“联网更新金句”；不开则不发请求。\n'
                '· 通知（POST_NOTIFICATIONS）：仅在你开启课程提醒后申请。\n'
                '· 开机完成（RECEIVE_BOOT_COMPLETED）：用于重启后恢复课程提醒。\n'
                '· 振动（VIBRATE）：用于通知提醒。\n'
                '应用没有读取或写入系统日历的权限；“加入系统日历”只是打开系统日历的新建事件界面，'
                '由你确认保存。',
          ),
          const _Section(
            title: '四、第三方组件',
            body: '应用基于 Flutter 构建，使用 Flutter 官方组件 material_ui、shared_preferences，'
                '以及文件导入、通知、时区和网络请求的开源库。这些组件不包含广告、统计或崩溃上报 SDK，'
                '不会收集或上传你的任务数据。在线金句使用今日诗词 API（jinrishici.com）。',
          ),
          const _Section(
            title: '五、文件导入与导出',
            body: '课表文件（ICS/Excel/Word/HTML 等）只在本机解析，不会上传；'
                '任务导出只会写入系统剪贴板，由你粘贴到自己的备忘录或网盘。'
                '“加入系统日历”通过系统日历的插入界面完成，应用不读取你的日历内容。',
          ),
          const _Section(
            title: '六、课程提醒',
            body: '课程提醒默认关闭；只有你开启并授权通知后，应用才会在本机安排前一天汇总'
                '和课前 10/5 分钟提醒。提醒内容只包含课程名、时间、地点和教师，'
                '不会上传到服务器。你可以随时关闭提醒，关闭后应用会取消所有已安排的通知。',
          ),
          const _Section(
            title: '七、未成年人保护',
            body: '应用不收集任何个人信息，也不含广告或付费内容，未成年人可以在监护人'
                '指导下放心使用。',
          ),
          const _Section(
            title: '八、政策更新',
            body: '如果未来功能变化导致本政策调整，我们会更新应用内和仓库中的政策文本，'
                '并标注新的生效日期。',
          ),
          const _Section(
            title: '九、联系我们',
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
