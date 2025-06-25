import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/weather_repository_impl.dart';
import '../domain/weather_repository.dart';

// Provider for weather repository
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl();
});

// Provider for current weather
final currentWeatherProvider = FutureProvider.family<WeatherData, LatLng>((
  ref,
  location,
) async {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.getCurrentWeather(location.latitude, location.longitude);
});

// Provider for weather forecast
final weatherForecastProvider =
    FutureProvider.family<List<WeatherData>, ForecastRequest>((
      ref,
      request,
    ) async {
      final repository = ref.watch(weatherRepositoryProvider);
      return repository.getWeatherForecast(
        request.latitude,
        request.longitude,
        request.days,
      );
    });

// Provider for cached weather
final cachedWeatherProvider = FutureProvider<WeatherData?>((ref) async {
  final repository = ref.watch(weatherRepositoryProvider);
  return repository.getCachedWeather();
});

// Helper classes
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LatLng &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

class ForecastRequest {
  final double latitude;
  final double longitude;
  final int days;

  const ForecastRequest(this.latitude, this.longitude, this.days);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForecastRequest &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.days == days;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ days.hashCode;
}
