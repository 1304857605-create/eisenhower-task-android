import 'package:flutter/foundation.dart';

import 'quadrant.dart';

/// 一条待办。
///
/// 数据只保存在本机，字段保持简单、可读，方便导出成 JSON 备份。
@immutable
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.quadrant,
    required this.createdAt,
    this.note = '',
    this.dueDate,
    this.completed = false,
    this.completedAt,
  });

  final String id;
  final String title;
  final String note;
  final Quadrant quadrant;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool completed;
  final DateTime? completedAt;

  bool get hasNote => note.trim().isNotEmpty;

  Task copyWith({
    String? title,
    String? note,
    Quadrant? quadrant,
    DateTime? dueDate,
    bool clearDueDate = false,
    bool? completed,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      quadrant: quadrant ?? this.quadrant,
      createdAt: createdAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      completed: completed ?? this.completed,
      completedAt: clearCompletedAt
          ? null
          : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'note': note,
      'quadrant': quadrant.storageKey,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'completed': completed,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  static Task? tryFromJson(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final title = raw['title'];
    if (id is! String || id.trim().isEmpty) return null;
    if (title is! String || title.trim().isEmpty) return null;

    final createdAt = _parseDate(raw['createdAt']) ?? DateTime.now();
    final dueDate = _parseDate(raw['dueDate']);
    final completedAt = _parseDate(raw['completedAt']);

    return Task(
      id: id,
      title: title.trim(),
      note: raw['note'] is String ? (raw['note'] as String).trim() : '',
      quadrant: Quadrant.fromStorage(raw['quadrant'] as String?),
      createdAt: createdAt,
      dueDate: dueDate == null ? null : normalizeDate(dueDate),
      completed: raw['completed'] == true,
      completedAt: completedAt,
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  /// 去掉时分秒，只保留日期，避免“同一天”出现时区/时间误差。
  static DateTime normalizeDate(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  @override
  bool operator ==(Object other) {
    return other is Task &&
        other.id == id &&
        other.title == title &&
        other.note == note &&
        other.quadrant == quadrant &&
        other.createdAt == createdAt &&
        other.dueDate == dueDate &&
        other.completed == completed &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        note,
        quadrant,
        createdAt,
        dueDate,
        completed,
        completedAt,
      );
}
