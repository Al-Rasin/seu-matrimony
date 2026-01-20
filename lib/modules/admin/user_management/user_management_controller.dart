import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/firebase_constants.dart';

enum UserFilter { all, pending, verified }

class UserManagementController extends GetxController with GetSingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();

  final users = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final selectedFilter = UserFilter.all.obs;
  
  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
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
    } catch (e) {
      Get.snackbar('Error', 'Failed to load users');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredUsers {
    var list = users.toList();

    // Filter by Tab
    if (selectedFilter.value == UserFilter.pending) {
      list = list.where((u) => u[FirebaseConstants.fieldIsVerified] != true).toList();
    } else if (selectedFilter.value == UserFilter.verified) {
      list = list.where((u) => u[FirebaseConstants.fieldIsVerified] == true).toList();
    }

    // Filter by Search
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      list = list.where((u) {
        final name = (u[FirebaseConstants.fieldFullName] ?? '').toString().toLowerCase();
        final email = (u[FirebaseConstants.fieldEmail] ?? '').toString().toLowerCase();
        final phone = (u[FirebaseConstants.fieldPhone] ?? '').toString().toLowerCase();
        return name.contains(query) || email.contains(query) || phone.contains(query);
      }).toList();
    }

    return list;
  }

  Future<void> verifyUser(String userId, bool isVerified) async {
    try {
      await _firestoreService.update(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
        data: {FirebaseConstants.fieldIsVerified: isVerified},
      );
      
      // Update local state
      final index = users.indexWhere((u) => u['id'] == userId);
      if (index != -1) {
        final updatedUser = Map<String, dynamic>.from(users[index]);
        updatedUser[FirebaseConstants.fieldIsVerified] = isVerified;
        users[index] = updatedUser;
        users.refresh();
      }
      
      Get.snackbar(
        'Success', 
        isVerified ? 'User verified successfully' : 'User verification revoked',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar('Error', 'Action failed');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestoreService.delete(
        collection: FirebaseConstants.usersCollection,
        documentId: userId,
      );
      users.removeWhere((u) => u['id'] == userId);
      Get.snackbar('Success', 'User deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user');
    }
  }
}
