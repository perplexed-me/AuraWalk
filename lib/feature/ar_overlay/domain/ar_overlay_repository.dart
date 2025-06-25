import 'package:flutter/material.dart';

// Abstract repository for AR overlay

class ARObject {
  final String id;
  final String type;
  final Color color;
  final double x;
  final double y;
  final double z;
  final double scale;
  final DateTime createdAt;

  const ARObject({
    required this.id,
    required this.type,
    required this.color,
    required this.x,
    required this.y,
    required this.z,
    required this.scale,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'color': color.value, // ignore: deprecated_member_use
      'x': x,
      'y': y,
      'z': z,
      'scale': scale,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ARObject.fromJson(Map<String, dynamic> json) {
    return ARObject(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      color: Color(json['color'] ?? 0xFF000000),
      x: json['x']?.toDouble() ?? 0.0,
      y: json['y']?.toDouble() ?? 0.0,
      z: json['z']?.toDouble() ?? 0.0,
      scale: json['scale']?.toDouble() ?? 1.0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class ARSession {
  final String id;
  final List<ARObject> objects;
  final DateTime startTime;
  final DateTime? endTime;
  final String location;

  const ARSession({
    required this.id,
    required this.objects,
    required this.startTime,
    this.endTime,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'objects': objects.map((o) => o.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'location': location,
    };
  }

  factory ARSession.fromJson(Map<String, dynamic> json) {
    return ARSession(
      id: json['id'] ?? '',
      objects:
          (json['objects'] as List<dynamic>?)
              ?.map((o) => ARObject.fromJson(Map<String, dynamic>.from(o)))
              .toList() ??
          [],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      location: json['location'] ?? '',
    );
  }
}

abstract class AROverlayRepository {
  Future<bool> initializeAR();
  Future<void> disposeAR();
  Future<bool> isARAvailable();
  Future<String> startARSession();
  Future<void> endARSession(String sessionId);
  Future<void> placeObject(String sessionId, ARObject object);
  Future<void> removeObject(String sessionId, String objectId);
  Future<List<ARObject>> getSessionObjects(String sessionId);
  Future<List<ARSession>> getSavedSessions();
  Future<void> saveSession(ARSession session);
  Future<void> deleteSession(String sessionId);
}
