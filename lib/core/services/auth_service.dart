import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../constants/firebase_constants.dart';
import '../../main.dart' show isFirebaseInitialized;
import 'firestore_service.dart';
import 'storage_service.dart';

/// Firebase Authentication service
class AuthService extends GetxService {
  FirebaseAuth? _auth;
  late final FirestoreService _firestoreService;
  late final StorageService _storageService;

  FirebaseAuth? get auth => _auth;

  /// Current authenticated user
  User? get currentUser => _auth?.currentUser;

  /// Current user ID
  String? get currentUserId => _auth?.currentUser?.uid;

  /// Check if user is logged in
  bool get isLoggedIn => _auth?.currentUser != null;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth?.authStateChanges() ?? Stream.value(null);

  /// Stream of user changes (includes token refresh)
  Stream<User?> get userChanges => _auth?.userChanges() ?? Stream.value(null);

  @override
  void onInit() {
    super.onInit();
    if (isFirebaseInitialized) {
      _auth = FirebaseAuth.instance;
    }
    _firestoreService = Get.find<FirestoreService>();
    _storageService = Get.find<StorageService>();
  }

  // ==================== EMAIL/PASSWORD AUTHENTICATION ====================

  /// Sign up with email and password
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? profileFor,
  }) async {
    if (_auth == null) return AuthResult.failure('Firebase not initialized');
    try {
      // Create user in Firebase Auth
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Failed to create user');
      }

      // Update display name
      await user.updateDisplayName(fullName);

      // Create user document in Firestore
      await _firestoreService.createWithId(
        collection: FirebaseConstants.usersCollection,
        documentId: user.uid,
        data: {
          FirebaseConstants.fieldEmail: email,
          FirebaseConstants.fieldPhone: phone,
          FirebaseConstants.fieldFullName: fullName,
          FirebaseConstants.fieldProfileFor: profileFor,
          FirebaseConstants.fieldRole: FirebaseConstants.roleUser,
          FirebaseConstants.fieldIsVerified: false,
          FirebaseConstants.fieldIsOnline: true,
          FirebaseConstants.fieldProfileCompletion: 0,
        },
      );

      // Save auth data locally
      await _storageService.setUserId(user.uid);
      await _storageService.setUserEmail(email);

      return AuthResult.success(user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Sign up error: $e');
      return AuthResult.failure('An error occurred during sign up');
    }
  }

  /// Sign in with email and password
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (_auth == null) return AuthResult.failure('Firebase not initialized');
    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return AuthResult.failure('Failed to sign in');
      }

      // Update online status
      await _updateOnlineStatus(user.uid, true);

      // Fetch and save user data
      final userData = await _firestoreService.getById(
        collection: FirebaseConstants.usersCollection,
        documentId: user.uid,
      );

      if (userData != null) {
        await _storageService.setUserId(user.uid);
        await _storageService.setUserEmail(email);
        await _storageService.setUserName(userData[FirebaseConstants.fieldFullName] ?? '');

        final role = userData[FirebaseConstants.fieldRole] as String?;
        if (role != null) {
          await _storageService.setUserRole(role);
        }
      }

      return AuthResult.success(user, userData: userData);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Sign in error: $e');
      return AuthResult.failure('An error occurred during sign in');
    }
  }

  // ==================== PHONE AUTHENTICATION ====================

  /// Send OTP to phone number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(String) onVerificationFailed,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String) onCodeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    if (_auth == null) {
      onVerificationFailed('Firebase not initialized');
      return;
    }
    await _auth!.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: (e) => onVerificationFailed(_getAuthErrorMessage(e.code)),
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onCodeAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
      timeout: const Duration(seconds: 60),
    );
  }

  /// Verify OTP and sign in
  Future<AuthResult> verifyOtpAndSignIn({
    required String verificationId,
    required String smsCode,
  }) async {
    if (_auth == null) return AuthResult.failure('Firebase not initialized');
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final result = await _auth!.signInWithCredential(credential);
      final user = result.user;

      if (user == null) {
        return AuthResult.failure('Failed to verify OTP');
      }

      // Check if user exists in Firestore
      final exists = await _firestoreService.exists(
        collection: FirebaseConstants.usersCollection,
        documentId: user.uid,
      );

      if (!exists) {
        // New user - needs registration
        return AuthResult.success(user, isNewUser: true);
      }

      // Update online status
      await _updateOnlineStatus(user.uid, true);

      // Existing user - fetch data
      final userData = await _firestoreService.getById(
        collection: FirebaseConstants.usersCollection,
        documentId: user.uid,
      );

      await _storageService.setUserId(user.uid);

      return AuthResult.success(user, userData: userData);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('OTP verification error: $e');
      return AuthResult.failure('An error occurred during verification');
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    if (_auth == null) return AuthResult.failure('Firebase not initialized');
    try {
      await _auth!.sendPasswordResetEmail(email: email);
      return AuthResult.success(null, message: 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Password reset error: $e');
      return AuthResult.failure('An error occurred');
    }
  }

  /// Confirm password reset with code
  Future<AuthResult> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    if (_auth == null) return AuthResult.failure('Firebase not initialized');
    try {
      await _auth!.confirmPasswordReset(code: code, newPassword: newPassword);
      return AuthResult.success(null, message: 'Password reset successful');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Confirm password reset error: $e');
      return AuthResult.failure('An error occurred');
    }
  }

  // ==================== EMAIL VERIFICATION ====================

  /// Send email verification
  Future<AuthResult> sendEmailVerification() async {
    if (_auth == null) return AuthResult.failure('Firebase not initialized');
    try {
      final user = _auth!.currentUser;
      if (user == null) {
        return AuthResult.failure('No user logged in');
      }

      await user.sendEmailVerification();
      return AuthResult.success(user, message: 'Verification email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Email verification error: $e');
      return AuthResult.failure('An error occurred');
    }
  }

  /// Check if email is verified
  Future<bool> isEmailVerified() async {
    if (_auth == null) return false;
    await _auth!.currentUser?.reload();
    return _auth!.currentUser?.emailVerified ?? false;
  }

  // ==================== USER DATA OPERATIONS ====================

  /// Get current user data from Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final userId = currentUserId;
    if (userId == null) return null;

    return await _firestoreService.getById(
      collection: FirebaseConstants.usersCollection,
      documentId: userId,
    );
  }

  /// Stream current user data
  Stream<Map<String, dynamic>?> streamCurrentUserData() {
    final userId = currentUserId;
    if (userId == null) return Stream.value(null);

    return _firestoreService.getByIdStream(
      collection: FirebaseConstants.usersCollection,
      documentId: userId,
    );
  }

  /// Update current user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    final userId = currentUserId;
    if (userId == null) return;

    await _firestoreService.update(
      collection: FirebaseConstants.usersCollection,
      documentId: userId,
      data: data,
    );
  }

  /// Check if user profile is complete
  Future<bool> isProfileComplete() async {
    final userData = await getCurrentUserData();
    if (userData == null) return false;

    final completion = userData[FirebaseConstants.fieldProfileCompletion] as int?;
    return completion != null && completion >= 100;
  }

  /// Get user role
  Future<String?> getUserRole() async {
    final userData = await getCurrentUserData();
    return userData?[FirebaseConstants.fieldRole] as String?;
  }

  // ==================== SIGN OUT ====================

  /// Sign out
  Future<void> signOut() async {
    final userId = currentUserId;

    // Update online status before signing out
    if (userId != null) {
      await _updateOnlineStatus(userId, false);
    }

    if (_auth != null) {
      await _auth!.signOut();
    }
    await _storageService.clearAuthData();
  }

  // ==================== HELPER METHODS ====================

  Future<void> _updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: {
          FirebaseConstants.fieldIsOnline: isOnline,
          FirebaseConstants.fieldLastSeen: FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      debugPrint('Failed to update online status: $e');
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'invalid-verification-code':
        return 'Invalid verification code';
      case 'invalid-verification-id':
        return 'Invalid verification. Please request a new code';
      case 'session-expired':
        return 'Session expired. Please request a new code';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later';
      default:
        return 'An error occurred. Please try again';
    }
  }
}

/// Result class for auth operations
class AuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? message;
  final Map<String, dynamic>? userData;
  final bool isNewUser;

  AuthResult._({
    required this.success,
    this.user,
    this.error,
    this.message,
    this.userData,
    this.isNewUser = false,
  });

  factory AuthResult.success(
    User? user, {
    String? message,
    Map<String, dynamic>? userData,
    bool isNewUser = false,
  }) {
    return AuthResult._(
      success: true,
      user: user,
      message: message,
      userData: userData,
      isNewUser: isNewUser,
    );
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(
      success: false,
      error: error,
    );
  }
}
