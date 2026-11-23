import 'package:flutter/services.dart';

/// 通过系统「新建日历事件」界面把课程加入系统日历。
/// 不申请日历读写权限：由系统日历 App 弹出编辑页，用户确认后保存。
abstract final class CalendarBridge {
  static const MethodChannel _channel =
      MethodChannel('cn.sifen.quadrant/calendar');

  static Future<bool> addEvent({
    required String title,
    required String location,
    required String description,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('insertEvent', <String, Object?>{
        'title': title,
        'location': location,
        'description': description,
        'startMillis': start.millisecondsSinceEpoch,
        'endMillis': end.millisecondsSinceEpoch,
      });
      return result ?? false;
    } on PlatformException catch (_) {
      rethrow;
    } on MissingPluginException {
      return false;
    }
  }
}
