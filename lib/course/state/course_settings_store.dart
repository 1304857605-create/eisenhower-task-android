import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 课表提醒、每日一句等新增功能的开关。全部可选、默认尽量克制。
class CourseSettingsStore extends ChangeNotifier {
  CourseSettingsStore(this._prefs);

  static const String _remindersKey = 'course_reminders_enabled';
  static const String _summaryKey = 'course_daily_summary';
  static const String _summaryTimeKey = 'course_summary_minutes';
  static const String _pre10Key = 'course_pre_10';
  static const String _pre5Key = 'course_pre_5';
  static const String _quoteVisibleKey = 'quote_visible';
  static const String _quoteOnlineKey = 'quote_online_enabled';

  final SharedPreferences _prefs;

  bool _remindersEnabled = false;
  bool _dailySummaryEnabled = true;
  int _summaryMinutes = 21 * 60;
  bool _preClass10 = true;
  bool _preClass5 = true;
  bool _quoteVisible = true;
  bool _quoteOnlineEnabled = false;

  bool get remindersEnabled => _remindersEnabled;

  bool get dailySummaryEnabled => _dailySummaryEnabled;

  int get summaryMinutes => _summaryMinutes;

  bool get preClass10 => _preClass10;

  bool get preClass5 => _preClass5;

  bool get quoteVisible => _quoteVisible;

  bool get quoteOnlineEnabled => _quoteOnlineEnabled;

  String get summaryTimeLabel {
    final hour = (_summaryMinutes ~/ 60).toString().padLeft(2, '0');
    final minute = (_summaryMinutes % 60).toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void load() {
    _remindersEnabled = _prefs.getBool(_remindersKey) ?? false;
    _dailySummaryEnabled = _prefs.getBool(_summaryKey) ?? true;
    _summaryMinutes = _prefs.getInt(_summaryTimeKey) ?? 21 * 60;
    _preClass10 = _prefs.getBool(_pre10Key) ?? true;
    _preClass5 = _prefs.getBool(_pre5Key) ?? true;
    _quoteVisible = _prefs.getBool(_quoteVisibleKey) ?? true;
    _quoteOnlineEnabled = _prefs.getBool(_quoteOnlineKey) ?? false;
    notifyListeners();
  }

  void setRemindersEnabled(bool value) {
    if (_remindersEnabled == value) return;
    _remindersEnabled = value;
    _prefs.setBool(_remindersKey, value);
    notifyListeners();
  }

  void setDailySummaryEnabled(bool value) {
    if (_dailySummaryEnabled == value) return;
    _dailySummaryEnabled = value;
    _prefs.setBool(_summaryKey, value);
    notifyListeners();
  }

  void setSummaryMinutes(int minutes) {
    final normalized = minutes.clamp(0, 23 * 60 + 59);
    if (_summaryMinutes == normalized) return;
    _summaryMinutes = normalized;
    _prefs.setInt(_summaryTimeKey, normalized);
    notifyListeners();
  }

  void setPreClass10(bool value) {
    if (_preClass10 == value) return;
    _preClass10 = value;
    _prefs.setBool(_pre10Key, value);
    notifyListeners();
  }

  void setPreClass5(bool value) {
    if (_preClass5 == value) return;
    _preClass5 = value;
    _prefs.setBool(_pre5Key, value);
    notifyListeners();
  }

  void setQuoteVisible(bool value) {
    if (_quoteVisible == value) return;
    _quoteVisible = value;
    _prefs.setBool(_quoteVisibleKey, value);
    notifyListeners();
  }

  void setQuoteOnlineEnabled(bool value) {
    if (_quoteOnlineEnabled == value) return;
    _quoteOnlineEnabled = value;
    _prefs.setBool(_quoteOnlineKey, value);
    notifyListeners();
  }
}
