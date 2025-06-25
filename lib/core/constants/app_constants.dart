class AppConstants {
  // App Information
  static const String appName = 'AuraWalk';
  static const String appVersion = '1.0.0';

  // API Keys and URLs
  static const String weatherApiBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  // Local Storage Keys
  static const String userPreferencesKey = 'user_preferences';
  static const String lastSyncKey = 'last_sync';
  static const String offlineModeKey = 'offline_mode';

  // Sound Classification
  static const List<String> soundCategories = [
    'birds',
    'traffic',
    'nature',
    'urban',
    'water',
    'wind',
    'silence',
    'music',
    'voices',
    'industrial',
  ];

  // Aura Colors
  static const Map<String, String> auraColorMappings = {
    'calm': '#4A90E2',
    'energetic': '#F5A623',
    'peaceful': '#7ED321',
    'mysterious': '#9013FE',
    'vibrant': '#FF6B6B',
    'serene': '#50E3C2',
    'warm': '#FF9500',
    'cool': '#0080FF',
  };

  // Weather Condition Mappings
  static const Map<String, String> weatherAuraMappings = {
    'clear': 'vibrant',
    'clouds': 'serene',
    'rain': 'calm',
    'snow': 'peaceful',
    'thunderstorm': 'mysterious',
    'fog': 'mysterious',
    'drizzle': 'calm',
  };

  // AR Settings
  static const double arObjectScale = 0.1;
  static const double arPlacementDistance = 2.0;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
}
