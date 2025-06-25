import 'dart:math';
import 'package:flutter/material.dart';
import '../domain/ar_overlay_repository.dart';
import '../../../core/local/hive_service.dart';
import '../../../core/utils/app_utils.dart';

// Implements AR overlay logic using ar_flutter_plugin
class AROverlayRepositoryImpl implements AROverlayRepository {
  static const String _sessionsBoxKey = 'ar_sessions';
  final Map<String, List<ARObject>> _activeSessions = {};
  bool _isInitialized = false;

  @override
  Future<bool> initializeAR() async {
    try {
      // Simulate AR initialization
      await Future.delayed(const Duration(milliseconds: 500));
      _isInitialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> disposeAR() async {
    _isInitialized = false;
    _activeSessions.clear();
  }

  @override
  Future<bool> isARAvailable() async {
    // Simulate AR availability check
    // In a real implementation, this would check device capabilities
    return true;
  }

  @override
  Future<String> startARSession() async {
    if (!_isInitialized) {
      throw Exception('AR not initialized');
    }

    final sessionId = AppUtils.generateId();
    _activeSessions[sessionId] = [];
    return sessionId;
  }

  @override
  Future<void> endARSession(String sessionId) async {
    if (_activeSessions.containsKey(sessionId)) {
      final objects = _activeSessions[sessionId]!;
      final session = ARSession(
        id: sessionId,
        objects: objects,
        startTime: DateTime.now().subtract(
          const Duration(minutes: 5),
        ), // Mock start time
        endTime: DateTime.now(),
        location: 'Current Location',
      );

      await saveSession(session);
      _activeSessions.remove(sessionId);
    }
  }

  @override
  Future<void> placeObject(String sessionId, ARObject object) async {
    if (_activeSessions.containsKey(sessionId)) {
      _activeSessions[sessionId]!.add(object);
    }
  }

  @override
  Future<void> removeObject(String sessionId, String objectId) async {
    if (_activeSessions.containsKey(sessionId)) {
      _activeSessions[sessionId]!.removeWhere((obj) => obj.id == objectId);
    }
  }

  @override
  Future<List<ARObject>> getSessionObjects(String sessionId) async {
    return _activeSessions[sessionId] ?? [];
  }

  @override
  Future<List<ARSession>> getSavedSessions() async {
    try {
      final sessionsData = HiveService.getData<List<dynamic>>(
        'aura_data',
        _sessionsBoxKey,
      );
      if (sessionsData == null) return [];

      return sessionsData
          .map((data) => ARSession.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveSession(ARSession session) async {
    try {
      final existingSessions = await getSavedSessions();
      existingSessions.add(session);

      final sessionsJson = existingSessions.map((s) => s.toJson()).toList();
      await HiveService.saveData('aura_data', _sessionsBoxKey, sessionsJson);
    } catch (e) {
      // Ignore save errors
    }
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    try {
      final existingSessions = await getSavedSessions();
      existingSessions.removeWhere((s) => s.id == sessionId);

      final sessionsJson = existingSessions.map((s) => s.toJson()).toList();
      await HiveService.saveData('aura_data', _sessionsBoxKey, sessionsJson);
    } catch (e) {
      // Ignore delete errors
    }
  }

  // Helper method to generate AR objects based on aura colors
  ARObject generateAuraObject(Color color, String type) {
    final random = Random();

    return ARObject(
      id: AppUtils.generateId(),
      type: type,
      color: color,
      x: (random.nextDouble() - 0.5) * 4, // -2 to 2 meters
      y: random.nextDouble() * 2, // 0 to 2 meters height
      z: -2 - random.nextDouble() * 2, // 2 to 4 meters away
      scale: 0.5 + random.nextDouble() * 1.0, // 0.5 to 1.5 scale
      createdAt: DateTime.now(),
    );
  }

  // Generate multiple objects for an aura palette
  List<ARObject> generateAuraObjectsFromPalette(List<Color> colors) {
    final objects = <ARObject>[];
    final objectTypes = ['sphere', 'cube', 'pyramid', 'cylinder'];
    final random = Random();

    for (int i = 0; i < colors.length; i++) {
      final color = colors[i];
      final type = objectTypes[random.nextInt(objectTypes.length)];
      objects.add(generateAuraObject(color, type));
    }

    return objects;
  }
}
