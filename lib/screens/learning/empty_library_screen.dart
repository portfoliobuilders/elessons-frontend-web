import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';

/// 33 · Empty Library — state (My Learnings with no enrolments).
class EmptyLibraryScreen extends StatelessWidget {
  const EmptyLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
            child: Text('My Learnings', style: AppTextStyles.display),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: 'No courses yet',
                  message:
                      'Once you enrol, your lessons, notes and progress live here — and work offline.',
                  actionLabel: 'Explore courses',
                  onAction: () => Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.store, (_) => false),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.courseDetail),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.play_arrow_rounded,
                          size: 15, color: AppColors.signalRed),
                      SizedBox(width: 7),
                      Text('Watch a free sample first',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.signalRed)),
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
