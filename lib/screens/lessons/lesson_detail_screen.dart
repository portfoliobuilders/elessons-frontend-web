import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/dummy_data.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({super.key});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = DummyData.literatureLessons.first; // Example lesson

    return AppScaffold(
      safeBottom: false,
      safeTop: false,
      body: Column(
        children: [
          // Video Player Placeholder
          Container(
            color: Colors.black,
            width: double.infinity,
            height: MediaQuery.of(context).size.width * (9 / 16) +
                MediaQuery.of(context).padding.top,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.navy.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.navy,
              unselectedLabelColor: AppColors.muted,
              indicatorColor: AppColors.navy,
              indicatorWeight: 3,
              labelStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Notes'),
                Tab(text: 'Quiz'),
                Tab(text: 'Assignment'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(lesson.title, style: AppTextStyles.heading),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined,
                            size: 16, color: AppColors.slate),
                        const SizedBox(width: 4),
                        Text(lesson.duration,
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.slate,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 16),
                        const Icon(Icons.remove_red_eye_outlined,
                            size: 16, color: AppColors.slate),
                        const SizedBox(width: 4),
                        const Text('1.2k Views',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.slate,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Description',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink)),
                    const SizedBox(height: 8),
                    const Text(
                      'In this lesson, we explore the foundations of English literature, analyzing core texts and understanding the context in which they were written.',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.bodyText, height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF0F4FF),
                              foregroundColor: AppColors.navy,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.forum_outlined, size: 18),
                            label: const Text('Discussion'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF0F4FF),
                              foregroundColor: AppColors.navy,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Notes Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.picture_as_pdf_rounded,
                          size: 64, color: AppColors.navy),
                      const SizedBox(height: 16),
                      const Text('Lesson Notes',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text(
                          'Download the complete PDF notes for this lesson.',
                          style: TextStyle(color: AppColors.slate)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Download Notes'),
                      ),
                    ],
                  ),
                ),

                // Quiz Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.quiz_rounded,
                          size: 64, color: AppColors.navy),
                      const SizedBox(height: 16),
                      const Text('Chapter Quiz',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Test your knowledge on this topic.',
                          style: TextStyle(color: AppColors.slate)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.subjectQuiz),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: const Text('Start Quiz'),
                      ),
                    ],
                  ),
                ),

                // Assignment Tab
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.assignment_rounded,
                          size: 64, color: AppColors.navy),
                      const SizedBox(height: 16),
                      const Text('Weekly Assignment',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const Text('Submit your work for grading.',
                          style: TextStyle(color: AppColors.slate)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppRoutes.subjectAssignment),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: const Text('View Assignment'),
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
