import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class NotificationsScreen extends StatefulWidget {
  final List<AppNotification> notifications;
  final VoidCallback onMarkAllRead;

  const NotificationsScreen({
    super.key,
    required this.notifications,
    required this.onMarkAllRead,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  void _markRead(AppNotification n) {
    setState(() => n.read = true);
  }

  @override
  Widget build(BuildContext context) {
    final unread = widget.notifications.where((n) => !n.read).length;
    final unreadList = widget.notifications.where((n) => !n.read).toList();
    final readList = widget.notifications.where((n) => n.read).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: AppColors.borderMedium),
                        boxShadow: AppShadow.card,
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.textPrimary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notifications',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (unread > 0)
                          Text(
                            '$unread non lue${unread > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (unread > 0)
                    TextButton(
                      onPressed: () {
                        widget.onMarkAllRead();
                        setState(() {});
                      },
                      child: const Text(
                        'Tout lire',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: widget.notifications.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (unreadList.isNotEmpty) ...[
                            _buildSectionTitle('Non lues'),
                            const SizedBox(height: 8),
                            ...unreadList.map((n) => _buildNotifCard(n)),
                            const SizedBox(height: 20),
                          ],
                          if (readList.isNotEmpty) ...[
                            _buildSectionTitle('Lues'),
                            const SizedBox(height: 8),
                            ...readList.map((n) => _buildNotifCard(n)),
                          ],
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucune notification',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Vous serez notifié des nouvelles dépenses\net abonnements automatisés.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard(AppNotification notif) {
    return GestureDetector(
      onTap: () => _markRead(notif),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.read ? AppColors.card : AppColors.primaryBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notif.read ? AppColors.border : AppColors.primaryBorder,
          ),
          boxShadow: AppShadow.card,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _iconBg(notif.type),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                _iconFor(notif.type),
                color: _iconColor(notif.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: notif.read
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!notif.read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notif.createdAt),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'subscription':
        return Icons.auto_awesome_rounded;
      case 'expense':
        return Icons.receipt_long_rounded;
      case 'reminder':
        return Icons.schedule_rounded;
      case 'alert':
        return Icons.warning_amber_rounded;
      case 'invite':
        return Icons.group_add_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'subscription':
        return AppColors.primary;
      case 'expense':
        return const Color(0xFF2563EB);
      case 'reminder':
        return const Color(0xFFD97706);
      case 'alert':
        return AppColors.error;
      case 'invite':
        return AppColors.success;
      default:
        return AppColors.primary;
    }
  }

  Color _iconBg(String type) {
    switch (type) {
      case 'subscription':
        return AppColors.primaryBg;
      case 'expense':
        return const Color(0xFFDBEAFE);
      case 'reminder':
        return const Color(0xFFFFFBEB);
      case 'alert':
        return AppColors.errorBg;
      case 'invite':
        return AppColors.successBg;
      default:
        return AppColors.primaryBg;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
