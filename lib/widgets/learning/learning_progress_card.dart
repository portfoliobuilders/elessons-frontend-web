import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/subject_image_helper.dart';
import '../../models/api/learning_models.dart';
import '../common/progress_track.dart';
import 'progress_ring.dart';

/// Premium enrolled subject progress card for My Learnings dashboard.
class LearningProgressCard extends StatelessWidget {
  const LearningProgressCard({
    super.key,
    required this.subject,
    required this.onTap,
    required this.onContinue,
  });

  final SubjectModel subject;
  final VoidCallback onTap;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: AppColors.borderSoft, width: 1.5),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                SubjectImageHelper.buildSubjectThumbnail(
                  name: subject.name,
                  code: subject.monogram,
                  width: 76,
                  height: 52,
                  radius: 14,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        subject.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.heading.copyWith(
                          fontSize: 15,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              subject.teacherName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ProgressRing(percent: subject.progressPercent, size: 48),
              ],
            ),
            const SizedBox(height: 14),

            ProgressTrack(value: (subject.progressPercent / 100).clamp(0.0, 1.0)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _statItem(
                    icon: Icons.play_circle_outline_rounded,
                    label: '${subject.completedLessons}/${subject.totalLessons} Lessons',
                  ),
                  Container(width: 1, height: 12, color: AppColors.border),
                  _statItem(
                    icon: Icons.folder_open_rounded,
                    label: '${subject.completedModules}/${subject.totalModules} Modules',
                  ),
                  if (subject.remainingMinutes != null && subject.remainingMinutes! > 0) ...[
                    Container(width: 1, height: 12, color: AppColors.border),
                    _statItem(
                      icon: Icons.timer_outlined,
                      label: '${subject.remainingMinutes}m left',
                    ),
                  ],
                ],
              ),
            ),

            if (subject.lastWatchedLessonTitle != null) ...[
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  const Icon(Icons.history_rounded, size: 14, color: AppColors.slate),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Last: ${subject.lastWatchedLessonTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.bodyText,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),

            InkWell(
              onTap: onContinue,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.navy.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.play_arrow_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Continue Learning',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 13, color: AppColors.navy),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}
