import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/themes/app_colors.dart';

/// Base shimmer container with consistent styling
class ShimmerContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  const ShimmerContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
        shape: shape,
      ),
    );
  }
}

/// Shimmer effect wrapper
class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWrapper({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? AppColors.shimmerBase,
      highlightColor: highlightColor ?? AppColors.shimmerHighlight,
      child: child,
    );
  }
}

/// Match card shimmer for matches list
class MatchCardShimmer extends StatelessWidget {
  const MatchCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: ShimmerWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile image placeholder
            const ShimmerContainer(
              height: 200,
              borderRadius: 16,
            ),
            // Profile info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  const ShimmerContainer(
                    width: 150,
                    height: 20,
                  ),
                  const SizedBox(height: 12),
                  // Basic info row
                  Row(
                    children: [
                      const ShimmerContainer(width: 60, height: 14),
                      const SizedBox(width: 12),
                      const ShimmerContainer(width: 50, height: 14),
                      const SizedBox(width: 12),
                      Expanded(child: ShimmerContainer(height: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Education & Job
                  const ShimmerContainer(
                    width: 200,
                    height: 14,
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(child: ShimmerContainer(height: 40, borderRadius: 8)),
                      const SizedBox(width: 12),
                      Expanded(child: ShimmerContainer(height: 40, borderRadius: 8)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact match card shimmer for horizontal lists (dashboard)
class CompactMatchCardShimmer extends StatelessWidget {
  const CompactMatchCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ShimmerWrapper(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  color: Colors.white,
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerContainer(width: 100, height: 14),
                  const SizedBox(height: 6),
                  const ShimmerContainer(width: 80, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Matches list shimmer - shows multiple card shimmers
class MatchesListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsets padding;

  const MatchesListShimmer({
    super.key,
    this.itemCount = 3,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const MatchCardShimmer(),
    );
  }
}

/// Horizontal matches shimmer for dashboard
class HorizontalMatchesShimmer extends StatelessWidget {
  final int itemCount;
  final double height;

  const HorizontalMatchesShimmer({
    super.key,
    this.itemCount = 4,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) => const CompactMatchCardShimmer(),
      ),
    );
  }
}

/// Profile detail shimmer
class ProfileDetailShimmer extends StatelessWidget {
  const ProfileDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile photo
            const ShimmerContainer(
              height: 350,
              borderRadius: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick info row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickInfoShimmer(),
                        _buildQuickInfoShimmer(),
                        _buildQuickInfoShimmer(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Interest section
                  const ShimmerContainer(height: 80, borderRadius: 12),
                  const SizedBox(height: 24),
                  // Section cards
                  _buildSectionShimmer(),
                  const SizedBox(height: 16),
                  _buildSectionShimmer(),
                  const SizedBox(height: 16),
                  _buildSectionShimmer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInfoShimmer() {
    return Column(
      children: [
        ShimmerContainer(width: 24, height: 24, shape: BoxShape.circle),
        const SizedBox(height: 4),
        const ShimmerContainer(width: 40, height: 14),
        const SizedBox(height: 2),
        const ShimmerContainer(width: 50, height: 12),
      ],
    );
  }

  Widget _buildSectionShimmer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerContainer(width: 120, height: 18),
          const SizedBox(height: 16),
          const ShimmerContainer(height: 14),
          const SizedBox(height: 8),
          const ShimmerContainer(height: 14),
          const SizedBox(height: 8),
          const ShimmerContainer(width: 200, height: 14),
        ],
      ),
    );
  }
}

/// Chat list item shimmer
class ChatListItemShimmer extends StatelessWidget {
  const ChatListItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: ListTile(
        leading: const ShimmerContainer(
          width: 50,
          height: 50,
          shape: BoxShape.circle,
        ),
        title: const ShimmerContainer(width: 120, height: 16),
        subtitle: const ShimmerContainer(width: 180, height: 14),
        trailing: const ShimmerContainer(width: 40, height: 12),
      ),
    );
  }
}

/// Chat list shimmer
class ChatListShimmer extends StatelessWidget {
  final int itemCount;

  const ChatListShimmer({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) => const ChatListItemShimmer(),
    );
  }
}

/// Stats card shimmer for dashboard
class StatsCardShimmer extends StatelessWidget {
  const StatsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const ShimmerContainer(width: 20, height: 20),
                const SizedBox(width: 8),
                const ShimmerContainer(width: 40, height: 24),
              ],
            ),
            const SizedBox(height: 8),
            const ShimmerContainer(width: 80, height: 14),
          ],
        ),
      ),
    );
  }
}

/// Dashboard stats grid shimmer
class StatsGridShimmer extends StatelessWidget {
  const StatsGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: List.generate(4, (_) => const StatsCardShimmer()),
    );
  }
}
