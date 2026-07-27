import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/text_styles.dart';
import '../../models/api/learning_models.dart';

/// Individual lesson tile inside module expansion.
class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.onTap,
  });

  final LessonModel lesson;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = lesson.isCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.successBg
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.play_arrow_rounded,
                    size: 18,
                    color: isCompleted ? AppColors.success : AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 13,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: <Widget>[
                        _badge(
                          icon: Icons.timer_outlined,
                          label: '${lesson.durationMinutes}m',
                          color: AppColors.mutedAlt,
                        ),
                        if (lesson.hasQuiz)
                          _badge(
                            icon: Icons.quiz_outlined,
                            label: 'Quiz',
                            color: AppColors.purple,
                          ),
                        if (lesson.hasAssignment)
                          _badge(
                            icon: Icons.assignment_outlined,
                            label: 'Assignment',
                            color: AppColors.googleBlue,
                          ),
                        if (lesson.notesUrl != null)
                          _badge(
                            icon: Icons.description_outlined,
                            label: 'Notes',
                            color: AppColors.successDeep,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              Text(
                isCompleted ? 'Watch Again' : 'Watch',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isCompleted ? AppColors.slate : AppColors.navy,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
