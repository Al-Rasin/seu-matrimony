import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/firestore_service.dart';

class NotificationController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final AuthService _authService = Get.find<AuthService>();

  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  StreamSubscription? _notificationSubscription;

  @override
  void onInit() {
    super.onInit();
    _subscribeToNotifications();
  }

  @override
  void onClose() {
    _notificationSubscription?.cancel();
    super.onClose();
  }

  void _subscribeToNotifications() {
    final userId = _authService.currentUserId;
    print('NotificationController: Subscribing for user: $userId');
    if (userId == null) {
      print('NotificationController: UserId is null, cannot subscribe');
      isLoading.value = false;
      return;
    }

    isLoading.value = true;
    
    // Subscribe to notifications stream
    _notificationSubscription = _firestoreService.queryStream(
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
      limit: 50,
    ).listen((data) {
      print('NotificationController: Received ${data.length} notifications');
      notifications.assignAll(data);
      isLoading.value = false;
    }, onError: (e) {
      print('Error listening to notifications: $e');
      isLoading.value = false;
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _firestoreService.update(
      collection: FirebaseConstants.notificationsCollection,
      documentId: notificationId,
      data: {
        FirebaseConstants.fieldIsRead: true,
      },
    );
  }

  Future<void> markAllAsRead() async {
    final unreadNotifications = notifications.where((n) => n[FirebaseConstants.fieldIsRead] == false).toList();
    
    // Batch update would be better, but FirestoreService might not expose it directly.
    // For now, loop through. Ideally, update FirestoreService to support batch updates.
    for (var notification in unreadNotifications) {
      if (notification['id'] != null) {
        markAsRead(notification['id']);
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    await _firestoreService.delete(
      collection: FirebaseConstants.notificationsCollection,
      documentId: notificationId,
    );
  }
}
