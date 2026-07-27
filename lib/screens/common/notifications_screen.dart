import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/text_styles.dart';
import '../../models/api/notification.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/icon_tile_button.dart';
import '../../widgets/feedback/empty_state.dart';
import '../../widgets/feedback/loading_indicator.dart';

/// 11 · Notifications. Live feed backed by [NotificationProvider], grouped into
/// Today / Earlier, with mark-as-read on tap and "Mark all read".
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().load();
    });
  }

  /// (icon, background, foreground) styling per notification type.
  (IconData, Color, Color) _styleFor(String type) {
    switch (type) {
      case 'PAYMENT':
        return (Icons.check_rounded, const Color(0xFFE7ECF6), AppColors.navy);
      case 'OFFER':
      case 'PRICE_DROP':
        return (Icons.sell_outlined, AppColors.redBg, AppColors.signalRed);
      case 'DOUBT_ANSWERED':
        return (
          Icons.chat_bubble_outline_rounded,
          AppColors.surfaceAlt,
          AppColors.navy
        );
      case 'LIVE':
        return (Icons.podcasts_rounded, AppColors.surfaceAlt, AppColors.navy);
      case 'CONTENT':
      case 'NEW_CONTENT':
        return (
          Icons.star_outline_rounded,
          AppColors.surfaceAlt,
          AppColors.navy
        );
      default:
        return (
          Icons.notifications_none_rounded,
          AppColors.surfaceAlt,
          AppColors.navy
        );
    }
  }

  bool _isToday(DateTime? d) {
    if (d == null) return false;
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final items = provider.items;
    final today = items.where((n) => _isToday(n.createdAt)).toList();
    final earlier = items.where((n) => !_isToday(n.createdAt)).toList();

    final loading = provider.status.isLoading && items.isEmpty;
    final error = provider.status.isError && items.isEmpty;

    return AppScaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // White header with title + "Mark all read".
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Row(
              children: [
                if (Navigator.of(context).canPop()) ...[
                  IconTileButton(
                    icon: Icons.chevron_left,
                    iconSize: 24,
                    bordered: true,
                    background: Colors.white,
                    iconColor: AppColors.ink,
                    size: 42,
                    onTap: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text('Notifications',
                      style:
                          AppTextStyles.titleSm.copyWith(letterSpacing: -0.3)),
                ),
                GestureDetector(
                  onTap: provider.unread == 0
                      ? null
                      : () =>
                          context.read<NotificationProvider>().markAllRead(),
                  child: Text('Mark all read',
                      style: AppTextStyles.label.copyWith(
                        fontSize: 12.5,
                        color: provider.unread == 0
                            ? AppColors.muted
                            : AppColors.navy,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSofter),
          Expanded(
            child: loading
                ? const LoadingIndicator()
                : error
                    ? EmptyState(
                        icon: Icons.wifi_off_rounded,
                        title: 'Something went wrong',
                        message:
                            provider.error ?? 'Could not load notifications.',
                        actionLabel: 'Retry',
                        onAction: () =>
                            context.read<NotificationProvider>().load(),
                      )
                    : items.isEmpty
                        ? const EmptyState(
                            icon: Icons.notifications_none_rounded,
                            title: 'No notifications',
                            message:
                                "You're all caught up. New updates will show up here.",
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                            children: [
                              if (today.isNotEmpty) ...[
                                _groupLabel('Today'),
                                const SizedBox(height: 11),
                                _card(today.map(_tile).toList()),
                                const SizedBox(height: 20),
                              ],
                              if (earlier.isNotEmpty) ...[
                                _groupLabel('Earlier'),
                                const SizedBox(height: 11),
                                _card(earlier.map(_tile).toList()),
                              ],
                            ],
                          ),
          ),
        ],
      ),
    );
  }

  Widget _tile(NotificationModel n) {
    final style = _styleFor(n.type);
    return _NotificationTile(
      icon: style.$1,
      iconBg: style.$2,
      iconColor: style.$3,
      title: n.title,
      body: n.body,
      time: n.timeLabel,
      unread: !n.read,
      onTap: n.read
          ? null
          : () => context.read<NotificationProvider>().markRead(n.id),
    );
  }

  Widget _groupLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(text.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              fontSize: 11.5,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            )),
      );

  Widget _card(List<Widget> tiles) {
    final children = <Widget>[];
    for (int i = 0; i < tiles.length; i++) {
      if (i != 0) {
        children.add(const Divider(height: 1, color: Color(0xFFF0F2F7)));
      }
      children.add(tiles[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141A2A).withValues(alpha: 0.18),
            blurRadius: 18,
            spreadRadius: -16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  final bool unread;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.cardTitle
                          .copyWith(fontSize: 13.5, height: 1.3)),
                  const SizedBox(height: 2),
                  Text(body,
                      style: AppTextStyles.body.copyWith(
                          fontSize: 12, color: AppColors.slate, height: 1.4)),
                  const SizedBox(height: 5),
                  Text(time,
                      style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.iconMuted)),
                ],
              ),
            ),
            if (unread)
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: AppColors.navy, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
