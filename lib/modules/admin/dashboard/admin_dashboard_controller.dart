import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/firebase_constants.dart';

class AdminDashboardController extends GetxController {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  // User stats
  final totalUsers = 0.obs;
  final pendingVerifications = 0.obs;
  final verifiedUsers = 0.obs;
  final activeUsers = 0.obs;
  final suspendedUsers = 0.obs;

  // Other stats
  final totalReports = 0.obs;
  final pendingReports = 0.obs;
  final totalConversations = 0.obs;
  final totalInterests = 0.obs;

  // Recent activity
  final newUsersToday = 0.obs;
  final newUsersThisWeek = 0.obs;
  final newUsersThisMonth = 0.obs;

  // App settings
  final maintenanceMode = false.obs;

  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStats();
    loadAppSettings();
  }

  Future<void> loadStats() async {
    try {
      isLoading.value = true;

      // Load users
      final users = await _firestoreService.getAll(collection: FirebaseConstants.usersCollection);
      totalUsers.value = users.length;

      pendingVerifications.value = users.where((u) => u[FirebaseConstants.fieldIsVerified] != true).length;
      verifiedUsers.value = users.where((u) => u[FirebaseConstants.fieldIsVerified] == true).length;
      activeUsers.value = users.where((u) => u['profileStatus'] == 'active').length;
      suspendedUsers.value = users.where((u) => u['profileStatus'] == 'suspended').length;

      // Calculate new users
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = todayStart.subtract(const Duration(days: 7));
      final monthStart = DateTime(now.year, now.month, 1);

      newUsersToday.value = users.where((u) {
        final createdAt = _parseTimestamp(u[FirebaseConstants.fieldCreatedAt]);
        return createdAt != null && createdAt.isAfter(todayStart);
      }).length;

      newUsersThisWeek.value = users.where((u) {
        final createdAt = _parseTimestamp(u[FirebaseConstants.fieldCreatedAt]);
        return createdAt != null && createdAt.isAfter(weekStart);
      }).length;

      newUsersThisMonth.value = users.where((u) {
        final createdAt = _parseTimestamp(u[FirebaseConstants.fieldCreatedAt]);
        return createdAt != null && createdAt.isAfter(monthStart);
      }).length;

      // Load reports
      final reports = await _firestoreService.getAll(collection: FirebaseConstants.reportsCollection);
      totalReports.value = reports.length;
      pendingReports.value = reports.where((r) => r[FirebaseConstants.fieldStatus] == FirebaseConstants.reportStatusPending).length;

      // Load conversations
      final conversations = await _firestoreService.getAll(collection: FirebaseConstants.conversationsCollection);
      totalConversations.value = conversations.length;

      // Load interests
      final interests = await _firestoreService.getAll(collection: FirebaseConstants.interestsCollection);
      totalInterests.value = interests.length;

    } catch (e) {
      // Handle error silently
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAppSettings() async {
    try {
      final settings = await _firestoreService.getById(
        collection: FirebaseConstants.appSettingsCollection,
        documentId: 'config',
      );

      if (settings != null) {
        maintenanceMode.value = settings['maintenanceMode'] == true;
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> toggleMaintenanceMode(bool value) async {
    try {
      final existing = await _firestoreService.exists(
        collection: FirebaseConstants.appSettingsCollection,
        documentId: 'config',
      );

      final data = {
        'maintenanceMode': value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (existing) {
        await _firestoreService.update(
          collection: FirebaseConstants.appSettingsCollection,
          documentId: 'config',
          data: data,
        );
      } else {
        await _firestoreService.createWithId(
          collection: FirebaseConstants.appSettingsCollection,
          documentId: 'config',
          data: data,
        );
      }

      maintenanceMode.value = value;
    } catch (e) {
      // Handle error
    }
  }

  DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
