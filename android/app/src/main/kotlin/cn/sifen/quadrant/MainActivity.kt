package cn.sifen.quadrant

import android.content.Intent
import android.provider.CalendarContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val calendarChannel = "cn.sifen.quadrant/calendar"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, calendarChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "insertEvent" -> {
                        try {
                            val title = call.argument<String>("title") ?: "课程"
                            val location = call.argument<String>("location") ?: ""
                            val description = call.argument<String>("description") ?: ""
                            val startMillis = call.argument<Long>("startMillis")
                            val endMillis = call.argument<Long>("endMillis")
                            if (startMillis == null || endMillis == null) {
                                result.error("INVALID_ARGS", "Missing start/end time", null)
                                return@setMethodCallHandler
                            }
                            val intent = Intent(Intent.ACTION_INSERT).apply {
                                data = CalendarContract.Events.CONTENT_URI
                                putExtra(CalendarContract.Events.TITLE, title)
                                putExtra(CalendarContract.Events.EVENT_LOCATION, location)
                                putExtra(CalendarContract.Events.DESCRIPTION, description)
                                putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startMillis)
                                putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endMillis)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (error: Exception) {
                            result.error("INSERT_FAILED", error.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
