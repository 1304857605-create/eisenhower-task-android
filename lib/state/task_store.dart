import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../data/task_repository.dart';
import '../models/quadrant.dart';
import '../models/task.dart';

/// 待办数据仓库 + 业务操作。界面只通过它读写任务。
class TaskStore extends ChangeNotifier {
  TaskStore(this._repository);

  final TaskRepository _repository;
  final List<Task> _tasks = <Task>[];
  Future<void> _saveQueue = Future<void>.value();
  final Random _random = Random();

  List<Task> get all => List<Task>.unmodifiable(_tasks);

  int get activeCount => _tasks.where((task) => !task.completed).length;

  int get completedCount => _tasks.where((task) => task.completed).length;

  void load() {
    _tasks
      ..clear()
      ..addAll(_repository.load());
    _sortAll();
    notifyListeners();
  }

  List<Task> tasksFor(Quadrant quadrant) {
    return _tasks.where((task) => task.quadrant == quadrant).toList()
      ..sort(_compare);
  }

  int activeCountFor(Quadrant quadrant) {
    return _tasks
        .where((task) => task.quadrant == quadrant && !task.completed)
        .length;
  }

  int completedCountFor(Quadrant quadrant) {
    return _tasks
        .where((task) => task.quadrant == quadrant && task.completed)
        .length;
  }

  Task? byId(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  Task add({
    required String title,
    String note = '',
    required Quadrant quadrant,
    DateTime? dueDate,
  }) {
    final now = DateTime.now();
    final task = Task(
      id: _newId(now),
      title: title.trim(),
      note: note.trim(),
      quadrant: quadrant,
      createdAt: now,
      dueDate: dueDate == null ? null : Task.normalizeDate(dueDate),
    );
    _tasks.add(task);
    _sortAll();
    _persistAndNotify();
    return task;
  }

  void update(Task task) {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index == -1) return;
    _tasks[index] = task;
    _sortAll();
    _persistAndNotify();
  }

  void toggleCompleted(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;
    final task = _tasks[index];
    final now = DateTime.now();
    _tasks[index] = task.copyWith(
      completed: !task.completed,
      completedAt: task.completed ? null : now,
      clearCompletedAt: task.completed,
    );
    _sortAll();
    _persistAndNotify();
  }

  void moveToQuadrant(String id, Quadrant quadrant) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1 || _tasks[index].quadrant == quadrant) return;
    _tasks[index] = _tasks[index].copyWith(quadrant: quadrant);
    _sortAll();
    _persistAndNotify();
  }

  void delete(String id) {
    final removed = _tasks.where((task) => task.id == id).toList();
    if (removed.isEmpty) return;
    _tasks.removeWhere((task) => task.id == id);
    _persistAndNotify();
  }

  /// 供「撤销删除」使用：把原任务按原 id 放回去。
  void restore(Task task) {
    if (_tasks.any((item) => item.id == task.id)) return;
    _tasks.add(task);
    _sortAll();
    _persistAndNotify();
  }

  void clearCompleted() {
    if (!_tasks.any((task) => task.completed)) return;
    _tasks.removeWhere((task) => task.completed);
    _persistAndNotify();
  }

  void clearAll() {
    if (_tasks.isEmpty) return;
    _tasks.clear();
    _persistAndNotify();
  }

  /// 导出为带格式的 JSON 文本，方便用户复制到笔记/网盘备份。
  String exportJson() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(<String, dynamic>{
      'app': 'quadrant_list',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'tasks': _tasks.map((task) => task.toJson()).toList(growable: false),
    });
  }

  /// 导入 JSON。返回成功导入（新增或覆盖）的条数；格式错误会抛 [FormatException]。
  int importJson(String raw, {bool merge = true}) {
    final decoded = jsonDecode(raw);
    final list = switch (decoded) {
      {'tasks': final List<dynamic> tasks} => tasks,
      final List<dynamic> tasks => tasks,
      _ => throw const FormatException('没有找到 tasks 列表'),
    };

    final imported = list
        .map(Task.tryFromJson)
        .whereType<Task>()
        .toList(growable: false);
    if (imported.isEmpty) {
      throw const FormatException('没有解析到有效任务');
    }

    var changed = 0;
    if (!merge) {
      _tasks.clear();
    }
    for (final task in imported) {
      final index = _tasks.indexWhere((item) => item.id == task.id);
      if (index == -1) {
        _tasks.add(task);
        changed++;
      } else if (merge) {
        _tasks[index] = task;
        changed++;
      }
    }
    _sortAll();
    _persistAndNotify();
    return changed;
  }

  void _sortAll() {
    _tasks.sort(_compare);
  }

  int _compare(Task a, Task b) {
    if (a.completed != b.completed) return a.completed ? 1 : -1;
    if (a.completed) {
      final aTime = a.completedAt ?? a.createdAt;
      final bTime = b.completedAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    }
    final aDue = a.dueDate;
    final bDue = b.dueDate;
    if (aDue != null && bDue != null) {
      final byDue = aDue.compareTo(bDue);
      if (byDue != 0) return byDue;
    } else if (aDue != null) {
      return -1;
    } else if (bDue != null) {
      return 1;
    }
    return b.createdAt.compareTo(a.createdAt);
  }

  String _newId(DateTime now) {
    final time = now.microsecondsSinceEpoch.toRadixString(36);
    final salt = _random.nextInt(1 << 32).toRadixString(36);
    return '$time-$salt';
  }

  void _persistAndNotify() {
    notifyListeners();
    final snapshot = List<Task>.of(_tasks);
    _saveQueue = _saveQueue.then((_) => _repository.save(snapshot)).catchError(
      (Object error, StackTrace stack) {
        debugPrint('保存任务失败: $error');
      },
    );
  }
}
