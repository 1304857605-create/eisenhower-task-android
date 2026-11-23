import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 轻量设置项：主题、是否显示已完成、首次拖动提示。
class SettingsStore extends ChangeNotifier {
  SettingsStore(this._prefs);

  static const String _themeKey = 'settings_theme_mode';
  static const String _showCompletedKey = 'settings_show_completed';
  static const String _dragTipKey = 'settings_show_drag_tip';
  static const String _privacyKey = 'settings_privacy_accepted_v1';

  final SharedPreferences _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  bool _showCompleted = false;
  bool _showDragTip = true;
  bool _privacyAccepted = false;

  ThemeMode get themeMode => _themeMode;

  bool get showCompleted => _showCompleted;

  bool get showDragTip => _showDragTip;

  bool get privacyAccepted => _privacyAccepted;

  void load() {
    final storedTheme = _prefs.getString(_themeKey);
    _themeMode = switch (storedTheme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    _showCompleted = _prefs.getBool(_showCompletedKey) ?? false;
    _showDragTip = _prefs.getBool(_dragTipKey) ?? true;
    _privacyAccepted = _prefs.getBool(_privacyKey) ?? false;
    notifyListeners();
  }

  void acceptPrivacy() {
    if (_privacyAccepted) return;
    _privacyAccepted = true;
    _prefs.setBool(_privacyKey, true);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    _prefs.setString(_themeKey, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
    notifyListeners();
  }

  void setShowCompleted(bool value) {
    if (_showCompleted == value) return;
    _showCompleted = value;
    _prefs.setBool(_showCompletedKey, value);
    notifyListeners();
  }

  void dismissDragTip() {
    if (!_showDragTip) return;
    _showDragTip = false;
    _prefs.setBool(_dragTipKey, false);
    notifyListeners();
  }

  void resetDragTip() {
    _showDragTip = true;
    _prefs.setBool(_dragTipKey, true);
    notifyListeners();
  }
}
