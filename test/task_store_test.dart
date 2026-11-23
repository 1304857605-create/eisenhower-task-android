import 'package:flutter_test/flutter_test.dart';
import 'package:quadrant_list/data/task_repository.dart';
import 'package:quadrant_list/models/quadrant.dart';
import 'package:quadrant_list/state/task_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late TaskStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    store = TaskStore(TaskRepository(prefs))..load();
  });

  test('新增任务并按截止日期排序，无日期的排后面', () {
    store.add(
      title: '没有日期',
      quadrant: Quadrant.importantNotUrgent,
    );
    store.add(
      title: '后天',
      quadrant: Quadrant.importantNotUrgent,
      dueDate: DateTime(2026, 11, 24),
    );
    store.add(
      title: '明天',
      quadrant: Quadrant.importantNotUrgent,
      dueDate: DateTime(2026, 11, 23),
    );

    final titles = store
        .tasksFor(Quadrant.importantNotUrgent)
        .map((task) => task.title)
        .toList();
    expect(titles, <String>['明天', '后天', '没有日期']);
  });

  test('勾选完成、移象限、清除已完成', () {
    final task = store.add(
      title: '整理桌面',
      quadrant: Quadrant.notUrgentNotImportant,
    );

    store.toggleCompleted(task.id);
    expect(store.byId(task.id)!.completed, isTrue);
    expect(store.completedCount, 1);
    expect(store.activeCountFor(Quadrant.notUrgentNotImportant), 0);

    store.toggleCompleted(task.id);
    expect(store.byId(task.id)!.completed, isFalse);

    store.moveToQuadrant(task.id, Quadrant.urgentImportant);
    expect(store.byId(task.id)!.quadrant, Quadrant.urgentImportant);
    expect(store.activeCountFor(Quadrant.urgentImportant), 1);

    store.toggleCompleted(task.id);
    store.clearCompleted();
    expect(store.all, isEmpty);
  });

  test('删除后可以撤销恢复', () {
    final task = store.add(
      title: '交水电费',
      quadrant: Quadrant.urgentImportant,
    );
    store.delete(task.id);
    expect(store.all, isEmpty);

    store.restore(task);
    expect(store.byId(task.id), equals(task));
  });

  test('导出再导入可以还原所有任务', () {
    store.add(
      title: '任务 A',
      quadrant: Quadrant.urgentImportant,
      dueDate: DateTime(2026, 12, 1),
    );
    store.add(
      title: '任务 B',
      note: '备注',
      quadrant: Quadrant.importantNotUrgent,
    );

    final json = store.exportJson();

    final another = TaskStore(TaskRepository(prefs))..load();
    final count = another.importJson(json);

    expect(count, 2);
    expect(another.all.map((task) => task.title), containsAll(<String>['任务 A', '任务 B']));
  });

  test('导入非法 JSON 抛出 FormatException', () {
    expect(
      () => store.importJson('{"foo": 1}'),
      throwsA(isA<FormatException>()),
    );
    expect(() => store.importJson('not json'), throwsFormatException);
  });

  test('数据会写入本地存储', () async {
    store.add(title: '持久化', quadrant: Quadrant.urgentNotImportant);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    final reloaded = TaskStore(TaskRepository(prefs))..load();
    expect(reloaded.all.single.title, '持久化');
  });
}
