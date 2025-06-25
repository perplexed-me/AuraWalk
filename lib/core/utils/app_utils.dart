import 'dart:convert';
import 'dart:math';
import 'dart:async';

class AppUtils {
  // Generate a random ID
  static String generateId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Format timestamp to readable string
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Safely parse JSON
  static Map<String, dynamic>? parseJson(String jsonString) {
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Safely encode JSON
  static String? encodeJson(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two points (Haversine formula)
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Debounce function
  static Timer? _debounceTimer;

  static void debounce(Function() action, Duration delay) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, action);
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Get random aura color based on sound type
  static String getAuraColorFromSound(String soundType) {
    final Map<String, List<String>> soundToColors = {
      'birds': ['peaceful', 'serene', 'vibrant'],
      'traffic': ['energetic', 'vibrant'],
      'nature': ['calm', 'peaceful', 'serene'],
      'urban': ['energetic', 'vibrant', 'warm'],
      'water': ['calm', 'serene', 'cool'],
      'wind': ['peaceful', 'cool'],
      'silence': ['peaceful', 'mysterious'],
      'music': ['vibrant', 'energetic', 'warm'],
      'voices': ['warm', 'energetic'],
      'industrial': ['energetic', 'mysterious'],
    };

    final colors = soundToColors[soundType] ?? ['calm'];
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }

  // Convert hex color to RGB values
  static Map<String, int> hexToRgb(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return {
      'r': int.parse(hexCode.substring(0, 2), radix: 16),
      'g': int.parse(hexCode.substring(2, 4), radix: 16),
      'b': int.parse(hexCode.substring(4, 6), radix: 16),
    };
  }

  // Calculate luminance for accessibility
  static double calculateLuminance(String hexColor) {
    final rgb = hexToRgb(hexColor);
    final r = rgb['r']! / 255;
    final g = rgb['g']! / 255;
    final b = rgb['b']! / 255;

    return 0.299 * r + 0.587 * g + 0.114 * b;
  }

  // Determine if text should be dark or light based on background
  static bool shouldUseDarkText(String backgroundColor) {
    return calculateLuminance(backgroundColor) > 0.5;
  }
}
