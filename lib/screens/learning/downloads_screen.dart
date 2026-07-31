import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';

/// 27 · Downloads — Offline.
///
/// Offline downloads aren't part of the current backend: lessons stream from
/// YouTube and notes are served on demand, so there is no download queue or
/// on-device library to show. Rather than fabricate storage figures and files,
/// this screen presents an honest "not available yet" state. The header layout
/// is preserved; the non-functional "Edit" action is omitted since there's
/// nothing to manage.
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.surface,
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEF1F6))),
            ),
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color(0xFFE7EAF0), width: 1.5),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.chevron_left_rounded,
                        size: 20, color: AppColors.ink),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Downloads',
                    style: AppTextStyles.titleSm.copyWith(fontSize: 16)),
              ],
            ),
          ),
          const Expanded(
            child: EmptyState(
              icon: Icons.download_for_offline_outlined,
              title: 'Offline downloads aren\'t available yet',
              message:
                  'Your lessons stream online and notes open when you\'re connected. Saving classes for offline viewing is coming in a future update.',
            ),
          ),
        ],
      ),
    );
  }
}
