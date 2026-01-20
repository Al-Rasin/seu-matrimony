import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/routes/app_routes.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import '../constants/firebase_constants.dart';

/// Service to handle push notifications using FCM and local notifications
class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  final AuthService _authService = Get.find<AuthService>();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  StreamSubscription? _authSubscription;
  StreamSubscription? _firestoreNotificationSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeLocalNotifications();
    requestPermissions();
    _setupFCMListeners();
    _setupFirestoreListener();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _firestoreNotificationSubscription?.cancel();
    super.onClose();
  }

  // ==================== LOCAL NOTIFICATIONS SETUP ====================

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        _handleNotificationClick(details.payload);
      },
    );
  }

  void _handleNotificationClick(String? payload) {
    if (payload != null) {
      debugPrint('NotificationService: Handling click payload: $payload');
      
      if (payload.startsWith(AppRoutes.profileDetail)) {
        final uri = Uri.parse(payload);
        final id = uri.queryParameters['id'];
        if (id != null) {
           Get.toNamed(AppRoutes.profileDetail, arguments: {'matchId': id});
        }
      } else if (payload.isNotEmpty) {
        Get.toNamed(payload);
      }
    }
  }

  // ==================== FIRESTORE LISTENER (REAL-TIME ALERTS) ====================

  void _setupFirestoreListener() {
    // Listen to auth changes to start/stop listening to notifications
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        debugPrint('NotificationService: User logged in, listening to notifications for ${user.uid}');
        _listenToUserNotifications(user.uid);
      } else {
        debugPrint('NotificationService: User logged out, stopping listener');
        _firestoreNotificationSubscription?.cancel();
      }
    });
  }

  void _listenToUserNotifications(String userId) {
    _firestoreNotificationSubscription?.cancel();
    
    // Listen for new notifications added to Firestore
    _firestoreNotificationSubscription = _firestoreService.queryStream(
      collection: FirebaseConstants.notificationsCollection,
      filters: [
        QueryFilter(
          field: FirebaseConstants.fieldUserId,
          operator: QueryOperator.isEqualTo,
          value: userId,
        ),
      ],
      orderBy: FirebaseConstants.fieldCreatedAt,
      descending: true,
      limit: 10,
    ).listen((data) {
      debugPrint('NotificationService: Received update with ${data.length} items');
      
      final now = DateTime.now();
      for (final item in data) {
        final createdAt = item[FirebaseConstants.fieldCreatedAt];
        DateTime? date;
        if (createdAt is Timestamp) {
          date = createdAt.toDate();
        } else if (createdAt is String) {
          date = DateTime.tryParse(createdAt);
        }

        if (date != null) {
          final diff = now.difference(date).inSeconds.abs();
          
          // Check if notification is new (within last 60 seconds)
          if (diff < 60) {
             debugPrint('NotificationService: Triggering local notification for ${item['id']}');
             _triggerLocalNotificationIfNew(item);
          }
        }
      }
    });
  }

  void _triggerLocalNotificationIfNew(Map<String, dynamic> item) {
    final title = item[FirebaseConstants.fieldTitle] as String?;
    final body = item[FirebaseConstants.fieldBody] as String?;
    final id = item['id'].hashCode;
    final data = item[FirebaseConstants.fieldData] as Map<String, dynamic>?;
    final type = item[FirebaseConstants.fieldType] as String?;

    String? payload;
    if (data != null && data['id'] != null) {
      final targetId = data['id'];
      if (type == 'interest_received' || type == 'interest_accepted') {
        // Navigate to profile detail of the person who acted
        payload = '${AppRoutes.profileDetail}?id=$targetId';
      }
    }

    if (title != null && body != null) {
       const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const notificationDetails = NotificationDetails(android: androidDetails);
      
      _localNotifications.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    }
  }

  // ==================== FCM SETUP ====================

  void _setupFCMListeners() {
    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // Listen to notification clicks when app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      // Parse payload from FCM data if needed, or path
      if (message.data['path'] != null) {
        Get.toNamed(message.data['path']);
      }
    });
  }

  Future<void> requestPermissions() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      _saveToken();
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }

  Future<void> _saveToken() async {
    String? token = await _fcm.getToken();
    if (token != null) {
      debugPrint('FCM Token: $token');
      final userId = _authService.currentUserId;
      if (userId != null) {
        await _firestoreService.update(
          collection: FirebaseConstants.usersCollection,
          documentId: userId,
          data: {
            FirebaseConstants.fieldFcmToken: token,
          },
        );
      }
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const iosDetails = DarwinNotificationDetails();
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: message.data['path'],
    );
  }

  /// Show a local notification manually (public method)
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Save notification to Firestore (for history)
  Future<void> saveNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestoreService.create(
        collection: FirebaseConstants.notificationsCollection,
        data: {
          FirebaseConstants.fieldUserId: userId,
          FirebaseConstants.fieldType: type,
          FirebaseConstants.fieldTitle: title,
          FirebaseConstants.fieldBody: body,
          FirebaseConstants.fieldData: data,
          FirebaseConstants.fieldIsRead: false,
          FirebaseConstants.fieldCreatedAt: FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }
}