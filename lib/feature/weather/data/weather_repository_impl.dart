import 'dart:math';
import '../domain/weather_repository.dart';
import '../../../core/local/hive_service.dart';

// Implements weather fetching and caching using OpenWeather API
class WeatherRepositoryImpl implements WeatherRepository {
  static const String _cacheKey = 'current_weather';

  WeatherRepositoryImpl();

  @override
  Future<WeatherData> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      // For demo purposes, return mock data
      // In a real implementation, you would make an API call to OpenWeather
      await Future.delayed(const Duration(milliseconds: 500));

      final mockWeather = _generateMockWeather(latitude, longitude);
      await cacheWeather(mockWeather);
      return mockWeather;
    } catch (e) {
      // Try to return cached data if API fails
      final cached = await getCachedWeather();
      if (cached != null) {
        return cached;
      }
      rethrow;
    }
  }

  @override
  Future<List<WeatherData>> getWeatherForecast(
    double latitude,
    double longitude,
    int days,
  ) async {
    try {
      // For demo purposes, return mock forecast data
      await Future.delayed(const Duration(milliseconds: 800));

      final forecast = <WeatherData>[];
      for (int i = 0; i < days; i++) {
        final weather = _generateMockWeather(
          latitude,
          longitude,
          DateTime.now().add(Duration(days: i)),
        );
        forecast.add(weather);
      }

      return forecast;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<WeatherData?> getCachedWeather() async {
    try {
      final weatherJson = HiveService.getData<Map<dynamic, dynamic>>(
        'weather_data',
        _cacheKey,
      );

      if (weatherJson != null) {
        final weatherMap = Map<String, dynamic>.from(weatherJson);
        return WeatherData.fromJson(weatherMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheWeather(WeatherData weather) async {
    try {
      await HiveService.saveData('weather_data', _cacheKey, weather.toJson());
    } catch (e) {
      // Ignore cache errors
    }
  }

  WeatherData _generateMockWeather(
    double latitude,
    double longitude, [
    DateTime? date,
  ]) {
    final random = Random();
    final conditions = ['clear', 'clouds', 'rain', 'snow', 'thunderstorm'];
    final descriptions = {
      'clear': 'Clear sky',
      'clouds': 'Partly cloudy',
      'rain': 'Light rain',
      'snow': 'Light snow',
      'thunderstorm': 'Thunderstorm',
    };

    final condition = conditions[random.nextInt(conditions.length)];

    return WeatherData(
      temperature: 15 + random.nextDouble() * 20, // 15-35°C
      condition: condition,
      description: descriptions[condition]!,
      humidity: 30 + random.nextDouble() * 40, // 30-70%
      windSpeed: random.nextDouble() * 15, // 0-15 m/s
      location:
          'Location (${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)})',
      timestamp: date ?? DateTime.now(),
    );
  }
}
