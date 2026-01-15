import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'matches_controller.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MatchesController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => Get.toNamed('/filters'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by criteria',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: controller.onSearchChanged,
            ),
          ),
          // Filter tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
                  children: [
                    _buildFilterChip('Filters', controller),
                    _buildFilterChip('Match Preference', controller),
                    _buildFilterChip('Save', controller),
                  ],
                )),
          ),
          const SizedBox(height: 16),
          // Matches list
          Expanded(
            child: Obx(() => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.matches.isEmpty
                    ? const Center(child: Text('No matches found'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.matches.length,
                        itemBuilder: (context, index) {
                          return _buildMatchCard(
                              controller.matches[index], controller);
                        },
                      )),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, MatchesController controller) {
    final isSelected = controller.selectedFilter.value == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.selectFilter(label),
        selectedColor: AppColors.primary.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primary,
      ),
    );
  }

  Widget _buildMatchCard(
      Map<String, dynamic> match, MatchesController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Profile image and basic info
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Icon(Icons.person, size: 80, color: Colors.grey.shade400),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match['name'] ?? 'Unknown',
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip(Icons.cake, '${match['age'] ?? 0} yrs'),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                        Icons.height, '${match['height'] ?? 0} cm'),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.school, match['education'] ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Interested with this profile?',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            controller.sendInterest(match['id'], true),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: const BorderSide(color: AppColors.success),
                        ),
                        child: const Text('Yes, Interested'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            controller.sendInterest(match['id'], false),
                        child: const Text('No'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.iconSecondary),
        const SizedBox(width: 4),
        Text(text, style: AppTextStyles.caption),
      ],
    );
  }
}
