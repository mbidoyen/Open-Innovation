import '../models/models.dart';

class DebtCalculator {
  /// Calculates simplified debts from a list of expenses for the given user IDs.
  static List<Debt> calculate(List<Expense> expenses) {
    // net[userId] = net balance (positive = owed money, negative = owes money)
    final Map<String, Map<String, double>> owes = {};
    // owes[from][to] = amount from owes to

    for (final expense in expenses) {
      if (expense.splitBetween.isEmpty) continue;
      final double share = expense.amount / expense.splitBetween.length;

      for (final userId in expense.splitBetween) {
        if (userId == expense.paidBy) continue;
        // userId owes expense.paidBy the share amount
        owes.putIfAbsent(userId, () => {});
        owes[userId]!.putIfAbsent(expense.paidBy, () => 0.0);
        owes[userId]![expense.paidBy] = owes[userId]![expense.paidBy]! + share;
      }
    }

    // Simplify mutual debts
    final List<Debt> debts = [];
    final processedPairs = <String>{};

    for (final from in owes.keys) {
      for (final to in owes[from]!.keys) {
        final pairKey =
            [from, to].toList()..sort();
        final key = '${pairKey[0]}_${pairKey[1]}';

        if (processedPairs.contains(key)) continue;
        processedPairs.add(key);

        final aOwesB = owes[from]?[to] ?? 0.0;
        final bOwesA = owes[to]?[from] ?? 0.0;

        final net = aOwesB - bOwesA;

        if (net > 0.005) {
          debts.add(Debt(from: from, to: to, amount: _round(net)));
        } else if (net < -0.005) {
          debts.add(Debt(from: to, to: from, amount: _round(-net)));
        }
      }
    }

    debts.sort((a, b) => b.amount.compareTo(a.amount));
    return debts;
  }

  /// Returns debts relevant to a specific user:
  /// - debts where user is 'from' (user owes someone)
  /// - debts where user is 'to' (someone owes user)
  static Map<String, List<Debt>> getDebtsForUser(
      List<Expense> expenses, String userId) {
    final allDebts = calculate(expenses);

    final List<Debt> owes =
        allDebts.where((d) => d.from == userId).toList();
    final List<Debt> owed =
        allDebts.where((d) => d.to == userId).toList();

    return {'owes': owes, 'owed': owed};
  }

  /// Net balance for user (positive = net creditor, negative = net debtor)
  static double getNetBalance(List<Expense> expenses, String userId) {
    final allDebts = calculate(expenses);
    double balance = 0.0;

    for (final debt in allDebts) {
      if (debt.to == userId) balance += debt.amount;
      if (debt.from == userId) balance -= debt.amount;
    }

    return _round(balance);
  }

  static double getTotalOwed(List<Expense> expenses, String userId) {
    final allDebts = calculate(expenses);
    return _round(
        allDebts.where((d) => d.from == userId).fold(0.0, (s, d) => s + d.amount));
  }

  static double getTotalToReceive(List<Expense> expenses, String userId) {
    final allDebts = calculate(expenses);
    return _round(
        allDebts.where((d) => d.to == userId).fold(0.0, (s, d) => s + d.amount));
  }

  static double _round(double value) {
    return (value * 100).round() / 100;
  }
}
