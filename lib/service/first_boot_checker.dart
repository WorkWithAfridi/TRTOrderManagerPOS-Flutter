import 'package:get_storage/get_storage.dart';

class FirstBootChecker {
  // Singleton instance
  static final FirstBootChecker _instance = FirstBootChecker._internal();

  // Private constructor
  FirstBootChecker._internal();

  // Factory constructor
  factory FirstBootChecker() {
    return _instance;
  }

  // Storage key
  static const String _isFirstBootKey = 'isFirstBoot';

  // GetStorage instance
  final GetStorage _storage = GetStorage();

  bool isFirstBoot = false;

  /// Checks if this is the first boot.
  /// Returns `true` if it is the first boot, otherwise `false`.
  Future<bool> checkFirstBoot() async {
    // Check if the key exists in storage
    bool? isFirstBoot = _storage.read<bool>(_isFirstBootKey);

    if (isFirstBoot == null || isFirstBoot == true) {
      // First boot
      await _storage.write(_isFirstBootKey, false);
      isFirstBoot = true;
      return true;
    }

    isFirstBoot = false;

    // Not the first boot
    return false;
  }
}
