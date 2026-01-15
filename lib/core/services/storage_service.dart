import 'package:get_storage/get_storage.dart';
import '../constants/storage_keys.dart';

class StorageService {
  late final GetStorage _box;

  StorageService() {
    _box = GetStorage();
  }

  static Future<void> init() async {
    await GetStorage.init();
  }

  // Generic read/write methods
  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, dynamic value) => _box.write(key, value);

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clearAll() => _box.erase();

  bool hasKey(String key) => _box.hasData(key);

  // Auth specific methods
  String? get accessToken => read<String>(StorageKeys.accessToken);

  set accessToken(String? value) => write(StorageKeys.accessToken, value);

  String? get refreshToken => read<String>(StorageKeys.refreshToken);

  set refreshToken(String? value) => write(StorageKeys.refreshToken, value);

  String? get firebaseToken => read<String>(StorageKeys.firebaseToken);

  set firebaseToken(String? value) => write(StorageKeys.firebaseToken, value);

  String? get userId => read<String>(StorageKeys.userId);

  set userId(String? value) => write(StorageKeys.userId, value);

  bool get isLoggedIn => read<bool>(StorageKeys.isLoggedIn) ?? false;

  set isLoggedIn(bool value) => write(StorageKeys.isLoggedIn, value);

  // Onboarding
  bool get hasSeenOnboarding =>
      read<bool>(StorageKeys.hasSeenOnboarding) ?? false;

  set hasSeenOnboarding(bool value) =>
      write(StorageKeys.hasSeenOnboarding, value);

  // Profile completion
  int get profileCompletion => read<int>(StorageKeys.profileCompletion) ?? 0;

  set profileCompletion(int value) =>
      write(StorageKeys.profileCompletion, value);

  bool get isProfileComplete =>
      read<bool>(StorageKeys.isProfileComplete) ?? false;

  set isProfileComplete(bool value) =>
      write(StorageKeys.isProfileComplete, value);

  // User data
  Map<String, dynamic>? get userData =>
      read<Map<String, dynamic>>(StorageKeys.userData);

  set userData(Map<String, dynamic>? value) =>
      write(StorageKeys.userData, value);

  // FCM Token
  String? get fcmToken => read<String>(StorageKeys.fcmToken);

  set fcmToken(String? value) => write(StorageKeys.fcmToken, value);

  // Clear auth data on logout
  Future<void> clearAuthData() async {
    await remove(StorageKeys.accessToken);
    await remove(StorageKeys.refreshToken);
    await remove(StorageKeys.firebaseToken);
    await remove(StorageKeys.userId);
    await remove(StorageKeys.isLoggedIn);
    await remove(StorageKeys.userData);
    await remove(StorageKeys.profileCompletion);
    await remove(StorageKeys.isProfileComplete);
  }
}
