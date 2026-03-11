import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../utils/debt_calculator.dart';
import '../widgets/add_expense_modal.dart';

class GroupDetailScreen extends StatefulWidget {
  final Group group;
  final List<Expense> allExpenses;
  final AppUser currentUser;
  final void Function(Expense expense) onAddExpense;

  const GroupDetailScreen({
    super.key,
    required this.group,
    required this.allExpenses,
    required this.currentUser,
    required this.onAddExpense,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  late List<Expense> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = widget.allExpenses
        .where((e) => e.groupId == widget.group.id)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  void didUpdateWidget(GroupDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      _expenses = widget.allExpenses
          .where((e) => e.groupId == widget.group.id)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _showAddExpense() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddExpenseModal(
        group: widget.group,
        currentUser: widget.currentUser,
        onAdd: (expense) {
          widget.onAddExpense(expense);
          setState(() {
            _expenses = [expense, ..._expenses];
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _expenses.fold(0.0, (sum, e) => sum + e.amount);
    final debts = DebtCalculator.calculate(_expenses);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
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
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.group.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${widget.group.members.length} membres · ${_expenses.length} dépenses',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Total card gradient
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
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
                        Text(
                          'Total dépensé',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatAmount(totalAmount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          children: widget.group.members.map((member) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                member.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Équilibre des comptes
                  _buildSectionHeader('Équilibre des comptes'),
                  const SizedBox(height: 12),
                  if (debts.isEmpty)
                    _buildAllSettledCard()
                  else
                    ...debts.map((debt) => _buildDebtRow(debt)),
                  const SizedBox(height: 24),

                  // Historique des dépenses
                  _buildSectionHeader('Historique des dépenses'),
                  const SizedBox(height: 12),
                  if (_expenses.isEmpty)
                    _buildNoExpensesCard()
                  else
                    ..._expenses.map((e) => _buildExpenseCard(e)),
                ],
              ),
            ),

            // Sticky button at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBackground,
                  border: Border(
                    top: BorderSide(color: AppColors.border),
                  ),
                ),
                child: GestureDetector(
                  onTap: _showAddExpense,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Ajouter une dépense',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAllSettledCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.successBorder),
      ),
      child: const Row(
        children: [
          Text('🎉', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tout est équilibré !',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Aucune dette en cours dans ce groupe.',
                style: TextStyle(color: AppColors.success, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDebtRow(Debt debt) {
    final fromUser = MockData.getUserById(debt.from);
    final toUser = MockData.getUserById(debt.to);
    final fromIdx = MockData.users.indexWhere((u) => u.id == debt.from);
    final toIdx = MockData.users.indexWhere((u) => u.id == debt.to);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          _miniAvatar(fromUser?.initials ?? '?', fromIdx < 0 ? 0 : fromIdx),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded,
              color: AppColors.textMuted, size: 16),
          const SizedBox(width: 8),
          _miniAvatar(toUser?.initials ?? '?', toIdx < 0 ? 1 : toIdx),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${fromUser?.name ?? '?'} doit à ${toUser?.name ?? '?'}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            formatAmount(debt.amount),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniAvatar(String initials, int index) {
    final colors = AppColors.getAvatarColor(index);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors['border']!, width: 1.5),
      ),
      child: Center(
        child: Text(
          initials.length > 1 ? initials[0] : initials,
          style: TextStyle(
            color: colors['text'],
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildNoExpensesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              color: AppColors.textMuted, size: 40),
          SizedBox(height: 12),
          Text(
            'Aucune dépense',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Ajoutez votre première dépense à ce groupe.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    final payer = MockData.getUserById(expense.paidBy);
    final emoji = categoryEmoji(expense.category);
    final perPerson = expense.amount / expense.splitBetween.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadow.card,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        expense.description,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (expense.isRecurring)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primaryBorder),
                        ),
                        child: const Text(
                          'Récurrent',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
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
                      formatDate(expense.date),
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
          const SizedBox(width: 12),
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
              Text(
                '${formatAmount(perPerson)}/pers.',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
