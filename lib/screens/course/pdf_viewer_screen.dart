import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../widgets/common/app_scaffold.dart';

/// 22 · Notes — PDF Viewer.
///
/// Bound to the resource metadata passed from the lesson (title, type, page
/// count, size). The current backend stores resources as private object-store
/// keys and does not yet serve the file or a signed URL, and the app ships
/// without a PDF rendering package — so the reader shows the real document
/// details and an honest "preview unavailable" state rather than fabricated
/// page content. The reader chrome matches the design.
class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({super.key});

  static const Color _bg = Color(0xFF33384A);

  @override
  Widget build(BuildContext context) {
    final Object? raw = ModalRoute.of(context)?.settings.arguments;
    String title = 'Document';
    String type = 'NOTE';
    int? pageCount;
    String sizeLabel = '';
    if (raw is Map) {
      title = (raw['title'] as String?)?.trim().isNotEmpty == true
          ? raw['title'] as String
          : title;
      type = (raw['type'] as String?) ?? type;
      pageCount = raw['pageCount'] as int?;
      sizeLabel = (raw['sizeLabel'] as String?) ?? '';
    }

    final String subtitle = '${_typeLabel(type)} · PDF';
    final List<String> metaParts = <String>[
      'PDF',
      if (pageCount != null && pageCount > 0) '$pageCount pages',
      if (sizeLabel.isNotEmpty) sizeLabel,
    ];

    void notAvailable() {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('This document isn\'t available for download yet.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.signalRed,
      ));
    }

    return AppScaffold(
      backgroundColor: _bg,
      dark: true,
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // toolbar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      _GlassButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: () => Navigator.maybePop(context)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.cardTitle.copyWith(
                                    color: Colors.white, height: 1.2)),
                            const SizedBox(height: 1),
                            Text(subtitle,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFAEB4C2))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  children: <Widget>[
                    _GlassButton(
                        icon: Icons.bookmark_border_rounded, onTap: () {}),
                    const SizedBox(width: 9),
                    _GlassButton(
                        icon: Icons.file_download_outlined, onTap: notAvailable),
                  ],
                ),
              ],
            ),
          ),
          // page
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                      spreadRadius: -16,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.redBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.picture_as_pdf_outlined,
                          size: 30, color: AppColors.signalRed),
                    ),
                    const SizedBox(height: 18),
                    Text(title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.titleSm
                            .copyWith(fontSize: 16, height: 1.3)),
                    const SizedBox(height: 6),
                    Text(metaParts.join(' · '),
                        style: AppTextStyles.mono.copyWith(
                            fontSize: 11,
                            letterSpacing: 0.5,
                            color: const Color(0xFF9AA6BE))),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'In-app preview for this document isn\'t available yet. It will open here once documents are served to the app.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            height: 1.55,
                            color: Color(0xFF5A6273)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 24 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'PYQ':
        return 'Previous year questions';
      case 'RESOURCE':
        return 'Resource';
      case 'NOTE':
      default:
        return 'Chapter notes';
    }
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 19, color: Colors.white),
      ),
    );
  }
}
