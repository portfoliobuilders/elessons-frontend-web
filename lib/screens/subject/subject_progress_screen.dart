import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../models/dummy_data.dart';
import '../../widgets/common/app_scaffold.dart';

class SubjectProgressScreen extends StatelessWidget {
  const SubjectProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const subject = DummyData.englishSubject;
    
    return AppScaffold(
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nav
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
                Text('Progress Report', style: AppTextStyles.heading.copyWith(fontSize: 16)),
                const SizedBox(width: 42),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Overall Progress Circle Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.navy,
                    borderRadius: BorderRadius.circular(AppRadius.hero),
                    boxShadow: AppShadows.hero,
                  ),
                  child: Column(
                    children: [
                      const Text('Overall Progress', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 24),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 140,
                            child: CircularProgressIndicator(
                              value: subject.progress,
                              strokeWidth: 12,
                              backgroundColor: Colors.white.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF38C793)),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${(subject.progress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                              const Text('Completed', style: TextStyle(color: Color(0xFF97A2BA), fontSize: 12, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ProgressStat(label: 'Modules', value: '${(subject.modulesCount * subject.progress).toInt()}/${subject.modulesCount}'),
                          Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.2)),
                          _ProgressStat(label: 'Lessons', value: '${(subject.lessonsCount * subject.progress).toInt()}/${subject.lessonsCount}'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const Text('ACHIEVEMENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: 0.5)),
                const SizedBox(height: 16),
                
                // Achievements
                const Row(
                  children: [
                    Expanded(child: _AchievementCard(icon: Icons.local_fire_department_rounded, title: '7 Day Streak', color: Color(0xFFFF9800))),
                    SizedBox(width: 16),
                    Expanded(child: _AchievementCard(icon: Icons.star_rounded, title: 'Perfect Quiz', color: Color(0xFFFFC107))),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: _AchievementCard(icon: Icons.menu_book_rounded, title: 'Bookworm', color: Color(0xFF4CAF50))),
                    SizedBox(width: 16),
                    Expanded(child: _AchievementCard(icon: Icons.lock_rounded, title: 'Locked', color: Color(0xFF9E9E9E), isLocked: true)),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text('CERTIFICATES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: 0.5)),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                        ),
                        child: const Icon(Icons.workspace_premium_rounded, color: AppColors.muted, size: 32),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Course Certificate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)),
                            SizedBox(height: 4),
                            Text('Complete 100% to unlock', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                          ],
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
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Color(0xFF97A2BA), fontSize: 12)),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.icon, required this.title, required this.color, this.isLocked = false});
  final IconData icon;
  final String title;
  final Color color;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: isLocked ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isLocked ? AppColors.muted : AppColors.ink)),
        ],
      ),
    );
  }
}
