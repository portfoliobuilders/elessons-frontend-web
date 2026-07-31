import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/text_styles.dart';
import '../../models/api/learning_models.dart';
import '../common/progress_track.dart';
import 'lesson_tile.dart';

/// Expandable Module accordion card for Subject Learning Dashboard.
class ModuleProgressCard extends StatefulWidget {
  const ModuleProgressCard({
    super.key,
    required this.module,
    required this.onSelectLesson,
  });

  final ModuleModel module;
  final ValueChanged<LessonModel> onSelectLesson;

  @override
  State<ModuleProgressCard> createState() => _ModuleProgressCardState();
}

class _ModuleProgressCardState extends State<ModuleProgressCard>
    with SingleTickerProviderStateMixin {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = !widget.module.isLocked && widget.module.moduleNumber == 1;
  }

  @override
  Widget build(BuildContext context) {
    final mod = widget.module;
    final bool isCompleted = mod.isCompleted;
    final bool isLocked = mod.isLocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.4)
              : AppColors.borderSoft,
          width: 1.5,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: isLocked ? null : () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.successBg
                              : isLocked
                                  ? AppColors.surfaceAlt
                                  : AppColors.navy.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                  size: 22,
                                )
                              : isLocked
                                  ? const Icon(
                                      Icons.lock_outline_rounded,
                                      color: AppColors.muted,
                                      size: 18,
                                    )
                                  : Text(
                                      '${mod.moduleNumber}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.navy,
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'MODULE ${mod.moduleNumber}',
                              style: AppTextStyles.caption.copyWith(
                                color: isCompleted
                                    ? AppColors.success
                                    : AppColors.mutedAlt,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              mod.title,
                              style: AppTextStyles.heading.copyWith(
                                fontSize: 14.5,
                                color: isLocked ? AppColors.muted : AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Locked',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10.5,
                              color: AppColors.muted,
                            ),
                          ),
                        )
                      else
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.navy,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        '${mod.completedLessons}/${mod.totalLessons} Lessons · ${mod.estimatedMinutes} mins',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.muted,
                        ),
                      ),
                      Text(
                        '${mod.progressPercent}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ProgressTrack(
                    value: (mod.progressPercent / 100).clamp(0.0, 1.0),
                    fillColor:
                        isCompleted ? AppColors.success : AppColors.navy,
                  ),
                ],
              ),
            ),
          ),

          if (_expanded && !isLocked) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: mod.lessons
                    .map(
                      (lesson) => LessonTile(
                        lesson: lesson,
                        onTap: () => widget.onSelectLesson(lesson),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
