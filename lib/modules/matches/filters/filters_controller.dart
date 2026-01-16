import 'package:get/get.dart';
import '../../../data/models/filter_model.dart';
import '../matches_controller.dart';

class FiltersController extends GetxController {
  // Range filters
  final minAge = 18.obs;
  final maxAge = 40.obs;
  final minHeight = 150.0.obs;
  final maxHeight = 190.0.obs;

  // Dropdown filters
  final selectedReligion = ''.obs;
  final selectedMaritalStatus = ''.obs;
  final selectedEducation = ''.obs;
  final selectedCity = ''.obs;
  final selectedDepartment = ''.obs;

  // Toggle filters
  final verifiedOnly = false.obs;
  final withPhotoOnly = false.obs;
  final onlineOnly = false.obs;

  // Filter options
  final religions = [
    '',
    'Islam',
    'Hinduism',
    'Christianity',
    'Buddhism',
    'Other',
  ];

  final maritalStatuses = [
    '',
    'Never Married',
    'Divorced',
    'Widowed',
    'Awaiting Divorce',
  ];

  final educationLevels = [
    '',
    'High School',
    'Diploma',
    'Bachelors',
    'Masters',
    'PhD',
    'Other',
  ];

  final departments = [
    '',
    'CSE',
    'EEE',
    'BBA',
    'MBA',
    'Civil',
    'Pharmacy',
    'Architecture',
    'English',
    'Law',
    'Other',
  ];

  final cities = [
    '',
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Rangpur',
    'Mymensingh',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    _loadCurrentFilters();
  }

  void _loadCurrentFilters() {
    // Load current filters from MatchesController if available
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['currentFilter'] != null) {
      final currentFilter = args['currentFilter'] as MatchFilter;
      if (currentFilter.minAge != null) minAge.value = currentFilter.minAge!;
      if (currentFilter.maxAge != null) maxAge.value = currentFilter.maxAge!;
      if (currentFilter.minHeight != null) minHeight.value = currentFilter.minHeight!;
      if (currentFilter.maxHeight != null) maxHeight.value = currentFilter.maxHeight!;
      if (currentFilter.religion != null) selectedReligion.value = currentFilter.religion!;
      if (currentFilter.maritalStatus != null) selectedMaritalStatus.value = currentFilter.maritalStatus!;
      if (currentFilter.education != null) selectedEducation.value = currentFilter.education!;
      if (currentFilter.city != null) selectedCity.value = currentFilter.city!;
      if (currentFilter.department != null) selectedDepartment.value = currentFilter.department!;
      if (currentFilter.verifiedOnly != null) verifiedOnly.value = currentFilter.verifiedOnly!;
      if (currentFilter.withPhotoOnly != null) withPhotoOnly.value = currentFilter.withPhotoOnly!;
      if (currentFilter.onlineOnly != null) onlineOnly.value = currentFilter.onlineOnly!;
    }
  }

  void resetFilters() {
    minAge.value = 18;
    maxAge.value = 40;
    minHeight.value = 150.0;
    maxHeight.value = 190.0;
    selectedReligion.value = '';
    selectedMaritalStatus.value = '';
    selectedEducation.value = '';
    selectedCity.value = '';
    selectedDepartment.value = '';
    verifiedOnly.value = false;
    withPhotoOnly.value = false;
    onlineOnly.value = false;
  }

  void applyFilters() {
    final filter = MatchFilter(
      minAge: minAge.value != 18 ? minAge.value : null,
      maxAge: maxAge.value != 40 ? maxAge.value : null,
      minHeight: minHeight.value != 150.0 ? minHeight.value : null,
      maxHeight: maxHeight.value != 190.0 ? maxHeight.value : null,
      religion: selectedReligion.value.isNotEmpty ? selectedReligion.value : null,
      maritalStatus: selectedMaritalStatus.value.isNotEmpty ? selectedMaritalStatus.value : null,
      education: selectedEducation.value.isNotEmpty ? selectedEducation.value : null,
      city: selectedCity.value.isNotEmpty ? selectedCity.value : null,
      department: selectedDepartment.value.isNotEmpty ? selectedDepartment.value : null,
      verifiedOnly: verifiedOnly.value ? true : null,
      withPhotoOnly: withPhotoOnly.value ? true : null,
      onlineOnly: onlineOnly.value ? true : null,
    );

    // Apply to MatchesController if available
    if (Get.isRegistered<MatchesController>()) {
      Get.find<MatchesController>().applyFilters(filter);
    }
  }

  bool get hasActiveFilters {
    return minAge.value != 18 ||
        maxAge.value != 40 ||
        minHeight.value != 150.0 ||
        maxHeight.value != 190.0 ||
        selectedReligion.value.isNotEmpty ||
        selectedMaritalStatus.value.isNotEmpty ||
        selectedEducation.value.isNotEmpty ||
        selectedCity.value.isNotEmpty ||
        selectedDepartment.value.isNotEmpty ||
        verifiedOnly.value ||
        withPhotoOnly.value ||
        onlineOnly.value;
  }

  int get activeFilterCount {
    int count = 0;
    if (minAge.value != 18 || maxAge.value != 40) count++;
    if (minHeight.value != 150.0 || maxHeight.value != 190.0) count++;
    if (selectedReligion.value.isNotEmpty) count++;
    if (selectedMaritalStatus.value.isNotEmpty) count++;
    if (selectedEducation.value.isNotEmpty) count++;
    if (selectedCity.value.isNotEmpty) count++;
    if (selectedDepartment.value.isNotEmpty) count++;
    if (verifiedOnly.value) count++;
    if (withPhotoOnly.value) count++;
    if (onlineOnly.value) count++;
    return count;
  }
}
