import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/hatch_painter.dart';
import '../../models/api/catalog.dart';
import '../../models/api/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../routes/app_routes.dart';

import '../../widgets/common/app_scaffold.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

String _mono(String value) {
  final String letters = value.replaceAll(RegExp(r'[^A-Za-z]'), '');
  if (letters.isEmpty) return 'GT';
  return letters
      .substring(0, letters.length >= 3 ? 3 : letters.length)
      .toUpperCase();
}

/// 15 · By Module — build your own plan. Bound to the catalog (the learner's
/// grade → subjects → chapters) with each module's product and price resolved
/// on demand, and a live cart bar driven by CartProvider. Layout unchanged.
class ByModuleScreen extends StatefulWidget {
  const ByModuleScreen({super.key});

  @override
  State<ByModuleScreen> createState() => _ByModuleScreenState();
}

class _ByModuleScreenState extends State<ByModuleScreen> {
  bool _loading = true;
  String? _error;
  String? _gradeId;
  List<SubjectModel> _subjects = const <SubjectModel>[];

  final Set<String> _open = <String>{};
  final Map<String, List<Chapter>> _chapters = <String, List<Chapter>>{};
  final Set<String> _subjectLoading = <String>{};
  // chapterId -> module product (absent = not fetched, null = none available)
  final Map<String, Product?> _product = <String, Product?>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    context.read<CartProvider>().load();

    _gradeId = context.read<AuthProvider>().user?.profile?.gradeId;
    if (_gradeId == null) {
      setState(() {
        _loading = false;
        _error = 'Complete onboarding to build a custom plan.';
      });
      return;
    }
    final Grade? grade = await context.read<CatalogProvider>().loadGrade(_gradeId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (grade == null) {
        _error = context.read<CatalogProvider>().error ??
            'Couldn\'t load the catalogue.';
      } else {
        _subjects = grade.subjects;
      }
    });
  }

  Future<void> _toggleSubject(String subjectId) async {
    setState(() {
      if (_open.contains(subjectId)) {
        _open.remove(subjectId);
      } else {
        _open.add(subjectId);
      }
    });
    if (!_open.contains(subjectId) || _chapters.containsKey(subjectId)) return;

    setState(() => _subjectLoading.add(subjectId));
    final SubjectModel? s =
        await context.read<CatalogProvider>().loadSubject(subjectId);
    if (!mounted) return;
    final List<Chapter> chapters = s?.chapters ?? const <Chapter>[];
    setState(() {
      _subjectLoading.remove(subjectId);
      _chapters[subjectId] = chapters;
    });
    for (final Chapter c in chapters) {
      _loadModuleProduct(c.id);
    }
  }

  Future<void> _loadModuleProduct(String chapterId) async {
    if (_product.containsKey(chapterId)) return;
    final Chapter? c = await context.read<CatalogProvider>().loadChapter(chapterId);
    if (!mounted) return;
    Product? module;
    if (c != null) {
      for (final Product p in c.products) {
        if (p.type == 'MODULE' || p.chapterId == chapterId) {
          module = p;
          break;
        }
      }
      module ??= c.products.isNotEmpty ? c.products.first : null;
    }
    setState(() => _product[chapterId] = module);
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.signalRed,
    ));
  }

  Future<void> _toggleCart(Product product, bool inCart) async {
    final CartProvider cart = context.read<CartProvider>();
    if (inCart) {
      await cart.remove(product.id);
    } else {
      final String? err = await cart.add(product.id);
      if (err != null) _snack(err);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CartProvider cart = context.watch<CartProvider>();

    return AppScaffold(
      safeBottom: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _OutlineIcon(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => Navigator.maybePop(context)),
                Text('Build Your Plan',
                    style: AppTextStyles.heading.copyWith(fontSize: 15)),
                _OutlineIcon(icon: Icons.bookmark_border_rounded, onTap: () {}),
              ],
            ),
          ),
          Expanded(child: _content()),
          _CartBar(
            count: cart.count,
            total: cart.quote.totalLabel,
            onView: () => Navigator.pushNamed(context, AppRoutes.cart),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    if (_loading) {
      return const LoadingIndicator(message: 'Loading catalogue…');
    }
    if (_error != null) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'Couldn\'t load',
        message: _error!,
        actionLabel: 'Retry',
        onAction: _load,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 18),
      children: <Widget>[
        _SegmentedHeader(
          onFull: () => Navigator.maybePop(context),
          onSubject: () => Navigator.maybePop(context),
        ),
        const SizedBox(height: 18),
        Text(
          'Add only the chapters you need. Mix modules across subjects — your cart updates live.',
          style: AppTextStyles.body.copyWith(color: AppColors.slate, height: 1.5),
        ),
        const SizedBox(height: 16),
        if (_subjects.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 30),
            child: EmptyState(
              icon: Icons.grid_view_rounded,
              title: 'Nothing to build yet',
              message: 'Modules for your class are being prepared.',
            ),
          )
        else
          ..._subjects.map(_buildGroup),
      ],
    );
  }

  Widget _buildGroup(SubjectModel g) {
    final bool open = _open.contains(g.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: open ? const Color(0xFFE0E6F0) : AppColors.borderSoft,
              width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () => _toggleSubject(g.id),
                child: Container(
                  color: open ? AppColors.surface : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: <Widget>[
                      HatchTile(
                          width: 38,
                          height: 38,
                          radius: 11,
                          label: g.code ?? _mono(g.name)),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(g.name, style: AppTextStyles.cardTitle),
                            const SizedBox(height: 1),
                            Text(
                                '${g.chapterCount} module${g.chapterCount == 1 ? '' : 's'}',
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.muted)),
                          ],
                        ),
                      ),
                      Icon(
                        open
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.chevron_right_rounded,
                        size: 19,
                        color: open ? AppColors.slate : AppColors.muted,
                      ),
                    ],
                  ),
                ),
              ),
              if (open) _groupBody(g.id),
            ],
          ),
        ),
      ),
    );
  }

  Widget _groupBody(String subjectId) {
    if (_subjectLoading.contains(subjectId)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: LoadingIndicator(size: 22),
      );
    }
    final List<Chapter> chapters = _chapters[subjectId] ?? const <Chapter>[];
    if (chapters.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFEEF1F6)))),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        alignment: Alignment.centerLeft,
        child: const Text('No modules in this subject yet.',
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.muted)),
      );
    }

    final CartProvider cart = context.watch<CartProvider>();
    return Column(
      children: chapters.map((Chapter m) {
        final bool fetched = _product.containsKey(m.id);
        final Product? product = _product[m.id];
        final bool inCart = product != null &&
            cart.quote.lines.any((l) => l.productId == product.id);
        final String price = product?.priceFor()?.displayPrice ?? '—';

        return Container(
          decoration: BoxDecoration(
            color: inCart ? const Color(0xFFFBFCFE) : Colors.white,
            border: const Border(top: BorderSide(color: Color(0xFFEEF1F6))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(m.name,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: inCart ? AppColors.ink : AppColors.bodyText)),
                    const SizedBox(height: 1),
                    Text(
                        '${m.lessonCount} lesson${m.lessonCount == 1 ? '' : 's'}${price == '—' ? '' : ' · $price'}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.muted)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (!fetched)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.muted),
                )
              else if (product == null)
                const Text('—',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted))
              else
                _AddToggle(
                  added: inCart,
                  onTap: () => _toggleCart(product, inCart),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _OutlineIcon extends StatelessWidget {
  const _OutlineIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE7EAF0), width: 1.5),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(icon, size: 20, color: AppColors.ink),
      ),
    );
  }
}

class _SegmentedHeader extends StatelessWidget {
  const _SegmentedHeader({required this.onFull, required this.onSubject});

  final VoidCallback onFull;
  final VoidCallback onSubject;

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>['Full Class', 'By Subject', 'By Module'];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double segWidth = (constraints.maxWidth - 8) / 3;
        return Container(
          height: 50,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.trackBg,
            borderRadius: BorderRadius.circular(AppRadius.input),
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: segWidth * 2,
                top: 0,
                bottom: 0,
                width: segWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
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
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onFull,
                      child: Center(
                        child: Text(labels[0],
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.muted)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onSubject,
                      child: Center(
                        child: Text(labels[1],
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.muted)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(labels[2],
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddToggle extends StatelessWidget {
  const _AddToggle({required this.added, required this.onTap});

  final bool added;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: added ? AppColors.navy : Colors.transparent,
          border: Border.all(color: AppColors.navy, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(added ? Icons.check_rounded : Icons.add_rounded,
                size: 13, color: added ? Colors.white : AppColors.navy),
            const SizedBox(width: 5),
            Text(added ? 'Added' : 'Add',
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: added ? Colors.white : AppColors.navy)),
          ],
        ),
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  const _CartBar({
    required this.count,
    required this.total,
    required this.onView,
  });

  final int count;
  final String total;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF1F6))),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 13, 20, 22 + MediaQuery.of(context).padding.bottom),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('$count ${count == 1 ? 'item' : 'items'} in cart',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1,
                      color: AppColors.muted)),
              const SizedBox(height: 3),
              Text(total,
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: GestureDetector(
              onTap: onView,
              child: Container(
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.navy,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                  boxShadow: AppShadows.primaryButton,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('View Cart',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        size: 18, color: Colors.white),
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
