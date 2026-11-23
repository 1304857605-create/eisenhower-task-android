// 开发用截图脚本：在 1080×1920 画布上渲染真实界面，输出到 docs/screenshots/。
//
// 用法：
//   1. 下载中文字体到 tool/screenshots/fonts/（见 tool/screenshots/fetch_fonts.ps1）
//   2. flutter test test/screenshots/render_screenshots.dart --update-goldens
//
// 文件名不以 _test.dart 结尾，常规 `flutter test` 不会执行它，避免 CI 依赖字体。
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quadrant_list/app_info.dart';
import 'package:quadrant_list/data/task_repository.dart';
import 'package:quadrant_list/models/quadrant.dart';
import 'package:quadrant_list/screens/home_screen.dart';
import 'package:quadrant_list/screens/settings_screen.dart';
import 'package:quadrant_list/state/settings_store.dart';
import 'package:quadrant_list/state/task_store.dart';
import 'package:quadrant_list/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _fontFamily = 'NotoSansSC';
const String _fontPath = 'tool/screenshots/fonts/NotoSansSC-Regular.otf';

Future<void> _loadFonts() async {
  final fontFile = File(_fontPath);
  if (!fontFile.existsSync()) {
    throw StateError(
      '未找到中文字体 $_fontPath。请先运行 tool/screenshots/fetch_fonts.ps1 下载字体（字体文件不入库）。',
    );
  }
  final bytes = fontFile.readAsBytesSync();
  final chinese = FontLoader(_fontFamily)
    ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
  await chinese.load();
  // 部分 Material 组件的样式会显式指定 Roboto；测试环境没有系统字体回退，
  // 这里用同一份中文字体兜底，避免中文变方块。
  final roboto = FontLoader('Roboto')
    ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
  await roboto.load();

  // 测试环境默认没有 MaterialIcons，需要从 Flutter SDK 手动加载，否则图标会变成方块。
  final iconPath = _findMaterialIconsFont();
  final iconBytes = File(iconPath).readAsBytesSync();
  final icons = FontLoader('MaterialIcons')
    ..addFont(Future<ByteData>.value(ByteData.view(iconBytes.buffer)));
  await icons.load();
}

String _findMaterialIconsFont() {
  const suffix =
      'bin/cache/artifacts/material_fonts/materialicons-regular.otf';
  final candidates = <String>[];
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root != null) {
    candidates.add('$root/$suffix');
  }
  var dir = File(Platform.resolvedExecutable).parent;
  for (var i = 0; i < 6; i++) {
    candidates.add('${dir.path}/$suffix');
    candidates.add('${dir.path}/artifacts/material_fonts/materialicons-regular.otf');
    dir = dir.parent;
  }
  candidates.add('../_toolchain/flutter/$suffix');
  for (final path in candidates) {
    if (File(path).existsSync()) return path;
  }
  throw StateError(
    '找不到 MaterialIcons 字体，请设置 FLUTTER_ROOT 指向 Flutter SDK 根目录。',
  );
}

void _setCanvas(WidgetTester tester) {
  // 测试环境默认把阴影画成黑色实线，这里恢复真实阴影，截图才和真机一致。
  debugDisableShadows = false;
  addTearDown(() => debugDisableShadows = true);
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<(TaskStore, SettingsStore)> _stores({
  bool withSampleData = true,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  final store = TaskStore(TaskRepository(prefs))..load();
  final settings = SettingsStore(prefs)..load();

  if (withSampleData) {
    final now = DateTime.now();
    DateTime day(int offset) => now.add(Duration(days: offset));

    store.add(
      title: '回复客户的方案确认邮件',
      quadrant: Quadrant.urgentImportant,
      dueDate: day(0),
    );
    store.add(
      title: '修复登录页偶现的白屏',
      quadrant: Quadrant.urgentImportant,
      dueDate: day(0),
    );
    store.add(
      title: '准备季度复盘的材料',
      note: '重点讲清楚三件事：做成了什么、卡在哪里、下季度怎么改。',
      quadrant: Quadrant.importantNotUrgent,
      dueDate: day(3),
    );
    store.add(
      title: '读《高效能人士的七个习惯》',
      quadrant: Quadrant.importantNotUrgent,
    );
    final meetingNotes = store.add(
      title: '整理上周会议纪要',
      quadrant: Quadrant.importantNotUrgent,
    );
    store.toggleCompleted(meetingNotes.id);
    store.add(
      title: '预约牙科复查',
      quadrant: Quadrant.urgentNotImportant,
      dueDate: day(1),
    );
    store.add(
      title: '提交差旅报销单',
      quadrant: Quadrant.urgentNotImportant,
      dueDate: day(2),
    );
    store.add(
      title: '整理手机相册',
      quadrant: Quadrant.notUrgentNotImportant,
    );
    store.add(
      title: '给绿植换盆',
      quadrant: Quadrant.notUrgentNotImportant,
    );
    final grocery = store.add(
      title: '买菜和牛奶',
      quadrant: Quadrant.notUrgentNotImportant,
    );
    store.toggleCompleted(grocery.id);
  }

  settings.dismissDragTip();
  settings.acceptPrivacy();
  return (store, settings);
}

Widget _frame({
  required TaskStore store,
  required SettingsStore settings,
  required bool dark,
  Widget? home,
}) {
  final theme = dark
      ? AppTheme.dark(fontFamily: _fontFamily)
      : AppTheme.light(fontFamily: _fontFamily);
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: theme,
    locale: const Locale('zh', 'CN'),
    supportedLocales: const <Locale>[Locale('zh', 'CN')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: Column(
      children: <Widget>[
        _FakeStatusBar(dark: dark),
        Expanded(
          child: home ?? HomeScreen(store: store, settings: settings),
        ),
      ],
    ),
  );
}

class _FakeStatusBar extends StatelessWidget {
  const _FakeStatusBar({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final color = dark ? Colors.white : const Color(0xFF16181C);
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
        child: Row(
          children: <Widget>[
            Text(
              '9:41',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                fontFamily: _fontFamily,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.signal_cellular_alt_rounded, size: 12, color: color),
            const SizedBox(width: 4),
            Icon(Icons.wifi_rounded, size: 12, color: color),
            const SizedBox(width: 4),
            Icon(Icons.battery_full_rounded, size: 13, color: color),
          ],
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadFonts();
  });

  testWidgets('01 首页四象限', (tester) async {
    _setCanvas(tester);
    final (store, settings) = await _stores();
    await tester.pumpWidget(
      _frame(store: store, settings: settings, dark: false),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/01-home.png'),
    );
  });

  testWidgets('02 新建任务', (tester) async {
    _setCanvas(tester);
    final (store, settings) = await _stores();
    await tester.pumpWidget(
      _frame(store: store, settings: settings, dark: false),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('新任务'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '准备下周的项目评审');
    await tester.enterText(
      find.byType(TextField).at(1),
      '和产品、设计确认范围，提前发出会议邀请。',
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/02-new-task.png'),
    );
  });

  testWidgets('03 拖动换象限', (tester) async {
    _setCanvas(tester);
    final (store, settings) = await _stores();
    await tester.pumpWidget(
      _frame(store: store, settings: settings, dark: false),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('回复客户的方案确认邮件')),
    );
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 80));
    await gesture.moveTo(tester.getCenter(find.text('准备季度复盘的材料')));
    await tester.pump(const Duration(milliseconds: 220));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/03-drag.png'),
    );

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('04 象限详情', (tester) async {
    _setCanvas(tester);
    final (store, settings) = await _stores();
    settings.setShowCompleted(true);
    await tester.pumpWidget(
      _frame(store: store, settings: settings, dark: false),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('重要不紧急'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/04-quadrant.png'),
    );
  });

  testWidgets('05 深色模式', (tester) async {
    _setCanvas(tester);
    final (store, settings) = await _stores();
    settings.setThemeMode(ThemeMode.dark);
    await tester.pumpWidget(
      _frame(store: store, settings: settings, dark: true),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/05-dark.png'),
    );
  });

  testWidgets('06 设置页', (tester) async {
    _setCanvas(tester);
    final (store, settings) = await _stores();
    await tester.pumpWidget(
      _frame(
        store: store,
        settings: settings,
        dark: false,
        home: SettingsScreen(store: store, settings: settings),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('../../docs/screenshots/06-settings.png'),
    );
  });

  test('应用元信息完整', () {
    expect(AppInfo.name, isNotEmpty);
    expect(AppInfo.version, isNotEmpty);
  });
}
