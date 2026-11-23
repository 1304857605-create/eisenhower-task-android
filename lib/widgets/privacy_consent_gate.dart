import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';

import '../app_info.dart';
import '../state/settings_store.dart';
import '../screens/privacy_screen.dart';

/// 首次启动的隐私政策确认。应用商店合规要求：用户同意后才能使用。
///
/// 本应用不收集任何信息，这个弹窗只是把「数据只在本地」这件事说清楚。
class PrivacyConsentGate extends StatefulWidget {
  const PrivacyConsentGate({
    super.key,
    required this.settings,
    required this.child,
  });

  final SettingsStore settings;
  final Widget child;

  @override
  State<PrivacyConsentGate> createState() => _PrivacyConsentGateState();
}

class _PrivacyConsentGateState extends State<PrivacyConsentGate> {
  bool _dialogScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleDialogIfNeeded();
  }

  @override
  void didUpdateWidget(covariant PrivacyConsentGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleDialogIfNeeded();
  }

  void _scheduleDialogIfNeeded() {
    if (widget.settings.privacyAccepted || _dialogScheduled) return;
    _dialogScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showDialog();
    });
  }

  Future<void> _showDialog() async {
    if (!mounted || widget.settings.privacyAccepted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return PopScope(
          canPop: false,
          child: AlertDialog(
            icon: Icon(
              Icons.lock_outline_rounded,
              color: scheme.primary,
              size: 26,
            ),
            title: const Text('隐私政策'),
            content: SingleChildScrollView(
              child: Text(
                '「${AppInfo.name}」不收集、不出售个人信息，'
                '没有广告、统计和账号。你的任务与课表数据只保存在本机，'
                '卸载应用即删除。\n\n'
                '联网金句、课程提醒等能力默认关闭，只有你主动开启时才会使用对应权限。\n\n'
                '使用前请阅读并同意《隐私政策》。',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.65,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrivacyScreen(),
                  ),
                ),
                child: const Text('查看政策'),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      SystemNavigator.pop();
                    },
                    child: const Text('不同意'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: () {
                      widget.settings.acceptPrivacy();
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text('同意并继续'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
