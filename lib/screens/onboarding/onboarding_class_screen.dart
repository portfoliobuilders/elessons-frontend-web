import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/profile_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/onboarding_header.dart';
import '../../widgets/inputs/primary_button.dart';

/// 08 · Onboarding — Your class.
class OnboardingClassScreen extends StatefulWidget {
  const OnboardingClassScreen({super.key});

  @override
  State<OnboardingClassScreen> createState() => _OnboardingClassScreenState();
}

class _OnboardingClassScreenState extends State<OnboardingClassScreen> {
  int _selected = 10; // Class 10 pre-selected per the design.
  static const List<int> _classes = [8, 9, 10, 11, 12];
  bool _finishing = false;

  /// Resolves the backend grade id for the chosen class number, persists the
  /// onboarding selection (region/currency/board/grade), then enters the app.
  Future<void> _finish() async {
    setState(() => _finishing = true);
    final catalog = context.read<CatalogProvider>();
    final profile = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();

    // Load the CBSE grades and match "Class N".
    if (catalog.grades.isEmpty) {
      await catalog.loadGrades(board: 'CBSE');
    }
    String? gradeId;
    for (final g in catalog.grades) {
      final digits = g.name.replaceAll(RegExp(r'\D'), '');
      if (digits == '$_selected') {
        gradeId = g.id;
        break;
      }
    }
    gradeId ??= catalog.grades.isNotEmpty ? catalog.grades.first.id : null;

    if (gradeId == null) {
      if (!mounted) return;
      setState(() => _finishing = false);
      _snack('Could not load classes. Please check your connection.');
      return;
    }

    final err = await profile.onboard(
      region: 'IN',
      currency: 'INR',
      board: 'CBSE',
      gradeId: gradeId,
    );
    if (!mounted) return;
    if (err != null) {
      setState(() => _finishing = false);
      _snack(err);
      return;
    }

    // Mark onboarded locally + refresh the full profile, then preload Home for
    // the selected grade so it renders immediately.
    auth.markOnboarded();
    await auth.refreshProfile();
    if (mounted) {
      context.read<HomeProvider>().load(gradeId: gradeId, force: true);
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(m),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.signalRed,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const OnboardingHeader(step: 2),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 30, 26, 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7ECF6),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.signalRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text('CBSE BOARD',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11.5,
                              letterSpacing: 0.3,
                              fontWeight: FontWeight.w800,
                              color: AppColors.navy,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Which class are\nyou in?',
                      style: AppTextStyles.display),
                  const SizedBox(height: 8),
                  Text(
                    'We teach Class 8 to 12 — pick yours. You can change it anytime.',
                    style: AppTextStyles.bodyLg,
                  ),
                  const SizedBox(height: 22),
                  for (final c in _classes) ...[
                    _ClassTile(
                      number: c,
                      selected: _selected == c,
                      onTap: () => setState(() => _selected = c),
                    ),
                    if (c != _classes.last) const SizedBox(height: 11),
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Finish setup',
                    icon: Icons.check_rounded,
                    loading: _finishing,
                    onPressed: _finish,
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

class _ClassTile extends StatelessWidget {
  const _ClassTile({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFAFBFE) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.navy : const Color(0xFFE7EAF0),
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.navy.withValues(alpha: 0.18),
                    blurRadius: 22,
                    spreadRadius: -16,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.navy : AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$number',
                style: AppTextStyles.sectionTitle.copyWith(
                  fontSize: 17,
                  color: selected ? Colors.white : AppColors.ink,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Class $number',
                      style: AppTextStyles.heading
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    'CBSE · 2025–26',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.5,
                      letterSpacing: 0,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected ? AppColors.navy : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            _Radio(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  const _Radio({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? AppColors.navy : Colors.transparent,
        shape: BoxShape.circle,
        border: selected
            ? null
            : Border.all(color: AppColors.border, width: 2),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
          : null,
    );
  }
}
