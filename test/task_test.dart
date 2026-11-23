import 'package:flutter_test/flutter_test.dart';
import 'package:quadrant_list/models/quadrant.dart';
import 'package:quadrant_list/models/task.dart';

void main() {
  test('任务可以完整地 JSON 往返', () {
    final task = Task(
      id: 'abc-1',
      title: '写周报',
      note: '周五之前发给组长',
      quadrant: Quadrant.importantNotUrgent,
      createdAt: DateTime(2026, 11, 22, 10, 30),
      dueDate: DateTime(2026, 11, 28),
      completed: true,
      completedAt: DateTime(2026, 11, 23, 9, 0),
    );

    final restored = Task.tryFromJson(task.toJson());

    expect(restored, isNotNull);
    expect(restored, equals(task));
    expect(restored!.quadrant, Quadrant.importantNotUrgent);
    expect(restored.dueDate, DateTime(2026, 11, 28));
  });

  test('坏数据不会让解析崩溃', () {
    expect(Task.tryFromJson(null), isNull);
    expect(Task.tryFromJson('not a map'), isNull);
    expect(Task.tryFromJson(<String, dynamic>{}), isNull);
    expect(
      Task.tryFromJson(<String, dynamic>{'id': 'x', 'title': '   '}),
      isNull,
    );
  });

  test('未知象限回退到重要且紧急', () {
    final task = Task.tryFromJson(<String, dynamic>{
      'id': 'x',
      'title': '旧版本任务',
      'quadrant': 'unknown_quadrant',
      'createdAt': '2026-11-22T10:00:00.000',
    });
    expect(task, isNotNull);
    expect(task!.quadrant, Quadrant.urgentImportant);
  });
}
