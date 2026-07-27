import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/text_styles.dart';

/// Empty state widget for My Learnings tab.
class EmptyLearningWidget extends StatelessWidget {
  const EmptyLearningWidget({
    super.key,
    required this.onExploreCourses,
  });

  final VoidCallback onExploreCourses;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.school_outlined,
                  size: 48,
                  color: AppColors.navy,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'No courses yet',
              style: AppTextStyles.title.copyWith(color: AppColors.navy),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            Text(
              'Purchase a course from the Store to begin learning.',
              style: AppTextStyles.body.copyWith(color: AppColors.slate),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            ElevatedButton.icon(
              onPressed: onExploreCourses,
              icon: const Icon(Icons.storefront_rounded, size: 18),
              label: const Text('Explore Courses'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
