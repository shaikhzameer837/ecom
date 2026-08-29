/// Safe parsing helpers for Firebase Realtime Database snapshots,
/// which arrive as `Map<Object?, Object?>` with loosely typed values.
class ModelUtils {
  ModelUtils._();

  static Map<String, dynamic> asMap(Object? raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  static String asString(Object? value, [String fallback = '']) =>
      value?.toString() ?? fallback;

  static double asDouble(Object? value, [double fallback = 0]) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static int asInt(Object? value, [int fallback = 0]) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool asBool(Object? value, [bool fallback = false]) {
    if (value is bool) return value;
    return fallback;
  }

  static List<String> asStringList(Object? value) {
    if (value is List) {
      return value.where((e) => e != null).map((e) => e.toString()).toList();
    }
    if (value is Map) {
      // RTDB sometimes stores lists as {"0": .., "1": ..} maps.
      return value.values.where((e) => e != null).map((e) => e.toString()).toList();
    }
    return const [];
  }

  static Map<String, String> asStringMap(Object? value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
    }
    return const {};
  }
}
