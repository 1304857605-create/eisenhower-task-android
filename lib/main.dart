import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'course/notifications/course_reminder_service.dart';
import 'course/state/course_settings_store.dart';
import 'course/state/course_store.dart';
import 'data/task_repository.dart';
import 'quotes/quote_store.dart';
import 'state/settings_store.dart';
import 'state/task_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final taskStore = TaskStore(TaskRepository(prefs))..load();
  final settingsStore = SettingsStore(prefs)..load();
  final courseStore = CourseStore(prefs)..load();
  final courseSettings = CourseSettingsStore(prefs)..load();
  final quoteStore = QuoteStore(prefs);
  await quoteStore.load();

  if (courseSettings.quoteOnlineEnabled) {
    unawaited(quoteStore.refreshIfNeeded());
  }

  await CourseReminderService.instance.init();
  unawaited(CourseReminderService.instance.sync(courseStore, courseSettings));

  runApp(
    QuadrantApp(
      taskStore: taskStore,
      settingsStore: settingsStore,
      courseStore: courseStore,
      courseSettings: courseSettings,
      quoteStore: quoteStore,
    ),
  );
}
