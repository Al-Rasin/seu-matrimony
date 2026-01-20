import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/constants/firebase_constants.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = true;
  bool isSaving = false;

  // App Settings
  bool maintenanceMode = false;
  bool registrationEnabled = true;
  bool chatEnabled = true;
  bool callsEnabled = true;
  bool notificationsEnabled = true;
  int maxPhotosPerUser = 6;
  int maxMessageLength = 500;
  int profileCompletionRequired = 60;
  String appVersion = '1.0.0';
  String minAppVersion = '1.0.0';
  String termsUrl = '';
  String privacyUrl = '';
  String supportEmail = '';
  String supportPhone = '';
  String welcomeMessage = '';
  String maintenanceMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() => isLoading = true);
      final settings = await _firestoreService.getById(
        collection: FirebaseConstants.appSettingsCollection,
        documentId: 'config',
      );

      if (settings != null) {
        setState(() {
          maintenanceMode = settings['maintenanceMode'] == true;
          registrationEnabled = settings['registrationEnabled'] != false;
          chatEnabled = settings['chatEnabled'] != false;
          callsEnabled = settings['callsEnabled'] != false;
          notificationsEnabled = settings['notificationsEnabled'] != false;
          maxPhotosPerUser = settings['maxPhotosPerUser'] ?? 6;
          maxMessageLength = settings['maxMessageLength'] ?? 500;
          profileCompletionRequired = settings['profileCompletionRequired'] ?? 60;
          appVersion = settings['appVersion']?.toString() ?? '1.0.0';
          minAppVersion = settings['minAppVersion']?.toString() ?? '1.0.0';
          termsUrl = settings['termsUrl']?.toString() ?? '';
          privacyUrl = settings['privacyUrl']?.toString() ?? '';
          supportEmail = settings['supportEmail']?.toString() ?? '';
          supportPhone = settings['supportPhone']?.toString() ?? '';
          welcomeMessage = settings['welcomeMessage']?.toString() ?? '';
          maintenanceMessage = settings['maintenanceMessage']?.toString() ?? '';
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load settings: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final settingsData = {
        'maintenanceMode': maintenanceMode,
        'registrationEnabled': registrationEnabled,
        'chatEnabled': chatEnabled,
        'callsEnabled': callsEnabled,
        'notificationsEnabled': notificationsEnabled,
        'maxPhotosPerUser': maxPhotosPerUser,
        'maxMessageLength': maxMessageLength,
        'profileCompletionRequired': profileCompletionRequired,
        'appVersion': appVersion,
        'minAppVersion': minAppVersion,
        'termsUrl': termsUrl,
        'privacyUrl': privacyUrl,
        'supportEmail': supportEmail,
        'supportPhone': supportPhone,
        'welcomeMessage': welcomeMessage,
        'maintenanceMessage': maintenanceMessage,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Check if config exists
      final existing = await _firestoreService.exists(
        collection: FirebaseConstants.appSettingsCollection,
        documentId: 'config',
      );

      if (existing) {
        await _firestoreService.update(
          collection: FirebaseConstants.appSettingsCollection,
          documentId: 'config',
          data: settingsData,
        );
      } else {
        await _firestoreService.createWithId(
          collection: FirebaseConstants.appSettingsCollection,
          documentId: 'config',
          data: settingsData,
        );
      }

      Get.snackbar(
        'Success',
        'Settings saved successfully',
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings: $e');
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        actions: [
          TextButton.icon(
            onPressed: isSaving ? null : _saveSettings,
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              isSaving ? 'Saving...' : 'Save',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('App Status', Icons.power_settings_new),
                    _buildCard([
                      _buildSwitchTile(
                        'Maintenance Mode',
                        'Put app in maintenance mode',
                        maintenanceMode,
                        (value) => setState(() => maintenanceMode = value),
                        isDanger: true,
                      ),
                      if (maintenanceMode)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextFormField(
                            initialValue: maintenanceMessage,
                            decoration: const InputDecoration(
                              labelText: 'Maintenance Message',
                              hintText: 'Message to show users during maintenance',
                            ),
                            maxLines: 2,
                            onChanged: (value) => maintenanceMessage = value,
                          ),
                        ),
                    ]),

                    const SizedBox(height: 24),
                    _buildSectionHeader('Feature Toggles', Icons.toggle_on),
                    _buildCard([
                      _buildSwitchTile(
                        'User Registration',
                        'Allow new user registrations',
                        registrationEnabled,
                        (value) => setState(() => registrationEnabled = value),
                      ),
                      _buildSwitchTile(
                        'Chat Feature',
                        'Enable chat between users',
                        chatEnabled,
                        (value) => setState(() => chatEnabled = value),
                      ),
                      _buildSwitchTile(
                        'Voice/Video Calls',
                        'Enable voice and video calls',
                        callsEnabled,
                        (value) => setState(() => callsEnabled = value),
                      ),
                      _buildSwitchTile(
                        'Push Notifications',
                        'Enable push notifications',
                        notificationsEnabled,
                        (value) => setState(() => notificationsEnabled = value),
                      ),
                    ]),

                    const SizedBox(height: 24),
                    _buildSectionHeader('Limits & Requirements', Icons.tune),
                    _buildCard([
                      _buildNumberField(
                        'Max Photos Per User',
                        maxPhotosPerUser,
                        (value) => maxPhotosPerUser = value,
                        min: 1,
                        max: 20,
                      ),
                      _buildNumberField(
                        'Max Message Length',
                        maxMessageLength,
                        (value) => maxMessageLength = value,
                        min: 100,
                        max: 2000,
                      ),
                      _buildNumberField(
                        'Profile Completion Required (%)',
                        profileCompletionRequired,
                        (value) => profileCompletionRequired = value,
                        min: 0,
                        max: 100,
                      ),
                    ]),

                    const SizedBox(height: 24),
                    _buildSectionHeader('App Version', Icons.info_outline),
                    _buildCard([
                      _buildTextField(
                        'Current App Version',
                        appVersion,
                        (value) => appVersion = value,
                      ),
                      _buildTextField(
                        'Minimum Required Version',
                        minAppVersion,
                        (value) => minAppVersion = value,
                        hint: 'Force update if below this version',
                      ),
                    ]),

                    const SizedBox(height: 24),
                    _buildSectionHeader('Support & Legal', Icons.support_agent),
                    _buildCard([
                      _buildTextField(
                        'Support Email',
                        supportEmail,
                        (value) => supportEmail = value,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        'Support Phone',
                        supportPhone,
                        (value) => supportPhone = value,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(
                        'Terms & Conditions URL',
                        termsUrl,
                        (value) => termsUrl = value,
                        keyboardType: TextInputType.url,
                      ),
                      _buildTextField(
                        'Privacy Policy URL',
                        privacyUrl,
                        (value) => privacyUrl = value,
                        keyboardType: TextInputType.url,
                      ),
                    ]),

                    const SizedBox(height: 24),
                    _buildSectionHeader('Welcome Message', Icons.message),
                    _buildCard([
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextFormField(
                          initialValue: welcomeMessage,
                          decoration: const InputDecoration(
                            labelText: 'Welcome Message',
                            hintText: 'Message shown to new users',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                          onChanged: (value) => welcomeMessage = value,
                        ),
                      ),
                    ]),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaving ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Save All Settings',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
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

  Widget _buildCard(List<Widget> children) {
    return Card(
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged, {
    bool isDanger = false,
  }) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: isDanger && value ? Colors.red : null)),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: isDanger ? Colors.red : AppColors.primary,
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    Function(String) onChanged, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    int value,
    Function(int) onChanged, {
    required int min,
    required int max,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Text(label),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > min ? () => setState(() => onChanged(value - 1)) : null,
          ),
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.toString(),
              textAlign: TextAlign.center,
              style: AppTextStyles.labelLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: value < max ? () => setState(() => onChanged(value + 1)) : null,
          ),
        ],
      ),
    );
  }
}
