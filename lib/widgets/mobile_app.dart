import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../screens/home_screen.dart';
import '../screens/groups_screen.dart';
import '../screens/group_detail_screen.dart';
import '../screens/subscriptions_screen.dart';
import '../screens/settlements_screen.dart';
import '../screens/profile_screen.dart';
import 'create_group_modal.dart';

class MobileApp extends StatefulWidget {
  final AppUser currentUser;
  final VoidCallback onLogout;

  const MobileApp({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  int _currentIndex = 0;
  late List<Group> _groups;
  late List<Expense> _expenses;
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _groups = List<Group>.from(MockData.groups);
    _expenses = List<Expense>.from(MockData.expenses);
    _notifications = List<AppNotification>.from(MockData.notifications);
  }

  void _addExpense(Expense expense) {
    setState(() {
      _expenses.insert(0, expense);
    });
  }

  void _addGroup(Group group) {
    setState(() {
      _groups.add(group);
    });
  }

  void _showCreateGroup() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateGroupModal(
        currentUser: widget.currentUser,
        onCreate: _addGroup,
      ),
    );
  }

  void _navigateToGroup(Group group) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroupDetailScreen(
          group: group,
          allExpenses: _expenses,
          currentUser: widget.currentUser,
          onAddExpense: _addExpense,
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_currentIndex) {
      case 0:
        return HomeScreen(
          currentUser: widget.currentUser,
          expenses: _expenses,
          groups: _groups,
          notifications: _notifications,
        );
      case 1:
        return GroupsScreen(
          currentUser: widget.currentUser,
          groups: _groups,
          expenses: _expenses,
          onCreateGroup: _showCreateGroup,
          onSelectGroup: _navigateToGroup,
        );
      case 2:
        return SubscriptionsScreen(
          currentUser: widget.currentUser,
          expenses: _expenses,
        );
      case 3:
        return SettlementsScreen(
          currentUser: widget.currentUser,
          expenses: _expenses,
          groups: _groups,
        );
      case 4:
        return ProfileScreen(
          currentUser: widget.currentUser,
          onLogout: widget.onLogout,
        );
      default:
        return HomeScreen(
          currentUser: widget.currentUser,
          expenses: _expenses,
          groups: _groups,
          notifications: _notifications,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _buildScreen(),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      _NavItem(icon: Icons.home_rounded, label: 'Accueil'),
      _NavItem(icon: Icons.group_rounded, label: 'Groupes'),
      _NavItem(icon: Icons.credit_card_rounded, label: 'Abonnements'),
      _NavItem(icon: Icons.handshake_rounded, label: 'Remboursements'),
      _NavItem(icon: Icons.person_rounded, label: 'Profil'),
    ];

    final unreadNotifs =
        _notifications.where((n) => !n.read).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = _currentIndex == index;
              final showBadge = index == 0 && unreadNotifs > 0;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 2),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryBg
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              item.icon,
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 22,
                            ),
                            if (showBadge)
                              Positioned(
                                top: -3,
                                right: -3,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isActive ? 5 : 0,
                          height: isActive ? 5 : 0,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
