import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/common/responsive_grid.dart';
import '../../models/api/learning_models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/learning_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/feedback/loading_indicator.dart';
import '../../widgets/learning/certificate_card.dart';
import '../../widgets/learning/empty_learning_widget.dart';
import '../../widgets/learning/learning_progress_card.dart';

/// 26 · My Learnings — Production EdTech Learning Dashboard.
class MyLearningsScreen extends StatefulWidget {
  const MyLearningsScreen({super.key});

  @override
  State<MyLearningsScreen> createState() => _MyLearningsScreenState();
}

class _MyLearningsScreenState extends State<MyLearningsScreen> {
  int _tab = 0; // 0 = In Progress, 1 = Completed
  static const List<String> _tabs = <String>['In Progress', 'Completed'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().loadLearnings(force: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSubjectDashboard(SubjectModel subject) {
    context.read<LearningProvider>().loadSubjectModules(subject.id);
    Navigator.pushNamed(
      context,
      AppRoutes.subjectDetail,
      arguments: {'subjectId': subject.id, 'title': subject.name},
    );
  }

  void _showCertificateDialog(SubjectModel subject, String studentName) async {
    final cert = await context
        .read<LearningProvider>()
        .fetchCertificate(subject.id, studentName);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.workspace_premium_rounded,
              size: 54,
              color: AppColors.amber,
            ),
            const SizedBox(height: 12),
            Text(
              'Course Completion Certificate',
              style: AppTextStyles.title.copyWith(color: AppColors.navy),
            ),
            const SizedBox(height: 6),
            Text(
              'Issued to ${cert.studentName} for completing ${cert.subjectName}',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(color: AppColors.slate),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Verification Code: ${cert.verificationCode}',
                style: AppTextStyles.mono.copyWith(color: AppColors.navy),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Downloading Certificate PDF...'),
                    backgroundColor: AppColors.navy,
                  ),
                );
              },
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download Certificate (PDF)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final learning = context.watch<LearningProvider>();
    final displayName = auth.displayName.isEmpty ? 'Student' : auth.displayName;

    final inProgress = learning.inProgressSubjects;
    final completed = learning.completedSubjects;
    final loading = learning.status.isLoading && learning.allSubjects.isEmpty;

    return RefreshIndicator(
      color: AppColors.navy,
      onRefresh: () => context.read<LearningProvider>().loadLearnings(force: true),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: <Widget>[
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Keep it up, $displayName 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMuted.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('My Learnings', style: AppTextStyles.display),
                  ],
                ),
              ),

              // Streak / Stats Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.local_fire_department_rounded,
                        size: 18, color: AppColors.signalRed),
                    SizedBox(width: 4),
                    Text(
                      '5 Day Streak',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Search Bar & Sort Filter Menu
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => learning.setSearchQuery(val),
                    decoration: const InputDecoration(
                      hintText: 'Search your courses...',
                      prefixIcon: Icon(Icons.search_rounded,
                          size: 20, color: AppColors.muted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              PopupMenuButton<LearningSortFilter>(
                onSelected: (filter) => learning.setFilter(filter),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                icon: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune_rounded,
                      size: 20, color: AppColors.navy),
                ),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: LearningSortFilter.recentlyViewed,
                    child: Text('Recently Viewed'),
                  ),
                  const PopupMenuItem(
                    value: LearningSortFilter.highestProgress,
                    child: Text('Highest Progress'),
                  ),
                  const PopupMenuItem(
                    value: LearningSortFilter.alphabetical,
                    child: Text('Alphabetical (A-Z)'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Segmented Tabs (In Progress / Completed)
          _SegmentedTabs(
            labels: _tabs,
            selectedIndex: _tab,
            onChanged: (int i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 20),

          if (loading)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: LoadingIndicator(),
            )
          else if (_tab == 0) ...[
            // IN PROGRESS TAB
            if (inProgress.isEmpty)
              EmptyLearningWidget(
                onExploreCourses: () {
                  Navigator.pushNamed(context, AppRoutes.store);
                },
              )
            else if (context.isDesktop || context.isTablet)
              ResponsiveGrid(
                itemCount: inProgress.length,
                phoneCols: 1,
                tabletCols: 2,
                desktopCols: 3,
                childAspectRatio: 1.35,
                itemBuilder: (context, i) => LearningProgressCard(
                  subject: inProgress[i],
                  onTap: () => _openSubjectDashboard(inProgress[i]),
                  onContinue: () => _openSubjectDashboard(inProgress[i]),
                ),
              )
            else
              ...inProgress.map(
                (subject) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: LearningProgressCard(
                    subject: subject,
                    onTap: () => _openSubjectDashboard(subject),
                    onContinue: () => _openSubjectDashboard(subject),
                  ),
                ),
              ),
          ] else ...[
            // COMPLETED TAB
            if (completed.isEmpty)
              EmptyLearningWidget(
                onExploreCourses: () {
                  Navigator.pushNamed(context, AppRoutes.store);
                },
              )
            else if (context.isDesktop || context.isTablet)
              ResponsiveGrid(
                itemCount: completed.length,
                phoneCols: 1,
                tabletCols: 2,
                desktopCols: 3,
                childAspectRatio: 1.25,
                itemBuilder: (context, i) => CertificateCard(
                  subject: completed[i],
                  onTap: () => _openSubjectDashboard(completed[i]),
                  onDownloadCertificate: () =>
                      _showCertificateDialog(completed[i], displayName),
                  onRevisionMode: () => _openSubjectDashboard(completed[i]),
                ),
              )
            else
              ...completed.map(
                (subject) => CertificateCard(
                  subject: subject,
                  onTap: () => _openSubjectDashboard(subject),
                  onDownloadCertificate: () =>
                      _showCertificateDialog(subject, displayName),
                  onRevisionMode: () => _openSubjectDashboard(subject),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double segWidth = (constraints.maxWidth - 8) / labels.length;
        return Container(
          height: 46,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.trackBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                left: segWidth * selectedIndex,
                top: 0,
                bottom: 0,
                width: segWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.ink.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List<Widget>.generate(labels.length, (int i) {
                  final bool active = i == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onChanged(i),
                      child: Center(
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: active ? AppColors.navy : AppColors.muted,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
