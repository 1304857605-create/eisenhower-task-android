import 'package:material_ui/material_ui.dart';

import '../course/screens/timetable_screen.dart';
import '../course/state/course_settings_store.dart';
import '../course/state/course_store.dart';
import '../quotes/quote_store.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import '../state/settings_store.dart';
import '../state/task_store.dart';

/// 应用主框架：四象限清单 / 课表 / 设置 三个标签页。
class RootShell extends StatefulWidget {
  const RootShell({
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
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: <Widget>[
          HomeScreen(
            store: widget.taskStore,
            settings: widget.settingsStore,
            courseSettings: widget.courseSettings,
            courseStore: widget.courseStore,
            quoteStore: widget.quoteStore,
          ),
          TimetableScreen(
            store: widget.courseStore,
            settings: widget.courseSettings,
          ),
          SettingsScreen(
            store: widget.taskStore,
            settings: widget.settingsStore,
            courseStore: widget.courseStore,
            courseSettings: widget.courseSettings,
            quoteStore: widget.quoteStore,
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        height: 62,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined, size: 22),
            selectedIcon: Icon(Icons.grid_view_rounded, size: 22),
            label: '四象限',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined, size: 22),
            selectedIcon: Icon(Icons.calendar_month_rounded, size: 22),
            label: '课表',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined, size: 22),
            selectedIcon: Icon(Icons.settings_rounded, size: 22),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
