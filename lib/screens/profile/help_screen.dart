import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/common/app_scaffold.dart';

class _Faq {
  const _Faq(this.question, this.answer);
  final String question;
  final String? answer;
}

/// 31 · Help & Support.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _open = 0;

  static const List<_Faq> _faqs = <_Faq>[
    _Faq('How long do I have access to a course?',
        'Every purchase includes 12 months of access from the date of enrolment, including all future updates to that course.'),
    _Faq('Can I get a refund?', null),
    _Faq('How do I download for offline use?', null),
    _Faq('How do I change my class or board?', null),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.surface,
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
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
                Text('Help & Support',
                    style: AppTextStyles.titleSm.copyWith(fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              children: <Widget>[
                // contact options
                const Row(
                  children: <Widget>[
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Live chat',
                        filled: true,
                      ),
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email us',
                      ),
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: _ContactCard(
                        icon: Icons.call_outlined,
                        label: 'Call',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    border:
                        Border.all(color: const Color(0xFFE7EAF0), width: 1.5),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.search_rounded,
                          size: 19, color: AppColors.muted),
                      const SizedBox(width: 10),
                      Text('Search help articles…',
                          style: AppTextStyles.bodyLg
                              .copyWith(color: AppColors.muted)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 11),
                  child: Text('POPULAR QUESTIONS',
                      style: AppTextStyles.overline.copyWith(
                          fontSize: 12,
                          letterSpacing: 0.6,
                          color: AppColors.muted)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppShadows.card,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      children: List<Widget>.generate(_faqs.length, (int i) {
                        return _FaqItem(
                          faq: _faqs[i],
                          open: _open == i,
                          showDivider: i != 0,
                          onTap: () =>
                              setState(() => _open = _open == i ? -1 : i),
                        );
                      }),
                    ),
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: filled ? AppColors.navy : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: filled
            ? null
            : Border.all(color: AppColors.borderSoft, width: 1.5),
        boxShadow: filled
            ? <BoxShadow>[
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.6),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                  spreadRadius: -14,
                ),
              ]
            : null,
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: filled
                  ? Colors.white.withValues(alpha: 0.14)
                  : AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                size: 20, color: filled ? Colors.white : AppColors.navy),
          ),
          const SizedBox(height: 9),
          Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : AppColors.ink)),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.faq,
    required this.open,
    required this.showDivider,
    required this.onTap,
  });

  final _Faq faq;
  final bool open;
  final bool showDivider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: open ? AppColors.surfaceSoft : Colors.white,
          border: showDivider
              ? const Border(top: BorderSide(color: Color(0xFFF0F2F7)))
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(faq.question,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: open ? FontWeight.w700 : FontWeight.w600,
                            color: open ? AppColors.ink : AppColors.bodyText)),
                  ),
                ),
                Icon(
                  open
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.chevron_right_rounded,
                  size: 18,
                  color: open ? AppColors.navy : AppColors.muted,
                ),
              ],
            ),
            if (open && faq.answer != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(faq.answer!,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.55,
                      color: AppColors.slate)),
            ],
          ],
        ),
      ),
    );
  }
}
