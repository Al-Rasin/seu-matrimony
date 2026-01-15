import 'package:get/get.dart';

class FiltersController extends GetxController {
  final minAge = 18.obs;
  final maxAge = 40.obs;
  final minHeight = 150.0.obs;
  final maxHeight = 180.0.obs;
  final selectedPreferences = <String>[].obs;

  void togglePreference(String preference) {
    if (selectedPreferences.contains(preference)) {
      selectedPreferences.remove(preference);
    } else {
      selectedPreferences.add(preference);
    }
  }

  void resetFilters() {
    minAge.value = 18;
    maxAge.value = 40;
    minHeight.value = 150.0;
    maxHeight.value = 180.0;
    selectedPreferences.clear();
  }

  void applyFilters() {
    // Implement filter application logic
  }
}
