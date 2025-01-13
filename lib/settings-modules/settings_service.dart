import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _timeRangeKey = 'chartTimeRange';

  // Fetch the saved time range
  static Future<String?> getChartTimeRange() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_timeRangeKey);
  }

  // Save a new time range
  static Future<void> setChartTimeRange(String timeRange) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeRangeKey, timeRange);
  }
}
