import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../utils/debt_calculator.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final AppUser currentUser;
  final List<Expense> expenses;
  final List<Group> groups;
  final List<AppNotification> notifications;

  const HomeScreen({
    super.key,
    required this.currentUser,
    required this.expenses,
    required this.groups,
    this.notifications = const [],
  });

  @override
  Widget build(BuildContext context) {
    final debtMap = DebtCalculator.getDebtsForUser(expenses, currentUser.id);
    final List<Debt> owes = (debtMap['owes'] ?? [])
        .where((d) => !MockData.settledKeys.contains('${d.from}_${d.to}'))
        .toList();
    final List<Debt> owed = (debtMap['owed'] ?? [])
        .where((d) => !MockData.settledKeys.contains('${d.from}_${d.to}'))
        .toList();
    final double totalOwed =
        owes.fold(0.0, (s, d) => s + d.amount);
    final double totalToReceive =
        owed.fold(0.0, (s, d) => s + d.amount);
    final double netBalance = totalToReceive - totalOwed;

    // Monthly total (recurring expenses involving user)
    final recurringExpenses = expenses.where((e) => e.isRecurring).toList();
    double monthlyTotal = 0;
    for (final e in recurringExpenses) {
      if (e.splitBetween.contains(currentUser.id)) {
        monthlyTotal += e.amount / e.splitBetween.length;
      }
    }

    // Recent expenses (last 5)
    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.date.compareTo(a.date));
    final recentExpenses = sortedExpenses.take(5).toList();

    final bool isPositive = netBalance >= 0;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${currentUser.name} 👋',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Voici votre résumé financier',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  _buildNotifBell(context),
                ],
              ),
              const SizedBox(height: 24),

              // Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Solde total',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPositive
                                ? Colors.white.withValues(alpha: 0.2)
                                : Colors.red.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            isPositive ? '✓ Positif' : '↓ Négatif',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${isPositive ? '+' : ''}${formatAmount(netBalance)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPositive
                          ? 'Vous avez un solde créditeur net'
                          : 'Vous avez des dettes en cours',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'Vous devez',
                      amount: totalOwed,
                      color: AppColors.error,
                      bgColor: AppColors.errorBg,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'On vous doit',
                      amount: totalToReceive,
                      color: AppColors.success,
                      bgColor: AppColors.successBg,
                      icon: Icons.arrow_downward_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      label: 'Ce mois',
                      amount: monthlyTotal,
                      color: AppColors.primary,
                      bgColor: AppColors.primaryBg,
                      icon: Icons.calendar_today_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // À rembourser section
              if (owes.isNotEmpty) ...[
                _buildSectionHeader('À rembourser', AppColors.error),
                const SizedBox(height: 12),
                ...owes.map((debt) => _buildDebtCard(debt, isOwes: true)),
                const SizedBox(height: 24),
              ],

              // À recevoir section
              if (owed.isNotEmpty) ...[
                _buildSectionHeader('À recevoir', AppColors.success),
                const SizedBox(height: 12),
                ...owed.map((debt) => _buildDebtCard(debt, isOwes: false)),
                const SizedBox(height: 24),
              ],

              // No debts card
              if (owes.isEmpty && owed.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.successBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.successBorder),
                  ),
                  child: const Column(
                    children: [
                      Text('🎉', style: TextStyle(fontSize: 36)),
                      SizedBox(height: 12),
                      Text(
                        'Tout est réglé !',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Vous n\'avez aucune dette en cours. Félicitations !',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Recent expenses
              _buildSectionHeader('Dépenses récentes', AppColors.textPrimary),
              const SizedBox(height: 12),
              ...recentExpenses.map((expense) =>
                  _buildExpenseCard(expense)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifBell(BuildContext context) {
    final unread = notifications.where((n) => !n.read).length;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NotificationsScreen(
            notifications: notifications,
            onMarkAllRead: () {
              for (final n in notifications) {
                n.read = true;
              }
            },
          ),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderMedium),
              boxShadow: AppShadow.card,
            ),
            child: const Icon(Icons.notifications_outlined,
                color: AppColors.textPrimary, size: 22),
          ),
          if (unread > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget(AppUser user, int index) {
    final colors = AppColors.getAvatarColor(index);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors['border']!, width: 1.5),
      ),
      child: Center(
        child: Text(
          user.initials,
          style: TextStyle(
            color: colors['text'],
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required double amount,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadow.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            formatAmount(amount),
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDebtCard(Debt debt, {required bool isOwes}) {
    final fromUser = MockData.getUserById(debt.from);
    final toUser = MockData.getUserById(debt.to);
    final color = isOwes ? AppColors.error : AppColors.success;
    final bgColor = isOwes ? AppColors.errorBg : AppColors.successBg;
    final borderColor = isOwes ? AppColors.errorBorder : AppColors.successBorder;
    final fromIndex = MockData.users.indexWhere((u) => u.id == debt.from);
    final toIndex = MockData.users.indexWhere((u) => u.id == debt.to);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadow.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildAvatarWidget(
              isOwes ? (toUser ?? MockData.users[0]) : (fromUser ?? MockData.users[0]),
              isOwes ? toIndex.clamp(0, 4) : fromIndex.clamp(0, 4)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOwes
                      ? 'Vous devez à ${toUser?.name ?? '?'}'
                      : '${fromUser?.name ?? '?'} vous doit',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    isOwes ? 'À rembourser' : 'À recevoir',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatAmount(debt.amount),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    final payer = MockData.getUserById(expense.paidBy);
    final emoji = categoryEmoji(expense.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadow.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.description,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      'Payé par ${payer?.name ?? '?'}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Text(' · ',
                        style: TextStyle(color: AppColors.textMuted)),
                    Text(
                      formatDateShort(expense.date),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatAmount(expense.amount),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (expense.isRecurring)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Récurrent',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
