import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../screens/home_screen.dart';
import '../screens/groups_screen.dart';
import '../screens/group_detail_screen.dart';
import '../screens/subscriptions_screen.dart';
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

  @override
  void initState() {
    super.initState();
    _groups = List<Group>.from(MockData.groups);
    _expenses = List<Expense>.from(MockData.expenses);
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
        return ProfileScreen(
          currentUser: widget.currentUser,
          onLogout: widget.onLogout,
        );
      default:
        return HomeScreen(
          currentUser: widget.currentUser,
          expenses: _expenses,
          groups: _groups,
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
      _NavItem(icon: Icons.person_rounded, label: 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = _currentIndex == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _currentIndex = index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? const Color(0xFFF5F3FF)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textMuted,
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          style: TextStyle(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isActive ? 6 : 0,
                          height: isActive ? 6 : 0,
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
