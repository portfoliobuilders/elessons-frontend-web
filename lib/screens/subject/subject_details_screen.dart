import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/dummy_data.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/decorative_blobs.dart';

class SubjectDetailsScreen extends StatelessWidget {
  const SubjectDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, we'd fetch this using Provider based on subjectId in arguments.
    const subject = DummyData.englishSubject;

    return AppScaffold(
      safeBottom: false,
      body: Stack(
        children: [
          // Background Gradient at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.heroCard,
              ),
              child: const Stack(
                children: [
                  Positioned(right: -30, top: -30, child: DecorBlob(size: 140)),
                  Positioned(left: -20, bottom: -20, child: DecorBlob(size: 100, opacity: 0.05)),
                ],
              ),
            ),
          ),
          
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Nav
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(Icons.chevron_left_rounded, size: 24, color: Colors.white),
                        ),
                      ),
                      Text('Subject Details', style: AppTextStyles.heading.copyWith(fontSize: 15, color: Colors.white)),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(Icons.share_rounded, size: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.hero),
                          boxShadow: AppShadows.hero,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HatchTile(width: 60, height: 60, label: subject.imagePath, radius: 16, band: 8),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(subject.title, style: AppTextStyles.headlineHero.copyWith(fontSize: 22, height: 1.2)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC53D)),
                                          const SizedBox(width: 4),
                                          Text('4.8 (1.2k reviews)', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, color: AppColors.slate)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(subject.description, style: AppTextStyles.body.copyWith(color: AppColors.bodyText)),
                            const SizedBox(height: 20),
                            
                            // Teacher Info
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
                                  alignment: Alignment.center,
                                  child: Text(subject.teacherImage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Taught by', style: AppTextStyles.caption.copyWith(fontSize: 10, color: AppColors.muted)),
                                    Text(subject.teacherName, style: AppTextStyles.titleSm.copyWith(fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Text('COURSE HIGHLIGHTS', style: AppTextStyles.overline.copyWith(fontSize: 12, letterSpacing: 0.5, color: AppColors.muted)),
                      const SizedBox(height: 12),
                      
                      // Stats Row
                      Row(
                        children: [
                          Expanded(child: _StatBox(icon: Icons.auto_awesome_mosaic_rounded, title: '${subject.modulesCount} Modules')),
                          const SizedBox(width: 12),
                          Expanded(child: _StatBox(icon: Icons.play_circle_outline_rounded, title: '${subject.lessonsCount} Lessons')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _StatBox(icon: Icons.timer_outlined, title: subject.duration)),
                          const SizedBox(width: 12),
                          const Expanded(child: _StatBox(icon: Icons.quiz_outlined, title: 'Weekly Quizzes')),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      Text('YOUR PROGRESS', style: AppTextStyles.overline.copyWith(fontSize: 12, letterSpacing: 0.5, color: AppColors.muted)),
                      const SizedBox(height: 12),
                      
                      // Progress Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FF),
                          border: Border.all(color: const Color(0xFFE6EAF2), width: 1.5),
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${(subject.progress * 100).toInt()}% Completed', style: AppTextStyles.titleSm),
                                GestureDetector(
                                  onTap: () => Navigator.pushNamed(context, AppRoutes.subjectProgress),
                                  child: const Text('View Full', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w700, fontSize: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: subject.progress,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFE6EAF2),
                                valueColor: const AlwaysStoppedAnimation(AppColors.navy),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Sticky CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                ],
                border: const Border(top: BorderSide(color: Color(0xFFF0F2F5), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Total Price', style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                        const SizedBox(height: 2),
                        Text('₹${subject.price.toInt()}', style: AppTextStyles.headlineHero.copyWith(fontSize: 22, color: AppColors.navy)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, AppRoutes.subjectModules),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.navy,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                            ),
                            child: const Text('Continue Learning', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
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

class _StatBox extends StatelessWidget {
  const _StatBox({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF0F2F5), width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.ink.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF4F6FB), shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: AppColors.navy),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bodyText))),
        ],
      ),
    );
  }
}
