import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../models/dummy_data.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';

class ModulesScreen extends StatelessWidget {
  const ModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const modules = DummyData.englishModules;
    
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
                Text('Modules', style: AppTextStyles.heading.copyWith(fontSize: 16)),
                const SizedBox(width: 42), // Balance for centering
              ],
            ),
          ),
          
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
              itemCount: modules.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final module = modules[index];
                final isComplete = module.progress == 1.0;
                
                return GestureDetector(
                  onTap: () {
                    if (!module.isLocked) {
                      Navigator.pushNamed(context, AppRoutes.subjectLessons);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('This module is locked.'), backgroundColor: AppColors.signalRed, behavior: SnackBarBehavior.floating),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: isComplete ? AppColors.navy.withValues(alpha: 0.3) : const Color(0xFFE6EAF2), 
                        width: isComplete ? 1.5 : 1
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: module.isLocked ? const Color(0xFFF0F2F5) : (isComplete ? const Color(0xFFE7F3EF) : const Color(0xFFF4F6FB)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                module.isLocked ? Icons.lock_outline_rounded : (isComplete ? Icons.check_circle_outline_rounded : Icons.library_books_rounded),
                                color: module.isLocked ? AppColors.muted : (isComplete ? AppColors.success : AppColors.navy),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Module ${index + 1}',
                                    style: AppTextStyles.overline.copyWith(fontSize: 10, color: AppColors.muted),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    module.title,
                                    style: AppTextStyles.cardTitle.copyWith(
                                      fontSize: 15, 
                                      color: module.isLocked ? AppColors.muted : AppColors.ink
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${module.totalLessons} Lessons',
                                    style: TextStyle(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.w600, 
                                      color: module.isLocked ? AppColors.muted : AppColors.slate
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (!module.isLocked) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: module.progress,
                                    minHeight: 6,
                                    backgroundColor: const Color(0xFFE6EAF2),
                                    valueColor: AlwaysStoppedAnimation(isComplete ? AppColors.success : AppColors.navy),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${(module.progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isComplete ? AppColors.success : AppColors.navy,
                                ),
                              ),
                            ],
                          ),
                        ]
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
