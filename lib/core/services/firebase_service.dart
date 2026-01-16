import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../main.dart' show isFirebaseInitialized;

/// Firebase service for initialization and FCM
/// Note: Firebase Auth operations are in AuthService
/// Note: Firestore operations are in FirestoreService
class FirebaseService extends GetxService {
  FirebaseAuth? _auth;
  FirebaseMessaging? _messaging;

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

  /// Check if Firebase is available
  bool get isAvailable => isFirebaseInitialized;

  User? get currentUser => auth?.currentUser;
  Stream<User?> get authStateChanges =>
      auth?.authStateChanges() ?? Stream.value(null);

  // ==================== FCM METHODS ====================

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

  void onForegroundMessage(void Function(RemoteMessage) handler) {
    if (messaging == null) return;
    FirebaseMessaging.onMessage.listen(handler);
  }

  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    FirebaseMessaging.onMessageOpenedApp.listen(handler);
  }

  Future<RemoteMessage?> getInitialMessage() async {
    return await messaging?.getInitialMessage();
  }
}
