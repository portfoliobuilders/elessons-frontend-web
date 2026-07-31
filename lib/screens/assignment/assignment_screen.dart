import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/common/app_scaffold.dart';

class AssignmentScreen extends StatelessWidget {
  const AssignmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      safeBottom: true,
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
                Text('Assignment', style: AppTextStyles.heading.copyWith(fontSize: 16)),
                const SizedBox(width: 42),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Details Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    boxShadow: AppShadows.card,
                    border: Border.all(color: const Color(0xFFE6EAF2), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7E6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('DUE: OCT 24', style: TextStyle(color: Color(0xFFFA8C16), fontSize: 10, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 12),
                      const Text('Write an essay on Elizabethan Theatre', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3, color: AppColors.ink)),
                      const SizedBox(height: 16),
                      const Text(
                        'Please submit a 500-word essay discussing the key characteristics of theatre during the Elizabethan era. You may include references to Shakespearean plays.',
                        style: TextStyle(fontSize: 14, color: AppColors.bodyText, height: 1.5),
                      ),
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Icon(Icons.attachment_rounded, size: 16, color: AppColors.navy),
                          SizedBox(width: 6),
                          Text('Reference_Material.pdf', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600, fontSize: 13, decoration: TextDecoration.underline)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                const Text('YOUR SUBMISSION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.muted, letterSpacing: 0.5)),
                const SizedBox(height: 16),
                
                // Upload Area
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 2, style: BorderStyle.none), // Should be dashed in a real implementation
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomPaint(
                    painter: _DashedBorderPainter(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                          ),
                          child: const Icon(Icons.cloud_upload_outlined, color: AppColors.navy, size: 28),
                        ),
                        const SizedBox(height: 12),
                        const Text('Upload PDF or Image', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.navy)),
                        const SizedBox(height: 4),
                        const Text('Max file size 10MB', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Submit Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.maybePop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment uploaded successfully!')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navy,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Submit Assignment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    // Simple dashed border logic for a rounded rect could be complex,
    // using a solid border for the mock but styling it to look like upload area.
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(16)), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
