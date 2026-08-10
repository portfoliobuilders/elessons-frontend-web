import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/utils/responsive.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/gtec_logo.dart';

/// 01 · Landing Screen — Pixel-perfect matching design screenshots.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _selectedClass = 10;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1 & 2: Top Nav Header + Hero Section (Dark Navy Background)
            _HeroSection(
              selectedClass: _selectedClass,
              onClassSelected: (c) => setState(() => _selectedClass = c),
            ),

            // 3: Stat Band
            const _StatBand(),

            // 4: Find Your Class & Popular Subjects Section
            _ClassAndSubjectsSection(
              selectedClass: _selectedClass,
              onClassSelected: (c) => setState(() => _selectedClass = c),
            ),

            // 5: Features Section ("Everything your child needs to top the class")
            const _FeaturesSection(),

            // 6: Simple, Flexible Pricing Section
            const _PricingSection(),

            // 7: Footer Band
            const _LandingFooter(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1 & 2. Hero Section + Header Navigation (Navy Background)
// ---------------------------------------------------------------------------
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.selectedClass,
    required this.onClassSelected,
  });

  final int selectedClass;
  final ValueChanged<int> onClassSelected;

  @override
  Widget build(BuildContext context) {
    final double pagePadX = context.isMobile ? 20.0 : (context.isTablet ? 36.0 : 64.0);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Dark Navy
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B1324),
            Color(0xFF0F172A),
            Color(0xFF131F37),
          ],
        ),
      ),
      child: Column(
        children: [
          // Top Navigation Bar
          _HeaderNav(pagePadX: pagePadX),

          // Hero Main Content
          Padding(
            padding: EdgeInsets.fromLTRB(pagePadX, 36, pagePadX, 60),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: context.isDesktop
                    ? const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: _HeroCopy()),
                          SizedBox(width: 48),
                          _HeroPreviewCard(),
                        ],
                      )
                    : const Column(
                        children: [
                          _HeroCopy(),
                          SizedBox(height: 40),
                          _HeroPreviewCard(),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header Nav
// ---------------------------------------------------------------------------
class _HeaderNav extends StatelessWidget {
  const _HeaderNav({required this.pagePadX});

  final double pagePadX;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: pagePadX, vertical: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              // Official eLessons Brand Logo & Lockup
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.home),
                child: const GtecELessonsLogo(
                  height: 46,
                  lightMode: false,
                  showTagline: true,
                ),
              ),

              const SizedBox(width: 32),

              // Navigation Links (Desktop)
              if (!context.isMobile) ...[
                _navLink(context, 'Courses', () => Navigator.pushNamed(context, AppRoutes.store)),
                const SizedBox(width: 24),
                _navLink(context, 'How it works', () {}),
                const SizedBox(width: 24),
                _navLink(context, 'Pricing', () {}),
                const SizedBox(width: 24),

                // Location / Currency Dropdown Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0x2EFFFFFF)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.language_rounded, color: Colors.white, size: 15),
                      SizedBox(width: 6),
                      Text(
                        'India · ₹ ˅',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Log In Text Button
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Get Started Pill Button
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.createAccount),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Get started',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navLink(BuildContext context, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFCBD5E1),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Left Column Copy & CTAs
// ---------------------------------------------------------------------------
class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Pill Tag: 🔴 CBSE · Class 8–12 · India & GCC
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x26FFFFFF)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'CBSE · Class 8–12 · India & GCC',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Main Title
        Text(
          'Tuition that actually\ngets results.',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.isMobile ? 32 : 44,
            fontWeight: FontWeight.w800,
            height: 1.12,
            letterSpacing: -0.8,
          ),
        ),

        const SizedBox(height: 20),

        // Subtitle Copy
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: const Text(
            'Concept videos, chapter notes, PYQs and full-length mock tests — built by top educators and mapped to your exact board and grade.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Action Buttons Row
        Wrap(
          spacing: 16,
          runSpacing: 14,
          children: [
            // Primary CTA: Start learning ->
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createAccount),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Start learning',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),

            // Secondary CTA: Watch demo
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0x0DFFFFFF),
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0x40FFFFFF)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Watch demo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),

        // Social Proof / Ratings Row
        Row(
          children: [
            // Avatar Stack
            SizedBox(
              width: 96,
              height: 36,
              child: Stack(
                children: [
                  _avatarBubble(const Color(0xFF1E293B), 0),
                  _avatarBubble(const Color(0xFF334155), 20),
                  _avatarBubble(const Color(0xFF1E293B), 40),
                  Positioned(
                    left: 60,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0F172A), width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '12k',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Star Rating + Student Count
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 16),
                    SizedBox(width: 4),
                    Text(
                      '4.8/5',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'from 12,400+ students',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _avatarBubble(Color bg, double leftPos) {
    return Positioned(
      left: leftPos,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0F172A), width: 2),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero Right Column Floating "LESSON PREVIEW" Card
// ---------------------------------------------------------------------------
class _HeroPreviewCard extends StatelessWidget {
  const _HeroPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.isMobile ? double.infinity : 390,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Label
          const Text(
            'LESSON PREVIEW',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 14),

          // Video Thumbnail Box
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF131D35),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Subject & Class
          const Text(
            'Science · Class 10',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          // Lesson Title
          const Text(
            'The pH Scale & Indicators',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          // Progress Bar (46%)
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.46,
              minHeight: 6,
              backgroundColor: Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
            ),
          ),

          const SizedBox(height: 10),

          // Completion Stats & Action Link
          Row(
            children: [
              const Text(
                '46% complete',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.createAccount),
                child: const Row(
                  children: [
                    Text(
                      'Resume',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '→',
                      style: TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Stat Band Section
// ---------------------------------------------------------------------------
class _StatBand extends StatelessWidget {
  const _StatBand();

  @override
  Widget build(BuildContext context) {
    final double pagePadX = context.isMobile ? 20.0 : (context.isTablet ? 36.0 : 64.0);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: pagePadX, vertical: 36),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: const Wrap(
            spacing: 48,
            runSpacing: 24,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _StatItem(value: '12,400+', label: 'Active students'),
              _StatItem(value: '240+', label: 'Video lessons per grade'),
              _StatItem(value: '94%', label: 'Report better grades'),
              _StatItem(value: '4.8/5', label: 'Average rating'),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Class Selector & Popular Subjects Section
// ---------------------------------------------------------------------------
class _ClassAndSubjectsSection extends StatelessWidget {
  const _ClassAndSubjectsSection({
    required this.selectedClass,
    required this.onClassSelected,
  });

  final int selectedClass;
  final ValueChanged<int> onClassSelected;

  @override
  Widget build(BuildContext context) {
    final double pagePadX = context.isMobile ? 20.0 : (context.isTablet ? 36.0 : 64.0);

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(horizontal: pagePadX, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Sub-tag
              const Text(
                'CBSE TUITION · CLASS 8–12',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 8),

              // Title Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Find your class, then explore',
                      style: TextStyle(
                        color: const Color(0xFF0F172A),
                        fontSize: context.isMobile ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  if (!context.isMobile)
                    const Row(
                      children: [
                        Text(
                          'View full catalog',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          '→',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 28),

              // Class Tab Chips (8, 9, 10, 11, 12)
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final c in [8, 9, 10, 11, 12])
                    _ClassChip(
                      classNum: c,
                      isSelected: c == selectedClass,
                      onTap: () => onClassSelected(c),
                    ),
                ],
              ),

              const SizedBox(height: 36),

              // Sub-heading: Popular subjects in Class X
              Text.rich(
                TextSpan(
                  text: 'Popular subjects in ',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    TextSpan(
                      text: 'Class $selectedClass',
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4 Subject Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final int cols = constraints.maxWidth > 1000
                      ? 3
                      : (constraints.maxWidth > 600 ? 2 : 1);
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: cols == 1 ? 1.4 : 0.95,
                    children: const [
                      _SubjectCard(
                        subjectName: 'MATHEMATICS',
                        title: 'Mathematics — Full Subject',
                        details: '5 modules · 52 lessons · R. Menon',
                        rating: '4.9 (1.2k)',
                        price: '₹8,000',
                        bannerColor: Color(0xFF234275), // Navy
                        hasBadge: true,
                        badgeText: 'BESTSELLER',
                      ),
                      _SubjectCard(
                        subjectName: 'SCIENCE',
                        title: 'Science — Full Subject',
                        details: '5 modules · 48 lessons · S. Iyer',
                        rating: '4.8 (980)',
                        price: '₹8,000',
                        bannerColor: Color(0xFF1B6A47), // Green
                      ),
                      _SubjectCard(
                        subjectName: 'ENGLISH',
                        title: 'English — Full Subject',
                        details: '4 modules · 36 lessons · P. Nair',
                        rating: '4.8 (720)',
                        price: '₹4,000',
                        bannerColor: Color(0xFF5B3E96), // Purple
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Class Chip Tab Widget
// ---------------------------------------------------------------------------
class _ClassChip extends StatelessWidget {
  const _ClassChip({
    required this.classNum,
    required this.isSelected,
    required this.onTap,
  });

  final int classNum;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 82,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF16244A) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF16244A) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x3316244A),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              '$classNum',
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Class',
              style: TextStyle(
                color: isSelected ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Subject Card Component
// ---------------------------------------------------------------------------
class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subjectName,
    required this.title,
    required this.details,
    required this.rating,
    required this.price,
    required this.bannerColor,
    this.hasBadge = false,
    this.badgeText,
  });

  final String subjectName;
  final String title;
  final String details;
  final String rating;
  final String price;
  final Color bannerColor;
  final bool hasBadge;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Top
          Container(
            height: 105,
            width: double.infinity,
            color: bannerColor,
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                if (hasBadge && badgeText != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFACC15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText!,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Text(
                    subjectName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  details,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Features Section ("Everything your child needs to top the class")
// ---------------------------------------------------------------------------
class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    final double pagePadX = context.isMobile ? 20.0 : (context.isTablet ? 36.0 : 64.0);

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: pagePadX, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Everything your child needs to top the class',
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: context.isMobile ? 22 : 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 32),

              // 3 Feature Cards
              context.isDesktop
                  ? const Row(
                      children: [
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.school_rounded,
                            title: 'Taught by top educators',
                            description:
                                'Concept-first videos from faculty with 10–15 years of CBSE board experience.',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.track_changes_rounded,
                            title: 'Mapped to your syllabus',
                            description:
                                'Pick your board and grade once — the whole library filters to exactly what you study.',
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _FeatureCard(
                            icon: Icons.description_rounded,
                            title: 'Notes, PYQs & mock tests',
                            description:
                                'Downloadable PDF notes, previous-year papers and timed mock tests with instant scoring.',
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      children: [
                        _FeatureCard(
                          icon: Icons.school_rounded,
                          title: 'Taught by top educators',
                          description:
                              'Concept-first videos from faculty with 10–15 years of CBSE board experience.',
                        ),
                        SizedBox(height: 16),
                        _FeatureCard(
                          icon: Icons.track_changes_rounded,
                          title: 'Mapped to your syllabus',
                          description:
                              'Pick your board and grade once — the whole library filters to exactly what you study.',
                        ),
                        SizedBox(height: 16),
                        _FeatureCard(
                          icon: Icons.description_rounded,
                          title: 'Notes, PYQs & mock tests',
                          description:
                              'Downloadable PDF notes, previous-year papers and timed mock tests with instant scoring.',
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF16244A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Simple, Flexible Pricing Section
// ---------------------------------------------------------------------------
class _PricingSection extends StatelessWidget {
  const _PricingSection();

  @override
  Widget build(BuildContext context) {
    final double pagePadX = context.isMobile ? 20.0 : (context.isTablet ? 36.0 : 64.0);

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(horizontal: pagePadX, vertical: 56),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'Simple , flexible pricing',
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: context.isMobile ? 22 : 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Buy the full year, or a single subject.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Pricing Cards Row
              context.isDesktop
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _PricingCardFeatured(),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _PricingCardStandard(
                            title: 'Per subject',
                            price: '₹3,499',
                            unit: '/ subject',
                            description:
                                'A complete subject end-to-end with notes, PYQs & tests.',
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      children: [
                        _PricingCardFeatured(),
                        SizedBox(height: 20),
                        _PricingCardStandard(
                          title: 'Per subject',
                          price: '₹3,499',
                          unit: '/ subject',
                          description:
                              'A complete subject end-to-end with notes, PYQs & tests.',
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PricingCardStandard extends StatelessWidget {
  const _PricingCardStandard({
    required this.title,
    required this.price,
    required this.unit,
    required this.description,
  });

  final String title;
  final String price;
  final String unit;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                unit,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricingCardFeatured extends StatelessWidget {
  const _PricingCardFeatured();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF16244A), // Dark Navy
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D16244A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Red Badge: MOST POPULAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'MOST POPULAR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Full year',
            style: TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹11,999',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '₹17,999',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  decoration: TextDecoration.lineThrough,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text(
            'All 5 subjects · 240+ lessons · 40 mock tests · 12-month access.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13.5,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),

          const SizedBox(height: 22),

          // Enroll Now Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.checkout),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Enroll now',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Footer
// ---------------------------------------------------------------------------
class _LandingFooter extends StatelessWidget {
  const _LandingFooter();

  @override
  Widget build(BuildContext context) {
    final double pagePadX = context.isMobile ? 20.0 : (context.isTablet ? 36.0 : 64.0);

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: EdgeInsets.symmetric(horizontal: pagePadX, vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '© 2026 G-TEC Education. All rights reserved.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Terms of Service',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
