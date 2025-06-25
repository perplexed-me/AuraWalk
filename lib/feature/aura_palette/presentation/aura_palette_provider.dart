import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/aura_palette_generator_impl.dart';
import '../domain/aura_palette_generator.dart';

// Provider for aura palette generator
final auraPaletteGeneratorProvider = Provider<AuraPaletteGenerator>((ref) {
  return AuraPaletteGeneratorImpl();
});

// Provider for saved palettes
final savedPalettesProvider = FutureProvider<List<AuraPalette>>((ref) async {
  final generator = ref.watch(auraPaletteGeneratorProvider);
  return generator.getSavedPalettes();
});

// Provider for generating palette from sound
final soundPaletteProvider =
    FutureProvider.family<AuraPalette, SoundPaletteRequest>((
      ref,
      request,
    ) async {
      final generator = ref.watch(auraPaletteGeneratorProvider);
      return generator.generateFromSound(
        request.soundType,
        request.confidenceScores,
      );
    });

// Provider for generating palette from weather
final weatherPaletteProvider =
    FutureProvider.family<AuraPalette, WeatherPaletteRequest>((
      ref,
      request,
    ) async {
      final generator = ref.watch(auraPaletteGeneratorProvider);
      return generator.generateFromWeather(
        request.weatherCondition,
        request.temperature,
      );
    });

// Provider for generating palette from mood
final moodPaletteProvider = FutureProvider.family<AuraPalette, String>((
  ref,
  mood,
) async {
  final generator = ref.watch(auraPaletteGeneratorProvider);
  return generator.generateFromMood(mood);
});

// Provider for current palette selection
final currentPaletteProvider = StateProvider<AuraPalette?>((ref) => null);

// Helper classes
class SoundPaletteRequest {
  final String soundType;
  final Map<String, double>? confidenceScores;

  const SoundPaletteRequest(this.soundType, this.confidenceScores);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoundPaletteRequest &&
        other.soundType == soundType &&
        _mapsEqual(other.confidenceScores, confidenceScores);
  }

  @override
  int get hashCode => soundType.hashCode ^ confidenceScores.hashCode;

  bool _mapsEqual(Map<String, double>? a, Map<String, double>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

class WeatherPaletteRequest {
  final String weatherCondition;
  final double temperature;

  const WeatherPaletteRequest(this.weatherCondition, this.temperature);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeatherPaletteRequest &&
        other.weatherCondition == weatherCondition &&
        other.temperature == temperature;
  }

  @override
  int get hashCode => weatherCondition.hashCode ^ temperature.hashCode;
}
