import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/match_model.dart';
import '../../data/models/paginated_response.dart';
import '../../data/repositories/match_repository.dart';
import '../../data/repositories/auth_repository.dart';
import 'dart:async';

/// Filter tab options
enum MatchTab { all, matchPreference, saved, sentInterests, receivedInterests }

class MatchesController extends GetxController {
  final MatchRepository _matchRepository = Get.find<MatchRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // Matches list
  final matches = <MatchModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Pagination
  int _currentPage = 1;
  final int _perPage = 10;
  bool _hasMorePages = true;

  // Search & Filters
  final searchQuery = ''.obs;
  final searchController = TextEditingController();
  final currentFilter = Rx<MatchFilter>(MatchFilter.empty);
  final selectedTab = MatchTab.all.obs;

  // Stream subscriptions
  StreamSubscription? _interestsSubscription;

  // Scroll controller for pagination
  late ScrollController scrollController;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController()..addListener(_onScroll);
    loadMatches();
  }

  @override
  void onClose() {
    _interestsSubscription?.cancel();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  /// Load matches based on current tab and filters
  Future<void> loadMatches({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
      matches.clear();
    }

    if (isLoading.value || (!_hasMorePages && !refresh)) return;

    // Cancel existing subscription when loading new tab
    _interestsSubscription?.cancel();

    if (selectedTab.value == MatchTab.sentInterests) {
      _listenToSentInterests();
      return;
    }

    if (selectedTab.value == MatchTab.receivedInterests) {
      _listenToReceivedInterests();
      return;
    }

    try {
      isLoading.value = true;
      hasError.value = false;

      PaginatedResponse<MatchModel> response;

      switch (selectedTab.value) {
        case MatchTab.all:
          if (searchQuery.value.isNotEmpty) {
            response = await _matchRepository.searchMatches(
              query: searchQuery.value,
              page: _currentPage,
              perPage: _perPage,
              filter: currentFilter.value.hasActiveFilters ? currentFilter.value : null,
            );
          } else {
            response = await _matchRepository.getMatches(
              page: _currentPage,
              perPage: _perPage,
              filter: currentFilter.value.hasActiveFilters ? currentFilter.value : null,
            );
          }
          break;
        case MatchTab.matchPreference:
          response = await _matchRepository.getRecommendedMatches(
            page: _currentPage,
            perPage: _perPage,
          );
          break;
        case MatchTab.saved:
          response = await _matchRepository.getShortlistedMatches(
            page: _currentPage,
            perPage: _perPage,
          );
          break;
        default:
          response = PaginatedResponse(items: [], pagination: PaginationMeta.empty());
      }

      if (_currentPage == 1) {
        matches.value = response.items;
      } else {
        matches.addAll(response.items);
      }

      _hasMorePages = response.hasMore;
      _currentPage++;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _listenToSentInterests() {
    isLoading.value = true;
    _interestsSubscription = _matchRepository.streamSentInterests().listen((list) {
      matches.value = list;
      isLoading.value = false;
      _hasMorePages = false; // Streams handle all data for now
    });
  }

  void _listenToReceivedInterests() {
    isLoading.value = true;
    _interestsSubscription = _matchRepository.streamReceivedInterests().listen((list) {
      matches.value = list;
      isLoading.value = false;
      _hasMorePages = false;
    });
  }

  /// Load more matches (pagination)
  Future<void> loadMoreMatches() async {
    if (isLoadingMore.value || !_hasMorePages) return;

    try {
      isLoadingMore.value = true;
      await loadMatches();
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Handle scroll for infinite pagination
  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMoreMatches();
    }
  }

  /// Refresh matches list
  Future<void> refreshMatches() async {
    await loadMatches(refresh: true);
  }

  /// Change tab
  void selectTab(MatchTab tab) {
    if (selectedTab.value == tab) return;
    selectedTab.value = tab;
    loadMatches(refresh: true);
  }

  /// Search matches
  void onSearchChanged(String query) {
    searchQuery.value = query;
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (searchQuery.value == query) {
        loadMatches(refresh: true);
      }
    });
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadMatches(refresh: true);
  }

  /// Apply filters
  void applyFilters(MatchFilter filter) {
    currentFilter.value = filter;
    loadMatches(refresh: true);
  }

  /// Clear filters
  void clearFilters() {
    currentFilter.value = MatchFilter.empty;
    loadMatches(refresh: true);
  }

  /// Send interest to a match
  Future<void> sendInterest(String matchId) async {
    if (!_checkAdminVerification()) return;

    try {
      final success = await _matchRepository.sendInterest(matchId);
      if (success) {
        // Update local state
        final index = matches.indexWhere((m) => m.id == matchId);
        if (index != -1) {
          matches[index] = matches[index].copyWith(
            interestStatus: InterestStatus.sent,
          );
        }
        Get.snackbar(
          'Success',
          'Interest sent successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send interest',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Skip/decline a match (just removes from view)
  void skipMatch(String matchId) {
    matches.removeWhere((m) => m.id == matchId);
  }

  /// Toggle shortlist
  Future<void> toggleShortlist(String matchId) async {
    if (!_checkAdminVerification()) return;

    final index = matches.indexWhere((m) => m.id == matchId);
    if (index == -1) return;

    final match = matches[index];
    final isCurrentlyShortlisted = match.isShortlisted;

    try {
      bool success;
      if (isCurrentlyShortlisted) {
        success = await _matchRepository.removeFromShortlist(matchId);
      } else {
        success = await _matchRepository.addToShortlist(matchId);
      }

      if (success) {
        matches[index] = match.copyWith(isShortlisted: !isCurrentlyShortlisted);
        Get.snackbar(
          'Success',
          isCurrentlyShortlisted ? 'Removed from shortlist' : 'Added to shortlist',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update shortlist',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Accept interest
  Future<void> acceptInterest(String matchId) async {
    if (!_checkAdminVerification()) return;

    try {
      final success = await _matchRepository.acceptInterest(matchId);
      if (success) {
        final index = matches.indexWhere((m) => m.id == matchId);
        if (index != -1) {
          matches[index] = matches[index].copyWith(
            interestStatus: InterestStatus.accepted,
          );
        }
        Get.snackbar(
          'Success',
          'Interest accepted!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept interest',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Reject interest
  Future<void> rejectInterest(String matchId) async {
    if (!_checkAdminVerification()) return;

    try {
      final success = await _matchRepository.rejectInterest(matchId);
      if (success) {
        matches.removeWhere((m) => m.id == matchId);
        Get.snackbar(
          'Info',
          'Interest declined',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject interest',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Navigate to profile detail
  void viewProfile(String matchId) {
    Get.toNamed('/profile-detail', arguments: {'matchId': matchId});
  }

  /// Navigate to filters screen
  void openFilters() {
    Get.toNamed('/filters', arguments: {'currentFilter': currentFilter.value});
  }

  /// Check if user is verified by admin
  bool _checkAdminVerification() {
    if (!_authRepository.isCurrentUserAdminVerified) {
      Get.snackbar(
        'Account Not Verified',
        'Your account is pending verification by admin. You can complete your profile while waiting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return false;
    }
    return true;
  }

  /// Get tab display name
  String getTabName(MatchTab tab) {
    switch (tab) {
      case MatchTab.all:
        return 'All';
      case MatchTab.matchPreference:
        return 'For You';
      case MatchTab.saved:
        return 'Saved';
      case MatchTab.sentInterests:
        return 'Sent';
      case MatchTab.receivedInterests:
        return 'Received';
    }
  }
}
