import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'storage_service.dart';
import '../../main.dart' show isFirebaseInitialized;

/// Firebase service with graceful fallback when Firebase is not configured
class FirebaseService extends GetxService {
  FirebaseAuth? _auth;
  FirebaseMessaging? _messaging;
  FirebaseStorage? _storage;

  FirebaseAuth? get auth {
    if (!isFirebaseInitialized) return null;
    _auth ??= FirebaseAuth.instance;
    return _auth;
  }

  FirebaseMessaging? get messaging {
    if (!isFirebaseInitialized) return null;
    _messaging ??= FirebaseMessaging.instance;
    return _messaging;
  }

  FirebaseStorage? get storage {
    if (!isFirebaseInitialized) return null;
    _storage ??= FirebaseStorage.instance;
    return _storage;
  }

  /// Check if Firebase is available
  bool get isAvailable => isFirebaseInitialized;

  User? get currentUser => auth?.currentUser;
  Stream<User?> get authStateChanges =>
      auth?.authStateChanges() ?? Stream.value(null);

  // Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
  }) async {
    if (auth == null) {
      debugPrint('Firebase Auth not available - skipping phone verification');
      return;
    }
    await auth!.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 60),
    );
  }

  // Sign in with phone credential
  Future<UserCredential?> signInWithPhoneCredential(
      PhoneAuthCredential credential) async {
    if (auth == null) return null;
    return await auth!.signInWithCredential(credential);
  }

  // Create credential from verification ID and SMS code
  PhoneAuthCredential createPhoneCredential({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  // Email/Password Authentication
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (auth == null) return null;
    return await auth!.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (auth == null) return null;
    return await auth!.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    if (auth == null) {
      debugPrint('Firebase Auth not available - skipping password reset email');
      return;
    }
    await auth!.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    await currentUser?.sendEmailVerification();
  }

  // Get Firebase ID Token for backend authentication
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await currentUser?.getIdToken(forceRefresh);
  }

  // Sign out
  Future<void> signOut() async {
    if (auth != null) {
      await auth!.signOut();
    }
    final storageService = Get.find<StorageService>();
    await storageService.clearAuthData();
  }

  // FCM Methods
  Future<String?> getFcmToken() async {
    if (messaging == null) return null;
    return await messaging!.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    if (messaging == null) return;
    await messaging!.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    if (messaging == null) return;
    await messaging!.unsubscribeFromTopic(topic);
  }

  Future<NotificationSettings?> requestNotificationPermissions() async {
    if (messaging == null) return null;
    return await messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // Firebase Storage Methods
  Future<String?> uploadFile({
    required File file,
    required String path,
    Function(double)? onProgress,
  }) async {
    if (storage == null) {
      debugPrint('Firebase Storage not available - skipping file upload');
      return null;
    }
    final ref = storage!.ref().child(path);
    final uploadTask = ref.putFile(file);

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        onProgress(progress);
      });
    }

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteFile(String path) async {
    if (storage == null) return;
    final ref = storage!.ref().child(path);
    await ref.delete();
  }

  // Upload profile photo
  Future<String?> uploadProfilePhoto({
    required File file,
    required String userId,
    Function(double)? onProgress,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final path = 'users/$userId/photos/$fileName';
    return await uploadFile(file: file, path: path, onProgress: onProgress);
  }

  // Upload SEU ID document
  Future<String?> uploadIdDocument({
    required File file,
    required String userId,
    Function(double)? onProgress,
  }) async {
    final fileName =
        'seu_id_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';
    final path = 'users/$userId/documents/$fileName';
    return await uploadFile(file: file, path: path, onProgress: onProgress);
  }
}
