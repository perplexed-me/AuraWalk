import 'dart:math';
import 'package:flutter/material.dart';
import '../domain/aura_palette_generator.dart';
import '../../../core/local/hive_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_utils.dart';

// Implements aura palette generation logic
class AuraPaletteGeneratorImpl implements AuraPaletteGenerator {
  static const String _paletteBoxKey = 'saved_palettes';

  @override
  Future<AuraPalette> generateFromSound(
    String soundType,
    Map<String, double>? confidenceScores,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final auraType = AppUtils.getAuraColorFromSound(soundType);
    final baseColor = _getColorFromAuraType(auraType);
    final colors = _generateHarmoniousColors(baseColor, 5);

    return AuraPalette(
      name: '${soundType.capitalize()} Aura',
      colors: colors,
      description: 'Generated from $soundType sounds',
      mood: auraType,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AuraPalette> generateFromWeather(
    String weatherCondition,
    double temperature,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final auraType =
        AppConstants.weatherAuraMappings[weatherCondition.toLowerCase()] ??
        'calm';
    final baseColor = _getColorFromAuraType(auraType);

    // Adjust color based on temperature
    final adjustedColor = _adjustColorForTemperature(baseColor, temperature);
    final colors = _generateHarmoniousColors(adjustedColor, 5);

    return AuraPalette(
      name: '${weatherCondition.capitalize()} Weather Aura',
      colors: colors,
      description:
          'Generated from $weatherCondition weather at ${temperature.toStringAsFixed(1)}°C',
      mood: auraType,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AuraPalette> generateFromMood(String mood) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final baseColor = _getColorFromAuraType(mood);
    final colors = _generateHarmoniousColors(baseColor, 5);

    return AuraPalette(
      name: '${mood.capitalize()} Mood',
      colors: colors,
      description: 'Generated for $mood mood',
      mood: mood,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<AuraPalette> generateCustomPalette(List<String> baseColors) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final colors = baseColors
        .map((hex) => Color(int.parse(hex.replaceAll('#', '0xFF'))))
        .toList();

    // Fill up to 5 colors if needed
    while (colors.length < 5) {
      final lastColor = colors.last;
      colors.add(_generateVariation(lastColor));
    }

    return AuraPalette(
      name: 'Custom Palette',
      colors: colors.take(5).toList(),
      description: 'Custom generated palette',
      mood: 'custom',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<AuraPalette>> getSavedPalettes() async {
    try {
      final palettesData = HiveService.getData<List<dynamic>>(
        'aura_data',
        _paletteBoxKey,
      );
      if (palettesData == null) return [];

      return palettesData
          .map((data) => AuraPalette.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> savePalette(AuraPalette palette) async {
    try {
      final existingPalettes = await getSavedPalettes();
      existingPalettes.add(palette);

      final palettesJson = existingPalettes.map((p) => p.toJson()).toList();
      await HiveService.saveData('aura_data', _paletteBoxKey, palettesJson);
    } catch (e) {
      // Ignore save errors
    }
  }

  @override
  Future<void> deletePalette(String paletteName) async {
    try {
      final existingPalettes = await getSavedPalettes();
      existingPalettes.removeWhere((p) => p.name == paletteName);

      final palettesJson = existingPalettes.map((p) => p.toJson()).toList();
      await HiveService.saveData('aura_data', _paletteBoxKey, palettesJson);
    } catch (e) {
      // Ignore delete errors
    }
  }

  Color _getColorFromAuraType(String auraType) {
    final colorHex = AppConstants.auraColorMappings[auraType] ?? '#4A90E2';
    return Color(int.parse(colorHex.replaceAll('#', '0xFF')));
  }

  List<Color> _generateHarmoniousColors(Color baseColor, int count) {
    final colors = <Color>[baseColor];
    final random = Random();

    for (int i = 1; i < count; i++) {
      final hsl = HSLColor.fromColor(baseColor);

      // Generate variations by adjusting hue, saturation, and lightness
      final newHue = (hsl.hue + (i * 60) + random.nextDouble() * 30) % 360;
      final newSaturation = (hsl.saturation + random.nextDouble() * 0.3 - 0.15)
          .clamp(0.0, 1.0);
      final newLightness = (hsl.lightness + random.nextDouble() * 0.3 - 0.15)
          .clamp(0.0, 1.0);

      colors.add(
        HSLColor.fromAHSL(1.0, newHue, newSaturation, newLightness).toColor(),
      );
    }

    return colors;
  }

  Color _adjustColorForTemperature(Color baseColor, double temperature) {
    final hsl = HSLColor.fromColor(baseColor);

    // Warmer temperatures shift towards red/orange, cooler towards blue
    double hueAdjustment = 0;
    if (temperature > 25) {
      hueAdjustment = -30; // Shift towards red/orange
    } else if (temperature < 10) {
      hueAdjustment = 30; // Shift towards blue
    }

    final newHue = (hsl.hue + hueAdjustment) % 360;
    return HSLColor.fromAHSL(
      hsl.alpha,
      newHue,
      hsl.saturation,
      hsl.lightness,
    ).toColor();
  }

  Color _generateVariation(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final random = Random();

    final newLightness = (hsl.lightness + random.nextDouble() * 0.4 - 0.2)
        .clamp(0.0, 1.0);
    return HSLColor.fromAHSL(
      hsl.alpha,
      hsl.hue,
      hsl.saturation,
      newLightness,
    ).toColor();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
