import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _pomodoroLengthKey = 'pomodoroLength';
  static const String _restTimeKey = 'restTime';
  static const String _activityTagsKey = 'activityTags';
  static const String _lastSelectedTagKey = 'lastSelectedTag';
  static const String _completedSessionsKey = 'completedSessions';
  static const String _sessionsToGrowKey = 'sessionsToGrow';
  static const String _activityTimeKey = 'activityTime';

  // Default values
  static const int defaultPomodoroLength = 25;
  static const int defaultRestTime = 5;
  static const int defaultSessionsToGrow = 3;
  static const List<String> defaultActivityTags = ['Work', 'Study', 'Reading'];

  // Singleton instance
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  Future<void> savePomodoroLength(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pomodoroLengthKey, minutes);
  }

  Future<int> getPomodoroLength() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pomodoroLengthKey) ?? defaultPomodoroLength;
  }

  Future<void> saveRestTime(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_restTimeKey, minutes);
  }

  Future<int> getRestTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_restTimeKey) ?? defaultRestTime;
  }

  Future<void> saveActivityTags(List<String> tags) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_activityTagsKey, tags);
  }

  Future<List<String>> getActivityTags() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_activityTagsKey) ?? defaultActivityTags;
  }

  Future<void> saveLastSelectedTag(String tag) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSelectedTagKey, tag);
  }

  Future<String?> getLastSelectedTag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSelectedTagKey);
  }

  Future<void> saveCompletedSessions(int sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_completedSessionsKey, sessions);
  }

  Future<int> getCompletedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_completedSessionsKey) ?? 0;
  }

  Future<void> saveSessionsToGrow(int sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionsToGrowKey, sessions);
  }

  Future<int> getSessionsToGrow() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_sessionsToGrowKey) ?? defaultSessionsToGrow;
  }

  Future<void> addTimeToActivity(String activity, int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> activityTime = await getActivityTime();
    
    activityTime[activity] = (activityTime[activity] ?? 0) + minutes;
    
    // Convert Map<String, int> to Map<String, String> for storage
    final Map<String, String> storedMap = activityTime.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    
    await prefs.setString(_activityTimeKey, _encodeMap(storedMap));
  }

  Future<Map<String, int>> getActivityTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedMap = prefs.getString(_activityTimeKey);
    
    if (encodedMap == null) {
      return {};
    }

    // Convert stored Map<String, String> back to Map<String, int>
    final Map<String, String> storedMap = _decodeMap(encodedMap);
    return storedMap.map(
      (key, value) => MapEntry(key, int.parse(value)),
    );
  }

  // Helper method to encode Map to String
  String _encodeMap(Map<String, String> map) {
    return map.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // Helper method to decode String to Map
  Map<String, String> _decodeMap(String encodedMap) {
    return Map.fromEntries(
      encodedMap.split('&').map((item) {
        final parts = item.split('=');
        if (parts.length != 2) return MapEntry('', '');
        return MapEntry(
          Uri.decodeComponent(parts[0]),
          Uri.decodeComponent(parts[1]),
        );
      }).where((entry) => entry.key.isNotEmpty),
    );
  }

  Future<void> clearActivityTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activityTimeKey);
  }

  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pomodoroLengthKey, defaultPomodoroLength);
    await prefs.setInt(_restTimeKey, defaultRestTime);
    await prefs.setInt(_sessionsToGrowKey, defaultSessionsToGrow);
    await prefs.setStringList(_activityTagsKey, defaultActivityTags);
    await prefs.remove(_lastSelectedTagKey);
    await prefs.setInt(_completedSessionsKey, 0);
    await prefs.remove(_activityTimeKey);
  }
}
