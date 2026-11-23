import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/task_repository.dart';
import 'state/settings_store.dart';
import 'state/task_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final taskStore = TaskStore(TaskRepository(prefs))..load();
  final settingsStore = SettingsStore(prefs)..load();

  runApp(
    QuadrantApp(taskStore: taskStore, settingsStore: settingsStore),
  );
}
