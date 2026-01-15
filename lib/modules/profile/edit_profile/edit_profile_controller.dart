import 'package:get/get.dart';

class EditProfileController extends GetxController {
  void editBasicDetails() {
    Get.toNamed('/edit-basic-details');
  }

  void editPersonalDetails() {
    Get.toNamed('/edit-personal-details');
  }

  void editProfessionalDetails() {
    Get.toNamed('/edit-professional-details');
  }

  void editFamilyDetails() {
    Get.toNamed('/edit-family-details');
  }

  void editPreferences() {
    Get.toNamed('/edit-preferences');
  }

  void editPhotos() {
    // Implement photo editing
  }
}
