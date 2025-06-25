import 'package:flutter/material.dart';

// Abstract generator for aura palettes

class AuraPalette {
  final String name;
  final List<Color> colors;
  final String description;
  final String mood;
  final DateTime createdAt;

  const AuraPalette({
    required this.name,
    required this.colors,
    required this.description,
    required this.mood,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'colors': colors.map((c) => c.value).toList(), // ignore: deprecated_member_use
      'description': description,
      'mood': mood,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AuraPalette.fromJson(Map<String, dynamic> json) {
    return AuraPalette(
      name: json['name'] ?? '',
      colors:
          (json['colors'] as List<dynamic>?)
              ?.map((c) => Color(c as int))
              .toList() ??
          [],
      description: json['description'] ?? '',
      mood: json['mood'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

abstract class AuraPaletteGenerator {
  Future<AuraPalette> generateFromSound(
    String soundType,
    Map<String, double>? confidenceScores,
  );
  Future<AuraPalette> generateFromWeather(
    String weatherCondition,
    double temperature,
  );
  Future<AuraPalette> generateFromMood(String mood);
  Future<AuraPalette> generateCustomPalette(List<String> baseColors);
  Future<List<AuraPalette>> getSavedPalettes();
  Future<void> savePalette(AuraPalette palette);
  Future<void> deletePalette(String paletteName);
}
