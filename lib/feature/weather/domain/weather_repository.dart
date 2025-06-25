// Abstract repository for weather data

class WeatherData {
  final double temperature;
  final String condition;
  final String description;
  final double humidity;
  final double windSpeed;
  final String location;
  final DateTime timestamp;

  const WeatherData({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.location,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'description': description,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      condition: json['condition'] ?? '',
      description: json['description'] ?? '',
      humidity: json['humidity']?.toDouble() ?? 0.0,
      windSpeed: json['windSpeed']?.toDouble() ?? 0.0,
      location: json['location'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

abstract class WeatherRepository {
  Future<WeatherData> getCurrentWeather(double latitude, double longitude);
  Future<List<WeatherData>> getWeatherForecast(
    double latitude,
    double longitude,
    int days,
  );
  Future<WeatherData?> getCachedWeather();
  Future<void> cacheWeather(WeatherData weather);
}
