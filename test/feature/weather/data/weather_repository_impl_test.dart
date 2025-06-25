import 'package:flutter_test/flutter_test.dart';
import 'package:aura_walk/feature/weather/data/weather_repository_impl.dart';

void main() {
  group('WeatherRepositoryImpl', () {
    test('dummy test', () {
      final repo = WeatherRepositoryImpl();
      expect(repo, isNotNull);
    });
  });
} 