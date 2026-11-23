import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// 本地存储。使用 SharedPreferences 保存一段 JSON，不联网、不依赖数据库。
class TaskRepository {
  TaskRepository(this._prefs);

  static const String storageKey = 'tasks_v1';

  final SharedPreferences _prefs;

  List<Task> load() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return <Task>[];
    try {
      final decoded = jsonDecode(raw);
      final list = switch (decoded) {
        {'tasks': final List<dynamic> tasks} => tasks,
        final List<dynamic> tasks => tasks,
        _ => const <dynamic>[],
      };
      return list
          .map(Task.tryFromJson)
          .whereType<Task>()
          .toList(growable: false);
    } catch (_) {
      // 存储损坏时宁可返回空列表，也不要让 App 打不开。
      return <Task>[];
    }
  }

  Future<void> save(List<Task> tasks) {
    final payload = jsonEncode(<String, dynamic>{
      'version': 1,
      'tasks': tasks.map((task) => task.toJson()).toList(growable: false),
    });
    return _prefs.setString(storageKey, payload);
  }

  Future<void> clear() => _prefs.remove(storageKey);
}
