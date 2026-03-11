import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/mock_data.dart';
import '../utils/debt_calculator.dart';

class SettlementsScreen extends StatefulWidget {
  final AppUser currentUser;
  final List<Expense> expenses;
  final List<Group> groups;

  const SettlementsScreen({
    super.key,
    required this.currentUser,
    required this.expenses,
    required this.groups,
  });

  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  late List<Settlement> _settlements;

  @override
  void initState() {
    super.initState();
    _settlements = List<Settlement>.from(MockData.settlements);
  }

  void _showSettleModal(Debt debt, String groupId) {
    String selectedMethod = 'virement';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final toUser = MockData.getUserById(debt.to);
          final fromUser = MockData.getUserById(debt.from);
          final isCurrentUserDebtor = debt.from == widget.currentUser.id;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.handshake_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),

                Text(
                  isCurrentUserDebtor
                      ? 'Rembourser ${toUser?.name ?? '?'}'
                      : '${fromUser?.name ?? '?'} vous rembourse',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),

                // Amount
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryBorder),
                  ),
                  child: Text(
                    formatAmount(debt.amount),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Payment method
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Moyen de paiement',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildMethodRow(
                    selectedMethod, (m) => setModalState(() => selectedMethod = m)),
                const SizedBox(height: 24),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        final settlement = Settlement(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          groupId: groupId,
                          fromUserId: debt.from,
                          toUserId: debt.to,
                          amount: debt.amount,
                          date: DateTime.now(),
                          method: selectedMethod,
                        );
                        setState(() {
                          _settlements.insert(0, settlement);
                          MockData.settlements.insert(0, settlement);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Remboursement enregistré !'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Confirmer le remboursement',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMethodRow(
      String selected, void Function(String) onSelect) {
    const methods = [
      {'value': 'virement', 'label': 'Virement', 'emoji': '🏦'},
      {'value': 'cash', 'label': 'Cash', 'emoji': '💵'},
      {'value': 'lydia', 'label': 'Lydia', 'emoji': '🟣'},
      {'value': 'paylib', 'label': 'PayLib', 'emoji': '🔵'},
    ];
    return Row(
      children: methods.map((m) {
        final isSelected = selected == m['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(m['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryBg : AppColors.surfaceBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderMedium,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(m['emoji']!, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    m['label']!,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Collect all debts from all groups involving current user
    final List<_DebtWithGroup> pendingDebts = [];
    for (final group in widget.groups) {
      final groupExpenses = widget.expenses
          .where((e) => e.groupId == group.id)
          .toList();
      final debts = DebtCalculator.calculate(groupExpenses);
      for (final debt in debts) {
        if (debt.from == widget.currentUser.id ||
            debt.to == widget.currentUser.id) {
          pendingDebts.add(_DebtWithGroup(debt: debt, group: group));
        }
      }
    }

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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Remboursements',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Soldez vos dettes en un tap',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _summaryTile(
                        'À régler',
                        pendingDebts
                            .where((d) => d.debt.from == widget.currentUser.id)
                            .fold(0.0, (s, d) => s + d.debt.amount),
                        AppColors.error,
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.3)),
                    Expanded(
                      child: _summaryTile(
                        'À recevoir',
                        pendingDebts
                            .where((d) => d.debt.to == widget.currentUser.id)
                            .fold(0.0, (s, d) => s + d.debt.amount),
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pending debts
              if (pendingDebts.isEmpty)
                _buildAllSettled()
              else ...[
                _sectionHeader('Dettes en cours', AppColors.textPrimary),
                const SizedBox(height: 12),
                ...pendingDebts.map((d) => _buildDebtCard(d)),
                const SizedBox(height: 24),
              ],

              // History
              if (_settlements.isNotEmpty) ...[
                _sectionHeader('Historique', AppColors.textPrimary),
                const SizedBox(height: 12),
                ..._settlements
                    .take(10)
                    .map((s) => _buildSettlementHistoryCard(s)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryTile(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            formatAmount(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllSettled() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.successBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.successBorder),
      ),
      child: const Column(
        children: [
          Text('🎉', style: TextStyle(fontSize: 40)),
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
            'Vous n\'avez aucune dette en cours.\nFélicitations !',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.success, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtCard(_DebtWithGroup dwg) {
    final fromUser = MockData.getUserById(dwg.debt.from);
    final toUser = MockData.getUserById(dwg.debt.to);
    final isOwes = dwg.debt.from == widget.currentUser.id;
    final fromIdx = MockData.users.indexWhere((u) => u.id == dwg.debt.from);
    final toIdx = MockData.users.indexWhere((u) => u.id == dwg.debt.to);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _avatar(fromUser?.initials ?? '?', fromIdx < 0 ? 0 : fromIdx),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.textMuted, size: 16),
              const SizedBox(width: 8),
              _avatar(toUser?.initials ?? '?', toIdx < 0 ? 1 : toIdx),
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
                    Text(
                      dwg.group.name,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatAmount(dwg.debt.amount),
                style: TextStyle(
                  color: isOwes ? AppColors.error : AppColors.success,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (isOwes) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _showSettleModal(dwg.debt, dwg.group.id),
              child: Container(
                width: double.infinity,
                height: 42,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.handshake_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Rembourser',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettlementHistoryCard(Settlement s) {
    final fromUser = MockData.getUserById(s.fromUserId);
    final toUser = MockData.getUserById(s.toUserId);
    const months = [
      'jan', 'fév', 'mar', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    final dateStr = '${s.date.day} ${months[s.date.month - 1]} ${s.date.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${fromUser?.name ?? '?'} → ${toUser?.name ?? '?'}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$dateStr · ${_methodLabel(s.method)}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            formatAmount(s.amount),
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(String initials, int index) {
    final colors = AppColors.getAvatarColor(index);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(11),
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

  Widget _sectionHeader(String title, Color color) {
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _methodLabel(String method) {
    switch (method) {
      case 'virement':
        return 'Virement bancaire';
      case 'cash':
        return 'Espèces';
      case 'lydia':
        return 'Lydia';
      case 'paylib':
        return 'PayLib';
      case 'revolut':
        return 'Revolut';
      default:
        return method;
    }
  }
}

class _DebtWithGroup {
  final Debt debt;
  final Group group;

  _DebtWithGroup({required this.debt, required this.group});
}
