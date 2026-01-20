import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'firestore_service.dart';
import '../constants/firebase_constants.dart';

/// Service to handle push notifications using FCM
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
    requestPermissions(); // Ensure permissions are requested
    _setupFCMListeners();
    _setupFirestoreListener();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _firestoreNotificationSubscription?.cancel();
    super.onClose();
  }

  void _setupFirestoreListener() {
    // Listen to auth changes to start/stop listening to notifications
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (user != null) {
        print('NotificationService: User logged in, listening to notifications for ${user.uid}');
        _listenToUserNotifications(user.uid);
      } else {
        print('NotificationService: User logged out, stopping listener');
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
      print('NotificationService: Received update with ${data.length} items');
      
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
          print('NotificationService: Item ${item['id']} diff: $diff seconds');
          
          // Relaxed check to 60 seconds to avoid clock skew issues during test
          if (diff < 60) {
             print('NotificationService: Triggering local notification for ${item['id']}');
             _triggerLocalNotificationIfNew(item);
          }
        } else {
           print('NotificationService: Date is null for ${item['id']}');
        }
      }
    });
  }

  void _triggerLocalNotificationIfNew(Map<String, dynamic> item) {
    final title = item[FirebaseConstants.fieldTitle] as String?;
    final body = item[FirebaseConstants.fieldBody] as String?;
    // Use ID hash as notification ID to avoid duplicates if processed twice
    final id = item['id'].hashCode; 

    if (title != null && body != null) {
       // Show local notification
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
      );
    }
  }

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
      _handleNotificationClick(message.data['path']);
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

  /// Show a local notification manually (e.g. triggered from Firestore listener)
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
    
    const iosDetails = DarwinNotificationDetails();
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  void _handleNotificationClick(String? path) {
    if (path != null && path.isNotEmpty) {
      Get.toNamed(path);
    }
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
