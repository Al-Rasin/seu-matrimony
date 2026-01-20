import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/firebase_constants.dart';

enum UserFilter { all, pending, verified, suspended, active }
enum SortOption { newest, oldest, nameAsc, nameDesc }

class UserManagementController extends GetxController with GetSingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final users = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedFilter = UserFilter.all.obs;
  final selectedSort = SortOption.newest.obs;
  final selectedUser = Rxn<Map<String, dynamic>>();

  // Stats
  final totalCount = 0.obs;
  final pendingCount = 0.obs;
  final verifiedCount = 0.obs;
  final suspendedCount = 0.obs;
  final activeCount = 0.obs;

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(() {
      switch (tabController.index) {
        case 0:
          selectedFilter.value = UserFilter.all;
          break;
        case 1:
          selectedFilter.value = UserFilter.pending;
          break;
        case 2:
          selectedFilter.value = UserFilter.verified;
          break;
        case 3:
          selectedFilter.value = UserFilter.active;
          break;
        case 4:
          selectedFilter.value = UserFilter.suspended;
          break;
      }
    });

    // Check if arguments passed to pre-select tab
    if (Get.arguments != null && Get.arguments['initialIndex'] != null) {
      final index = Get.arguments['initialIndex'] as int;
      tabController.animateTo(index);
    }

    loadUsers();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      final results = await _firestoreService.getAll(
        collection: FirebaseConstants.usersCollection,
        orderBy: FirebaseConstants.fieldCreatedAt,
        descending: true,
      );
      users.value = results;
      _calculateStats();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    totalCount.value = users.length;
    pendingCount.value = users.where((u) => u[FirebaseConstants.fieldIsVerified] != true).length;
    verifiedCount.value = users.where((u) => u[FirebaseConstants.fieldIsVerified] == true).length;
    suspendedCount.value = users.where((u) => u['profileStatus'] == 'suspended').length;
    activeCount.value = users.where((u) => u['profileStatus'] == 'active').length;
  }

  List<Map<String, dynamic>> get filteredUsers {
    var list = users.toList();

    // Filter by Tab
    switch (selectedFilter.value) {
      case UserFilter.pending:
        list = list.where((u) => u[FirebaseConstants.fieldIsVerified] != true).toList();
        break;
      case UserFilter.verified:
        list = list.where((u) => u[FirebaseConstants.fieldIsVerified] == true).toList();
        break;
      case UserFilter.active:
        list = list.where((u) => u['profileStatus'] == 'active').toList();
        break;
      case UserFilter.suspended:
        list = list.where((u) => u['profileStatus'] == 'suspended').toList();
        break;
      case UserFilter.all:
      default:
        break;
    }

    // Filter by Search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((u) {
        final name = (u[FirebaseConstants.fieldFullName] ?? '').toString().toLowerCase();
        final email = (u[FirebaseConstants.fieldEmail] ?? '').toString().toLowerCase();
        final phone = (u[FirebaseConstants.fieldPhone] ?? '').toString().toLowerCase();
        final studentId = (u[FirebaseConstants.fieldStudentId] ?? '').toString().toLowerCase();
        final department = (u[FirebaseConstants.fieldDepartment] ?? '').toString().toLowerCase();
        return name.contains(query) ||
               email.contains(query) ||
               phone.contains(query) ||
               studentId.contains(query) ||
               department.contains(query);
      }).toList();
    }

    // Sort
    switch (selectedSort.value) {
      case SortOption.newest:
        list.sort((a, b) => _compareTimestamps(b['createdAt'], a['createdAt']));
        break;
      case SortOption.oldest:
        list.sort((a, b) => _compareTimestamps(a['createdAt'], b['createdAt']));
        break;
      case SortOption.nameAsc:
        list.sort((a, b) => (a[FirebaseConstants.fieldFullName] ?? '').toString()
            .compareTo((b[FirebaseConstants.fieldFullName] ?? '').toString()));
        break;
      case SortOption.nameDesc:
        list.sort((a, b) => (b[FirebaseConstants.fieldFullName] ?? '').toString()
            .compareTo((a[FirebaseConstants.fieldFullName] ?? '').toString()));
        break;
    }

    return list;
  }

  int _compareTimestamps(dynamic a, dynamic b) {
    DateTime? dateA;
    DateTime? dateB;

    if (a is Timestamp) dateA = a.toDate();
    else if (a is DateTime) dateA = a;

    if (b is Timestamp) dateB = b.toDate();
    else if (b is DateTime) dateB = b;

    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return 1;
    if (dateB == null) return -1;

    return dateA.compareTo(dateB);
  }

  Future<void> verifyUser(String userId, bool isVerified) async {
    try {
      await _firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: {
          FirebaseConstants.fieldIsVerified: isVerified,
          FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
        },
      );

      // Update local state
      _updateLocalUser(userId, {FirebaseConstants.fieldIsVerified: isVerified});

      Get.snackbar(
        'Success',
        isVerified ? 'User verified successfully' : 'User verification revoked',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar('Error', 'Action failed: $e');
    }
  }

  Future<void> updateProfileStatus(String userId, String status) async {
    try {
      await _firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: {
          'profileStatus': status,
          FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
        },
      );

      // Update local state
      _updateLocalUser(userId, {'profileStatus': status});

      Get.snackbar(
        'Success',
        'Profile status updated to ${status.capitalizeFirst}',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status: $e');
    }
  }

  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: {
          FirebaseConstants.fieldRole: role,
          FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
        },
      );

      // Update local state
      _updateLocalUser(userId, {FirebaseConstants.fieldRole: role});

      Get.snackbar(
        'Success',
        'User role updated to ${_formatRole(role)}',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to update role: $e');
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      // Convert DateTime to Timestamp for Firestore
      final firestoreData = <String, dynamic>{};
      data.forEach((key, value) {
        if (value is DateTime) {
          firestoreData[key] = Timestamp.fromDate(value);
        } else {
          firestoreData[key] = value;
        }
      });

      await _firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: firestoreData,
      );

      // Update local state
      _updateLocalUser(userId, data);

      // Recalculate stats
      _calculateStats();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestoreService.delete(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );
      users.removeWhere((u) => u['id'] == userId);
      _calculateStats();
      Get.snackbar(
        'Success',
        'User deleted successfully',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user: $e');
    }
  }

  Future<void> bulkVerify(List<String> userIds, bool isVerified) async {
    try {
      for (final userId in userIds) {
        await _firestoreService.update(
          collection: FirebaseConstants.usersCollection,
          documentId: userId,
          data: {
            FirebaseConstants.fieldIsVerified: isVerified,
            FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
          },
        );
        _updateLocalUser(userId, {FirebaseConstants.fieldIsVerified: isVerified});
      }
      _calculateStats();
      Get.snackbar(
        'Success',
        '${userIds.length} users ${isVerified ? 'verified' : 'unverified'}',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar('Error', 'Bulk operation failed: $e');
    }
  }

  Future<void> bulkUpdateStatus(List<String> userIds, String status) async {
    try {
      for (final userId in userIds) {
        await _firestoreService.update(
          collection: FirebaseConstants.usersCollection,
          documentId: userId,
          data: {
            'profileStatus': status,
            FirebaseConstants.fieldUpdatedAt: FieldValue.serverTimestamp(),
          },
        );
        _updateLocalUser(userId, {'profileStatus': status});
      }
      _calculateStats();
      Get.snackbar(
        'Success',
        '${userIds.length} users updated to $status',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar('Error', 'Bulk operation failed: $e');
    }
  }

  void _updateLocalUser(String userId, Map<String, dynamic> updates) {
    final index = users.indexWhere((u) => u['id'] == userId);
    if (index != -1) {
      final updatedUser = Map<String, dynamic>.from(users[index]);
      updatedUser.addAll(updates);
      users[index] = updatedUser;
      users.refresh();
      _calculateStats();
    }
  }

  String _formatRole(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'super_admin':
        return 'Super Admin';
      default:
        return 'User';
    }
  }

  Map<String, dynamic>? getUserById(String id) {
    try {
      return users.firstWhere((u) => u['id'] == id);
    } catch (_) {
      return null;
    }
  }
}
