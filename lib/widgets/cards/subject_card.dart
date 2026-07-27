import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/utils/subject_image_helper.dart';
import '../../models/subject.dart';

/// "Recommended for you" grid tile: hatched thumbnail with subject monogram,
/// title, meta line, and a "from ₹…" price.
class SubjectCard extends StatelessWidget {
  const SubjectCard({super.key, required this.subject, this.onTap});

  final Subject subject;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.borderSoft, width: 1.5),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SubjectImageHelper.buildSubjectThumbnail(
              name: subject.name,
              code: subject.code,
              width: double.infinity,
              height: 92,
              radius: AppRadius.xl,
            ),
            const SizedBox(height: 11),
            Text(subject.name, style: AppTextStyles.cardTitle),
            const SizedBox(height: 3),
            Text(
              '${subject.modules} modules · ${subject.lessons} lessons',
              style: AppTextStyles.caption.copyWith(letterSpacing: 0),
            ),
            const SizedBox(height: 8),
            Text('from ₹${_fmt(subject.priceFrom)}', style: AppTextStyles.price),
          ],
        ),
      ),
    );
  }

  static String _fmt(int v) => v.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]},',
      );
}
