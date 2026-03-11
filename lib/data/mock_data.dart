import '../models/models.dart';

class MockData {
  static final List<AppUser> users = [
    const AppUser('1', 'Vous', 'vous@exemple.com'),
    const AppUser('2', 'Marie', 'marie@exemple.com'),
    const AppUser('3', 'Thomas', 'thomas@exemple.com'),
    const AppUser('4', 'Sophie', 'sophie@exemple.com'),
  ];

  static final List<Group> groups = [
    Group('1', 'Colocation Paris', [users[0], users[1], users[2]],
        DateTime(2024, 1, 15)),
    Group('2', 'Couple', [users[0], users[3]], DateTime(2024, 2, 1)),
  ];

  static final List<Expense> expenses = [
    Expense('1', '1', 'Loyer Appartement', 1200, '1', ['1', '2', '3'],
        DateTime(2024, 11, 1), true, 1, 'housing'),
    Expense('2', '1', 'Netflix Premium', 17.99, '2', ['1', '2', '3'],
        DateTime(2024, 11, 5), true, 5, 'streaming'),
    Expense('3', '1', 'Électricité EDF', 85, '1', ['1', '2', '3'],
        DateTime(2024, 11, 10), true, 10, 'utilities'),
    Expense('4', '1', 'Courses Carrefour', 124.50, '3', ['1', '2', '3'],
        DateTime(2024, 11, 15), false),
    Expense('5', '2', 'Spotify Duo', 12.99, '1', ['1', '4'],
        DateTime(2024, 11, 8), true, 8, 'music'),
    Expense('6', '2', 'Restaurant', 68, '4', ['1', '4'],
        DateTime(2024, 11, 20), false),
    Expense('7', '1', 'Internet Fibre', 39.99, '3', ['1', '2', '3'],
        DateTime(2024, 11, 1), true, 1, 'utilities'),
  ];

  static List<Expense> getExpensesForGroup(String groupId) {
    return expenses.where((e) => e.groupId == groupId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static List<Expense> getRecurringExpenses() {
    return expenses.where((e) => e.isRecurring).toList()
      ..sort((a, b) => (a.recurringDay ?? 0).compareTo(b.recurringDay ?? 0));
  }

  static AppUser? getUserById(String id) {
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  static Group? getGroupById(String id) {
    try {
      return groups.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  static double getTotalForGroup(String groupId) {
    return getExpensesForGroup(groupId).fold(0.0, (sum, e) => sum + e.amount);
  }

  static double getMonthlyTotal() {
    return getRecurringExpenses().fold(0.0, (sum, e) => sum + e.amount);
  }

  // ── Settlements ──────────────────────────────────────────────────────────
  static final List<Settlement> settlements = [
    Settlement(
      id: 's1',
      groupId: '1',
      fromUserId: '2',
      toUserId: '1',
      amount: 41.66,
      date: DateTime(2025, 1, 18),
      method: 'virement',
    ),
    Settlement(
      id: 's2',
      groupId: '2',
      fromUserId: '4',
      toUserId: '1',
      amount: 34.0,
      date: DateTime(2025, 1, 19),
      method: 'lydia',
    ),
  ];

  // ── Notifications ─────────────────────────────────────────────────────────
  static final List<AppNotification> notifications = [
    AppNotification(
      id: 'n1',
      type: 'subscription',
      title: 'Loyer généré automatiquement',
      body: 'Loyer Appartement 1 200 € a été ajouté ce mois-ci dans Colocation Paris.',
      createdAt: DateTime(2025, 1, 1, 1, 0),
      read: false,
    ),
    AppNotification(
      id: 'n2',
      type: 'expense',
      title: 'Nouvelle dépense',
      body: 'Marie a ajouté Netflix Premium 17,99 € dans Colocation Paris.',
      createdAt: DateTime(2025, 1, 5, 14, 30),
      read: false,
    ),
    AppNotification(
      id: 'n3',
      type: 'reminder',
      title: 'Rappel de remboursement',
      body: 'Fin de mois approche ! Vous avez des dettes en cours dans Colocation Paris.',
      createdAt: DateTime(2025, 1, 28, 9, 0),
      read: true,
    ),
    AppNotification(
      id: 'n4',
      type: 'subscription',
      title: 'Électricité générée automatiquement',
      body: 'Électricité EDF 85 € a été ajouté ce mois-ci dans Colocation Paris.',
      createdAt: DateTime(2025, 1, 10, 1, 0),
      read: true,
    ),
    AppNotification(
      id: 'n5',
      type: 'alert',
      title: 'Budget mensuel dépassé',
      body: 'Votre budget mensuel dans Colocation Paris a dépassé 500 €.',
      createdAt: DateTime(2025, 1, 20, 18, 0),
      read: false,
    ),
  ];
}
