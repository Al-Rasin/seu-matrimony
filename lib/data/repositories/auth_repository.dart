import 'package:get/get.dart';
import '../../core/network/dio_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/storage_service.dart';

class AuthRepository {
  final DioClient _dioClient = Get.find<DioClient>();
  final FirebaseService _firebaseService = Get.find<FirebaseService>();
  final StorageService _storageService = Get.find<StorageService>();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final idToken = await _firebaseService.getIdToken();

      final response = await _dioClient.post(
        ApiConstants.login,
        data: {'firebaseToken': idToken},
      );

      if (response.statusCode == 200) {
        _storageService.isLoggedIn = true;
        return response.data;
      }

      throw Exception('Login failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String profileFor,
    String? idDocumentUrl,
  }) async {
    try {
      await _firebaseService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final idToken = await _firebaseService.getIdToken();

      final response = await _dioClient.post(
        ApiConstants.register,
        data: {
          'firebaseToken': idToken,
          'fullName': fullName,
          'phone': phone,
          'profileFor': profileFor,
          'idDocumentUrl': idDocumentUrl,
        },
      );

      if (response.statusCode == 201) {
        return response.data;
      }

      throw Exception('Registration failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseService.signOut();
      await _storageService.clearAuthData();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  bool get isLoggedIn => _storageService.isLoggedIn;
}
