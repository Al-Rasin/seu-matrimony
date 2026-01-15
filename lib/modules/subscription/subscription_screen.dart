import 'package:flutter/material.dart';
import '../../app/themes/app_colors.dart';
import '../../app/themes/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Current plan card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Plan', style: AppTextStyles.caption),
                      Text('Free', style: AppTextStyles.h4),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Choose a Plan', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            // Plan cards
            _buildPlanCard(
              title: 'Premium Monthly',
              price: '৳499',
              period: '/month',
              features: [
                'Unlimited profile views',
                'Unlimited interests',
                'See who viewed you',
                'Chat with matches',
                'Video/Voice calls',
              ],
              isPopular: false,
            ),
            const SizedBox(height: 16),
            _buildPlanCard(
              title: 'Premium Yearly',
              price: '৳3999',
              period: '/year',
              features: [
                'All Premium Monthly features',
                'Save 33%',
                'Priority support',
                'Profile boost',
              ],
              isPopular: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required List<String> features,
    required bool isPopular,
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isPopular
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPopular ? AppColors.primary : AppColors.border,
              width: isPopular ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h4),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price,
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.primary)),
                  Text(period, style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 16),
              ...features.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Text(f, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  )),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Subscribe Now',
                onPressed: () {},
                type: isPopular ? ButtonType.primary : ButtonType.outline,
              ),
            ],
          ),
        ),
        if (isPopular)
          Positioned(
            top: -1,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Text(
                'POPULAR',
                style:
                    AppTextStyles.caption.copyWith(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
