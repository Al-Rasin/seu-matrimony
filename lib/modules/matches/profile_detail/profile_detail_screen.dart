import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_detail_controller.dart';
import '../../../data/models/match_model.dart';
import '../../../app/themes/app_colors.dart';
import '../../../app/themes/app_text_styles.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileDetailController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        if (controller.hasError.value || controller.profile.value == null) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Profile not found',
            message: controller.errorMessage.value.isNotEmpty
                ? controller.errorMessage.value
                : 'Unable to load profile',
            buttonText: 'Go Back',
            onAction: () => Get.back(),
          );
        }

        final profile = controller.profile.value!;

        return CustomScrollView(
          slivers: [
            // Profile Photo App Bar
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildProfileImage(profile),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                    // Badges
                    Positioned(
                      top: 100,
                      left: 16,
                      child: Row(
                        children: [
                          if (profile.isVerified) _buildBadge('Verified', AppColors.success, Icons.verified),
                          if (profile.isOnline) ...[
                            const SizedBox(width: 8),
                            _buildBadge('Online', Colors.green, Icons.circle, iconSize: 8),
                          ],
                        ],
                      ),
                    ),
                    // Name and basic info at bottom
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: AppTextStyles.h2.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.shortInfo,
                            style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Shortlist button
                Obx(() => IconButton(
                      icon: Icon(
                        controller.isShortlisted.value ? Icons.bookmark : Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      onPressed: controller.toggleShortlist,
                    )),
                // More options
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () => _showOptionsMenu(context, controller),
                ),
              ],
            ),

            // Profile Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Info Row
                    _buildQuickInfoRow(profile),
                    const SizedBox(height: 24),

                    // Interest Action Section
                    _buildInterestSection(profile, controller),
                    const SizedBox(height: 24),

                    // About Section
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      _buildSectionCard(
                        title: 'About',
                        icon: Icons.person_outline,
                        child: Text(
                          profile.bio!,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Basic Details Section
                    _buildSectionCard(
                      title: 'Basic Details',
                      icon: Icons.info_outline,
                      child: Column(
                        children: [
                          _buildDetailRow('Age', profile.ageDisplay),
                          _buildDetailRow('Height', profile.displayHeight ?? 'Not specified'),
                          _buildDetailRow('Religion', profile.religion ?? 'Not specified'),
                          _buildDetailRow('Marital Status', profile.maritalStatus ?? 'Not specified'),
                          _buildDetailRow('Department', profile.department ?? 'Not specified'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location Section
                    _buildSectionCard(
                      title: 'Location',
                      icon: Icons.location_on_outlined,
                      child: Column(
                        children: [
                          _buildDetailRow('Current City', profile.currentCity ?? 'Not specified'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Professional Details Section
                    _buildSectionCard(
                      title: 'Professional Details',
                      icon: Icons.work_outline,
                      child: Column(
                        children: [
                          _buildDetailRow('Education', profile.highestEducation ?? 'Not specified'),
                          _buildDetailRow('Occupation', profile.occupation ?? 'Not specified'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom bar
                  ],
                ),
              ),
            ),
          ],
        );
      }),
      // Bottom Action Bar
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.profile.value == null) {
          return const SizedBox.shrink();
        }

        final profile = controller.profile.value!;
        return _buildBottomActionBar(profile, controller);
      }),
    );
  }

  Widget _buildProfileImage(MatchModel profile) {
    if (profile.profilePhoto != null) {
      try {
        return Image.memory(
          Uri.parse(profile.profilePhoto!).data!.contentAsBytes(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
        );
      } catch (_) {
        return _buildPlaceholderImage();
      }
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.person,
          size: 100,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData icon, {double iconSize = 14}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoRow(MatchModel profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickInfoItem(Icons.cake, profile.ageDisplay, 'Age'),
          _buildVerticalDivider(),
          _buildQuickInfoItem(Icons.height, profile.displayHeight ?? 'N/A', 'Height'),
          _buildVerticalDivider(),
          _buildQuickInfoItem(Icons.location_on, profile.currentCity ?? 'N/A', 'Location'),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildInterestSection(MatchModel profile, ProfileDetailController controller) {
    return Obx(() {
      final status = controller.interestStatus.value;

      switch (status) {
        case InterestStatus.sent:
          return _buildStatusCard(
            'Interest Sent',
            'Waiting for response',
            Icons.check_circle,
            AppColors.primary,
          );

        case InterestStatus.received:
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      '${profile.fullName} is interested in you!',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.acceptInterest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.rejectInterest,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Decline'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );

        case InterestStatus.accepted:
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connected!',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'You can now start a conversation',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: controller.startChat,
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Chat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                ),
              ],
            ),
          );

        case InterestStatus.rejected:
          return _buildStatusCard(
            'Not Interested',
            'You declined this profile',
            Icons.cancel,
            Colors.grey,
          );

        case InterestStatus.none:
        case null:
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Interested with this profile?',
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.sendInterest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Yes, Interested'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.skipProfile,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Skip'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
      }
    });
  }

  Widget _buildStatusCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.h4,
              ),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(MatchModel profile, ProfileDetailController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final status = controller.interestStatus.value;

          if (status == InterestStatus.accepted) {
            return ElevatedButton.icon(
              onPressed: controller.startChat,
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Start Conversation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size(double.infinity, 50),
              ),
            );
          }

          if (status == InterestStatus.sent) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Interest Sent - Waiting for Response',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.skipProfile,
                  icon: const Icon(Icons.close),
                  label: const Text('Skip'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: controller.sendInterest,
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Send Interest'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, ProfileDetailController controller) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                // Implement share
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.orange),
              title: const Text('Block User', style: TextStyle(color: Colors.orange)),
              onTap: () {
                Navigator.pop(context);
                controller.blockUser();
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Report User', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                controller.reportUser();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
