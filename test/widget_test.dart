import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quadrant_list/app.dart';
import 'package:quadrant_list/course/state/course_settings_store.dart';
import 'package:quadrant_list/course/state/course_store.dart';
import 'package:quadrant_list/data/task_repository.dart';
import 'package:quadrant_list/models/quadrant.dart';
import 'package:quadrant_list/quotes/quote_store.dart';
import 'package:quadrant_list/state/settings_store.dart';
import 'package:quadrant_list/state/task_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<(
  TaskStore,
  SettingsStore,
  CourseStore,
  CourseSettingsStore,
  QuoteStore,
)> _buildStores({bool acceptPrivacy = true}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  final settings = SettingsStore(prefs)..load();
  if (acceptPrivacy) settings.acceptPrivacy();
  final quoteStore = QuoteStore(prefs);
  await quoteStore.load();
  return (
    TaskStore(TaskRepository(prefs))..load(),
    settings,
    CourseStore(prefs)..load(),
    CourseSettingsStore(prefs)..load(),
    quoteStore,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('首页展示四象限，并能新建一条任务', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final (store, settings, courseStore, courseSettings, quoteStore) = await _buildStores();
    await tester.pumpWidget(
      QuadrantApp(taskStore: store, settingsStore: settings, courseStore: courseStore, courseSettings: courseSettings, quoteStore: quoteStore),
    );
    await tester.pumpAndSettle();

    expect(find.text('四象限清单'), findsOneWidget);
    expect(find.text('重要且紧急'), findsOneWidget);
    expect(find.text('重要不紧急'), findsOneWidget);
    expect(find.text('紧急不重要'), findsOneWidget);
    expect(find.text('不重要不紧急'), findsOneWidget);
    expect(find.textContaining('长按任务卡片'), findsOneWidget);

    await tester.tap(find.text('新任务'));
    await tester.pumpAndSettle();
    expect(find.text('新建任务'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '写周报');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, '添加'));
    await tester.pumpAndSettle();

    expect(find.text('写周报'), findsOneWidget);
  });

  testWidgets('可以进入象限详情页并切换深色模式', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final (store, settings, courseStore, courseSettings, quoteStore) = await _buildStores();
    store.add(
      title: '准备季度复盘',
      quadrant: Quadrant.importantNotUrgent,
    );

    await tester.pumpWidget(
      QuadrantApp(taskStore: store, settingsStore: settings, courseStore: courseStore, courseSettings: courseSettings, quoteStore: quoteStore),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('重要不紧急'));
    await tester.pumpAndSettle();
    expect(find.text('留出时间，长期投入'), findsOneWidget);
    expect(find.text('准备季度复盘'), findsOneWidget);
    expect(find.text('进行中'), findsOneWidget);

    Navigator.of(tester.element(find.text('进行中'))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('设置'));
    await tester.pumpAndSettle();
    expect(find.text('外观'), findsOneWidget);
    expect(find.text('数据'), findsOneWidget);

    await tester.tap(find.text('深色'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });

  testWidgets('首次启动必须同意隐私政策后才能使用', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final (store, settings, courseStore, courseSettings, quoteStore) =
        await _buildStores(acceptPrivacy: false);

    await tester.pumpWidget(
      QuadrantApp(
        taskStore: store,
        settingsStore: settings,
        courseStore: courseStore,
        courseSettings: courseSettings,
        quoteStore: quoteStore,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('隐私政策'), findsOneWidget);
    expect(find.text('同意并继续'), findsOneWidget);

    await tester.tap(find.text('同意并继续'));
    await tester.pumpAndSettle();

    expect(find.text('同意并继续'), findsNothing);
    expect(settings.privacyAccepted, isTrue);
    expect(find.text('四象限清单'), findsOneWidget);
  });

  testWidgets('新建任务时可以设置截止日期', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final (store, settings, courseStore, courseSettings, quoteStore) = await _buildStores();
    await tester.pumpWidget(
      QuadrantApp(taskStore: store, settingsStore: settings, courseStore: courseStore, courseSettings: courseSettings, quoteStore: quoteStore),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('新任务'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '预约体检');
    await tester.pump();

    await tester.tap(find.text('不设置截止日期'));
    await tester.pumpAndSettle();
    expect(find.text('选择截止日期'), findsOneWidget);

    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, '添加'));
    await tester.pumpAndSettle();

    expect(store.all.single.title, '预约体检');
    expect(store.all.single.dueDate, isNotNull);
    expect(find.text('今天'), findsWidgets);
  });
}
