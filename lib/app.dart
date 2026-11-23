import 'package:material_ui/material_ui.dart';

import 'course/state/course_settings_store.dart';
import 'course/state/course_store.dart';
import 'quotes/quote_store.dart';
import 'screens/root_shell.dart';
import 'state/settings_store.dart';
import 'state/task_store.dart';
import 'theme/app_theme.dart';
import 'widgets/privacy_consent_gate.dart';

/// 应用根组件：主题、语言、三标签主框架。
class QuadrantApp extends StatelessWidget {
  const QuadrantApp({
    super.key,
    required this.taskStore,
    required this.settingsStore,
    required this.courseStore,
    required this.courseSettings,
    required this.quoteStore,
  });

  final TaskStore taskStore;
  final SettingsStore settingsStore;
  final CourseStore courseStore;
  final CourseSettingsStore courseSettings;
  final QuoteStore quoteStore;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsStore,
      builder: (context, _) {
        return MaterialApp(
          title: '四象限清单',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settingsStore.themeMode,
          locale: const Locale('zh', 'CN'),
          supportedLocales: const <Locale>[
            Locale('zh', 'CN'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: PrivacyConsentGate(
            settings: settingsStore,
            child: RootShell(
              taskStore: taskStore,
              settingsStore: settingsStore,
              courseStore: courseStore,
              courseSettings: courseSettings,
              quoteStore: quoteStore,
            ),
          ),
        );
      },
    );
  }
}
