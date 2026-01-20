import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/constants/firebase_constants.dart';
import 'user_management_controller.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<UserManagementController>();
  late Map<String, dynamic> userData;
  late Map<String, TextEditingController> textControllers;

  // Dropdown values
  String? selectedGender;
  String? selectedMaritalStatus;
  String? selectedReligion;
  String? selectedEmploymentType;
  String? selectedHighestEducation;
  String? selectedRole;
  String? selectedProfileStatus;
  bool? isVerified;
  bool? isEmailVerified;
  bool? isCurrentlyStudying;
  bool? hasChildren;
  DateTime? selectedDateOfBirth;

  bool isLoading = false;

  // Dropdown options
  final genderOptions = ['Male', 'Female'];
  final maritalStatusOptions = ['Never Married', 'Divorced', 'Widowed', 'Awaiting Divorce'];
  final religionOptions = ['Islam', 'Hinduism', 'Christianity', 'Buddhism', 'Other'];
  final employmentOptions = ['Employed', 'Self-Employed', 'Business Owner', 'Student', 'Unemployed', 'Not Working'];
  final educationOptions = ['High School', 'Diploma', 'Bachelor\'s Degree', 'Master\'s Degree', 'PhD', 'Other'];
  final roleOptions = ['user', 'admin', 'super_admin'];
  final profileStatusOptions = ['pending', 'active', 'suspended', 'rejected', 'deleted'];

  @override
  void initState() {
    super.initState();
    userData = Map<String, dynamic>.from(Get.arguments as Map<String, dynamic>);
    _initializeControllers();
  }

  void _initializeControllers() {
    textControllers = {
      'fullName': TextEditingController(text: userData[FirebaseConstants.fieldFullName]?.toString() ?? ''),
      'email': TextEditingController(text: userData[FirebaseConstants.fieldEmail]?.toString() ?? ''),
      'phone': TextEditingController(text: userData[FirebaseConstants.fieldPhone]?.toString() ?? ''),
      'studentId': TextEditingController(text: userData[FirebaseConstants.fieldStudentId]?.toString() ?? ''),
      'department': TextEditingController(text: userData[FirebaseConstants.fieldDepartment]?.toString() ?? ''),
      'height': TextEditingController(text: userData[FirebaseConstants.fieldHeight]?.toString() ?? ''),
      'occupation': TextEditingController(text: userData[FirebaseConstants.fieldOccupation]?.toString() ?? ''),
      'companyName': TextEditingController(text: userData['companyName']?.toString() ?? ''),
      'workLocation': TextEditingController(text: userData['workLocation']?.toString() ?? ''),
      'annualIncome': TextEditingController(text: userData['annualIncome']?.toString() ?? ''),
      'currentCity': TextEditingController(text: userData[FirebaseConstants.fieldCurrentCity]?.toString() ?? ''),
      'about': TextEditingController(text: userData[FirebaseConstants.fieldAbout]?.toString() ?? ''),
      'educationDetails': TextEditingController(text: userData['educationDetails']?.toString() ?? ''),
      'numberOfChildren': TextEditingController(text: userData[FirebaseConstants.fieldChildren]?.toString() ?? ''),
      'profileCompletion': TextEditingController(text: userData[FirebaseConstants.fieldProfileCompletion]?.toString() ?? '0'),
    };

    // Initialize dropdown and boolean values
    selectedGender = userData[FirebaseConstants.fieldGender]?.toString();
    selectedMaritalStatus = userData[FirebaseConstants.fieldMaritalStatus]?.toString();
    selectedReligion = userData[FirebaseConstants.fieldReligion]?.toString();
    selectedEmploymentType = userData[FirebaseConstants.fieldEmploymentStatus]?.toString();
    selectedHighestEducation = userData[FirebaseConstants.fieldHighestEducation]?.toString();
    selectedRole = userData[FirebaseConstants.fieldRole]?.toString() ?? 'user';
    selectedProfileStatus = userData['profileStatus']?.toString() ?? 'pending';
    isVerified = userData[FirebaseConstants.fieldIsVerified] == true;
    isEmailVerified = userData[FirebaseConstants.fieldIsEmailVerified] == true;
    isCurrentlyStudying = userData[FirebaseConstants.fieldCurrentlyStudying] == true;
    hasChildren = userData['hasChildren'] == true;

    // Parse date of birth
    final dob = userData[FirebaseConstants.fieldDateOfBirth];
    if (dob != null) {
      if (dob is DateTime) {
        selectedDateOfBirth = dob;
      } else if (dob.toString().isNotEmpty) {
        selectedDateOfBirth = DateTime.tryParse(dob.toString());
      }
    }
  }

  @override
  void dispose() {
    for (var controller in textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        actions: [
          TextButton.icon(
            onPressed: isLoading ? null : _saveChanges,
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              isLoading ? 'Saving...' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Account Settings', Icons.admin_panel_settings),
              _buildAccountSettingsSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Basic Information', Icons.person),
              _buildBasicInfoSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('SEU Details', Icons.school),
              _buildSeuDetailsSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Personal Details', Icons.favorite),
              _buildPersonalDetailsSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('Professional Details', Icons.work),
              _buildProfessionalDetailsSection(),

              const SizedBox(height: 24),
              _buildSectionHeader('About', Icons.info),
              _buildAboutSection(),

              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.h4),
        ],
      ),
    );
  }

  Widget _buildAccountSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdownField(
              label: 'Role',
              value: selectedRole,
              items: roleOptions,
              displayLabels: {'user': 'User', 'admin': 'Admin', 'super_admin': 'Super Admin'},
              onChanged: (value) => setState(() => selectedRole = value),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Profile Status',
              value: selectedProfileStatus,
              items: profileStatusOptions,
              displayLabels: {
                'pending': 'Pending',
                'active': 'Active',
                'suspended': 'Suspended',
                'rejected': 'Rejected',
                'deleted': 'Deleted',
              },
              onChanged: (value) => setState(() => selectedProfileStatus = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchField(
              label: 'Account Verified',
              value: isVerified ?? false,
              onChanged: (value) => setState(() => isVerified = value),
            ),
            _buildSwitchField(
              label: 'Email Verified',
              value: isEmailVerified ?? false,
              onChanged: (value) => setState(() => isEmailVerified = value),
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: textControllers['profileCompletion']!,
              label: 'Profile Completion %',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              controller: textControllers['fullName']!,
              label: 'Full Name',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: textControllers['email']!,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: textControllers['phone']!,
              label: 'Phone',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Gender',
              value: selectedGender,
              items: genderOptions,
              onChanged: (value) => setState(() => selectedGender = value),
            ),
            const SizedBox(height: 16),
            _buildDateField(
              label: 'Date of Birth',
              value: selectedDateOfBirth,
              onChanged: (date) => setState(() => selectedDateOfBirth = date),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeuDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              controller: textControllers['studentId']!,
              label: 'Student ID',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: textControllers['department']!,
              label: 'Department',
            ),
            const SizedBox(height: 16),
            _buildSwitchField(
              label: 'Currently Studying',
              value: isCurrentlyStudying ?? false,
              onChanged: (value) => setState(() => isCurrentlyStudying = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdownField(
              label: 'Marital Status',
              value: selectedMaritalStatus,
              items: maritalStatusOptions,
              onChanged: (value) => setState(() => selectedMaritalStatus = value),
            ),
            const SizedBox(height: 16),
            _buildSwitchField(
              label: 'Has Children',
              value: hasChildren ?? false,
              onChanged: (value) => setState(() => hasChildren = value),
            ),
            if (hasChildren == true) ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: textControllers['numberOfChildren']!,
                label: 'Number of Children',
                keyboardType: TextInputType.number,
              ),
            ],
            const SizedBox(height: 16),
            _buildTextField(
              controller: textControllers['height']!,
              label: 'Height (feet)',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Religion',
              value: selectedReligion,
              items: religionOptions,
              onChanged: (value) => setState(() => selectedReligion = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDropdownField(
              label: 'Highest Education',
              value: selectedHighestEducation,
              items: educationOptions,
              onChanged: (value) => setState(() => selectedHighestEducation = value),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: textControllers['educationDetails']!,
              label: 'Education Details',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Employment Status',
              value: selectedEmploymentType,
              items: employmentOptions,
              onChanged: (value) => setState(() => selectedEmploymentType = value),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: textControllers['occupation']!,
              label: 'Occupation',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: textControllers['companyName']!,
              label: 'Company Name',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: textControllers['workLocation']!,
              label: 'Work Location',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: textControllers['annualIncome']!,
              label: 'Annual Income',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: textControllers['currentCity']!,
              label: 'Current City',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField(
              controller: textControllers['about']!,
              label: 'About / Bio',
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    Map<String, String>? displayLabels,
  }) {
    // Validate that the current value exists in items
    final validValue = items.contains(value) ? value : null;

    return DropdownButtonFormField<String>(
      value: validValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(displayLabels?[item] ?? item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(2000),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null
              ? '${value.day}/${value.month}/${value.year}'
              : 'Select date',
          style: TextStyle(
            color: value != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchField({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Save All Changes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final updatedData = <String, dynamic>{
      FirebaseConstants.fieldFullName: textControllers['fullName']!.text.trim(),
      FirebaseConstants.fieldEmail: textControllers['email']!.text.trim(),
      FirebaseConstants.fieldPhone: textControllers['phone']!.text.trim(),
      FirebaseConstants.fieldGender: selectedGender,
      FirebaseConstants.fieldDateOfBirth: selectedDateOfBirth,
      FirebaseConstants.fieldStudentId: textControllers['studentId']!.text.trim(),
      FirebaseConstants.fieldDepartment: textControllers['department']!.text.trim(),
      FirebaseConstants.fieldCurrentlyStudying: isCurrentlyStudying,
      FirebaseConstants.fieldMaritalStatus: selectedMaritalStatus,
      'hasChildren': hasChildren,
      FirebaseConstants.fieldChildren: hasChildren == true
          ? int.tryParse(textControllers['numberOfChildren']!.text) ?? 0
          : 0,
      FirebaseConstants.fieldHeight: double.tryParse(textControllers['height']!.text),
      FirebaseConstants.fieldReligion: selectedReligion,
      FirebaseConstants.fieldHighestEducation: selectedHighestEducation,
      'educationDetails': textControllers['educationDetails']!.text.trim(),
      FirebaseConstants.fieldEmploymentStatus: selectedEmploymentType,
      FirebaseConstants.fieldOccupation: textControllers['occupation']!.text.trim(),
      'companyName': textControllers['companyName']!.text.trim(),
      'workLocation': textControllers['workLocation']!.text.trim(),
      'annualIncome': textControllers['annualIncome']!.text.trim(),
      FirebaseConstants.fieldCurrentCity: textControllers['currentCity']!.text.trim(),
      FirebaseConstants.fieldAbout: textControllers['about']!.text.trim(),
      FirebaseConstants.fieldRole: selectedRole,
      'profileStatus': selectedProfileStatus,
      FirebaseConstants.fieldIsVerified: isVerified,
      FirebaseConstants.fieldIsEmailVerified: isEmailVerified,
      FirebaseConstants.fieldProfileCompletion: int.tryParse(textControllers['profileCompletion']!.text) ?? 0,
      FirebaseConstants.fieldUpdatedAt: DateTime.now(),
    };

    try {
      final userId = userData['id'];
      await controller.updateUser(userId, updatedData);
      Get.back(result: true);
      Get.snackbar(
        'Success',
        'User updated successfully',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update user: $e',
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
