import 'package:hive_flutter/hive_flutter.dart';

// Handles Hive initialization and box management
class HiveService {
  static const String _soundDataBox = 'sound_data';
  static const String _weatherDataBox = 'weather_data';
  static const String _auraDataBox = 'aura_data';
  static const String _userPreferencesBox = 'user_preferences';

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters here if using custom objects
    // Hive.registerAdapter(SoundDataAdapter());

    // Open boxes
    await Hive.openBox(_soundDataBox);
    await Hive.openBox(_weatherDataBox);
    await Hive.openBox(_auraDataBox);
    await Hive.openBox(_userPreferencesBox);
  }

  // Get a specific box
  static Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  // Sound data operations
  static Box get soundDataBox => Hive.box(_soundDataBox);

  // Weather data operations
  static Box get weatherDataBox => Hive.box(_weatherDataBox);

  // Aura data operations
  static Box get auraDataBox => Hive.box(_auraDataBox);

  // User preferences operations
  static Box get userPreferencesBox => Hive.box(_userPreferencesBox);

  // Save data to a specific box
  static Future<void> saveData(
    String boxName,
    String key,
    dynamic value,
  ) async {
    final box = getBox(boxName);
    await box.put(key, value);
  }

  // Get data from a specific box
  static T? getData<T>(String boxName, String key) {
    final box = getBox(boxName);
    return box.get(key) as T?;
  }

  // Delete data from a specific box
  static Future<void> deleteData(String boxName, String key) async {
    final box = getBox(boxName);
    await box.delete(key);
  }

  // Clear all data in a specific box
  static Future<void> clearBox(String boxName) async {
    final box = getBox(boxName);
    await box.clear();
  }

  // Close all boxes
  static Future<void> closeAll() async {
    await Hive.close();
  }
}
