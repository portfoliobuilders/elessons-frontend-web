import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/subject_image_helper.dart';
import '../../models/api/learning_models.dart';
import '../../providers/learning_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/progress_track.dart';
import '../../widgets/learning/module_progress_card.dart';
import '../../widgets/learning/progress_ring.dart';

/// Subject Learning Dashboard displaying course completion header and module accordions.
class SubjectDashboardScreen extends StatefulWidget {
  const SubjectDashboardScreen({super.key});

  @override
  State<SubjectDashboardScreen> createState() => _SubjectDashboardScreenState();
}

class _SubjectDashboardScreenState extends State<SubjectDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();
    final subject = learning.selectedSubject;
    final modules = learning.selectedModules;

    if (subject == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subject Dashboard')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final double completionFraction =
        (subject.progressPercent / 100).clamp(0.0, 1.0);
    final String? bannerAsset =
        SubjectImageHelper.getBannerAsset(subject.name, subject.monogram);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 235,
            pinned: true,
            backgroundColor: AppColors.navy,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                subject.name,
                style: AppTextStyles.heading.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [
                    const Shadow(
                      color: Colors.black45,
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  if (bannerAsset != null)
                    Image.asset(
                      bannerAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.navyDeep),
                    )
                  else if (subject.bannerUrl != null)
                    Image.network(
                      subject.bannerUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.navyDeep),
                    )
                  else
                    Container(color: AppColors.navyDeep),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.transparent,
                          AppColors.navy.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.borderSoft),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: AppColors.navy.withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            ProgressRing(
                              percent: subject.progressPercent,
                              size: 60,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    '${subject.progressPercent}% Completed',
                                    style: AppTextStyles.title.copyWith(
                                      color: AppColors.navy,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${subject.completedLessons} of ${subject.totalLessons} lessons finished',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        ProgressTrack(value: completionFraction),
                        const SizedBox(height: 16),

                        ElevatedButton.icon(
                          onPressed: () {
                            LessonModel? target;
                            for (var m in modules) {
                              for (var l in m.lessons) {
                                if (!l.isCompleted) {
                                  target = l;
                                  break;
                                }
                              }
                              if (target != null) break;
                            }
                            target ??= (modules.isNotEmpty && modules.first.lessons.isNotEmpty)
                                ? modules.first.lessons.first
                                : null;

                            if (target != null) {
                              learning.setActiveLesson(target);
                              Navigator.pushNamed(
                                context,
                                AppRoutes.subjectLessonDetail,
                              );
                            }
                          },
                          icon: const Icon(Icons.play_circle_fill_rounded),
                          label: Text(
                            subject.isCompleted ? 'Review Course' : 'Continue Learning',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.navy,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.input),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Course Modules (${modules.length})',
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: AppColors.navy,
                        ),
                      ),
                      Text(
                        '${subject.completedModules}/${subject.totalModules} Completed',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedAlt,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (modules.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No modules loaded for this subject.',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    )
                  else
                    ...modules.map(
                      (module) => ModuleProgressCard(
                        module: module,
                        onSelectLesson: (lesson) {
                          learning.setActiveLesson(lesson);
                          Navigator.pushNamed(
                            context,
                            AppRoutes.videoPlayer,
                            arguments: {
                              'lessonId': lesson.id,
                              'title': lesson.title,
                              'subjectName': subject.name,
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
