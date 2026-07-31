import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../models/dummy_data.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const lessons = DummyData.literatureLessons;
    
    return AppScaffold(
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Nav
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE7EAF0), width: 1.5),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.chevron_left_rounded, size: 24, color: AppColors.ink),
                  ),
                ),
                Text('Lessons', style: AppTextStyles.heading.copyWith(fontSize: 16)),
                const SizedBox(width: 42), // Balance for centering
              ],
            ),
          ),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              itemCount: lessons.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                
                return GestureDetector(
                  onTap: () {
                    if (!lesson.isLocked) {
                      Navigator.pushNamed(context, AppRoutes.subjectLessonDetail);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This lesson is locked.'), backgroundColor: AppColors.signalRed, behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE6EAF2), width: 1),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Thumbnail Placeholder
                        Container(
                          width: 80,
                          height: 60,
                          decoration: BoxDecoration(
                            color: lesson.isLocked ? const Color(0xFFF0F2F5) : AppColors.navy.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            image: !lesson.isLocked ? const DecorationImage(
                              image: NetworkImage('https://placehold.co/160x120/1c263d/FFFFFF/png?text=Lesson'),
                              fit: BoxFit.cover,
                            ) : null,
                          ),
                          alignment: Alignment.center,
                          child: lesson.isLocked
                              ? const Icon(Icons.lock_rounded, color: AppColors.muted, size: 24)
                              : Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                                ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lesson.title,
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 14,
                                  color: lesson.isLocked ? AppColors.muted : AppColors.ink,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.timer_outlined, size: 12, color: lesson.isLocked ? AppColors.muted : AppColors.slate),
                                  const SizedBox(width: 4),
                                  Text(
                                    lesson.duration,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: lesson.isLocked ? AppColors.muted : AppColors.slate,
                                    ),
                                  ),
                                  if (lesson.hasNotes) ...[
                                    const SizedBox(width: 12),
                                    Icon(Icons.picture_as_pdf_outlined, size: 12, color: lesson.isLocked ? AppColors.muted : AppColors.slate),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Notes',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: lesson.isLocked ? AppColors.muted : AppColors.slate,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Action / Status
                        if (lesson.isCompleted)
                          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24)
                        else if (!lesson.isLocked)
                          const Icon(Icons.play_circle_outline_rounded, color: AppColors.navy, size: 24)
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
