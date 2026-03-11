class AppUser {
  final String id;
  final String name;
  final String email;

  const AppUser(this.id, this.name, this.email);

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppUser && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Group {
  final String id;
  final String name;
  final List<AppUser> members;
  final DateTime createdAt;

  const Group(this.id, this.name, this.members, this.createdAt);
}

class Expense {
  final String id;
  final String groupId;
  final String description;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;
  final DateTime date;
  final bool isRecurring;
  final int? recurringDay;
  final String? category;

  const Expense(
    this.id,
    this.groupId,
    this.description,
    this.amount,
    this.paidBy,
    this.splitBetween,
    this.date,
    this.isRecurring, [
    this.recurringDay,
    this.category,
  ]);

  Expense copyWith({
    String? id,
    String? groupId,
    String? description,
    double? amount,
    String? paidBy,
    List<String>? splitBetween,
    DateTime? date,
    bool? isRecurring,
    int? recurringDay,
    String? category,
  }) {
    return Expense(
      id ?? this.id,
      groupId ?? this.groupId,
      description ?? this.description,
      amount ?? this.amount,
      paidBy ?? this.paidBy,
      splitBetween ?? this.splitBetween,
      date ?? this.date,
      isRecurring ?? this.isRecurring,
      recurringDay ?? this.recurringDay,
      category ?? this.category,
    );
  }
}

class Debt {
  final String from;
  final String to;
  final double amount;

  const Debt({required this.from, required this.to, required this.amount});
}

class Settlement {
  final String id;
  final String groupId;
  final String fromUserId;
  final String toUserId;
  final double amount;
  final DateTime date;
  final String method; // 'virement', 'cash', 'lydia', 'paylib', 'revolut'

  const Settlement({
    required this.id,
    required this.groupId,
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
    required this.date,
    this.method = 'virement',
  });
}

class AppNotification {
  final String id;
  final String type; // 'subscription', 'expense', 'reminder', 'alert', 'invite'
  final String title;
  final String body;
  final DateTime createdAt;
  bool read;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.read = false,
  });
}

// Category emojis helper
String categoryEmoji(String? category) {
  switch (category) {
    case 'housing':
      return '🏠';
    case 'streaming':
      return '🎬';
    case 'utilities':
      return '⚡';
    case 'music':
      return '🎵';
    case 'food':
      return '🛒';
    case 'restaurant':
      return '🍽️';
    case 'transport':
      return '🚗';
    case 'sports':
      return '🏋️';
    default:
      return '💳';
  }
}

String categoryLabel(String? category) {
  switch (category) {
    case 'housing':
      return 'Logement';
    case 'streaming':
      return 'Streaming';
    case 'utilities':
      return 'Charges';
    case 'music':
      return 'Musique';
    case 'food':
      return 'Courses';
    case 'restaurant':
      return 'Restaurant';
    case 'transport':
      return 'Transport';
    case 'sports':
      return 'Sport';
    default:
      return 'Autre';
  }
}

// Date formatting helper (no intl package)
String formatDate(DateTime date) {
  const months = [
    'jan.',
    'fév.',
    'mar.',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sep.',
    'oct.',
    'nov.',
    'déc.',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatDateShort(DateTime date) {
  const months = [
    'jan',
    'fév',
    'mar',
    'avr',
    'mai',
    'juin',
    'juil',
    'août',
    'sep',
    'oct',
    'nov',
    'déc',
  ];
  return '${date.day} ${months[date.month - 1]}';
}

String formatAmount(double amount) {
  if (amount == amount.truncate()) {
    return '${amount.toStringAsFixed(0)} €';
  }
  return '${amount.toStringAsFixed(2)} €';
}
