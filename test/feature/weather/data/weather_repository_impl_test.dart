import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_3/feature/weather/data/weather_repository_impl.dart';

void main() {
  group('WeatherRepositoryImpl', () {
    test('dummy test', () {
      final repo = WeatherRepositoryImpl();
      expect(repo, isNotNull);
    });
  });
} 