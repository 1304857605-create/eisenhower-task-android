/// 日期显示与比较工具。刻意不引入 intl，保持依赖最少。
abstract final class DateText {
  static const List<String> _weekdays = <String>[
    '周一',
    '周二',
    '周三',
    '周四',
    '周五',
    '周六',
    '周日',
  ];

  static String weekday(DateTime date) => _weekdays[date.weekday - 1];

  /// 首页标题下的日期：11月22日 · 周六
  static String homeDate(DateTime date) {
    return '${date.month}月${date.day}日 · ${weekday(date)}';
  }

  /// 编辑器/详情里的日期：2026年11月30日
  static String fullDate(DateTime date) {
    return '${date.year}年${date.month}月${date.day}日';
  }

  /// 卡片上的紧凑日期：今天 / 明天 / 11-30 / 2027-01-03
  static String compactDate(DateTime date, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final target = _dateOnly(date);
    final diff = target.difference(today).inDays;
    if (diff == 0) return '今天';
    if (diff == 1) return '明天';
    if (diff == -1) return '昨天';
    if (target.year == today.year) {
      return '${target.month}-${target.day.toString().padLeft(2, '0')}';
    }
    return '${target.year}-${target.month.toString().padLeft(2, '0')}-'
        '${target.day.toString().padLeft(2, '0')}';
  }

  static bool isOverdue(DateTime date, {DateTime? now}) {
    return _dateOnly(date).isBefore(_dateOnly(now ?? DateTime.now()));
  }

  static bool isToday(DateTime date, {DateTime? now}) {
    return _dateOnly(date) == _dateOnly(now ?? DateTime.now());
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
