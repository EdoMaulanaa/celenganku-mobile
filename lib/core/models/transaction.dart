import 'dart:convert';

class Transaction {
  final String id;
  final double amount;
  final String? note;
  final DateTime date;
  final String goalId;
  final String userId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.amount,
    this.note,
    required this.date,
    required this.goalId,
    required this.userId,
    required this.createdAt,
  });

  // Copy with method untuk membuat salinan dengan beberapa field yang diubah
  Transaction copyWith({
    String? id,
    double? amount,
    String? note,
    DateTime? date,
    String? goalId,
    String? userId,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      goalId: goalId ?? this.goalId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Dari JSON Map
  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      amount: map['amount']?.toDouble() ?? 0.0,
      note: map['note'],
      date: DateTime.parse(map['date']),
      goalId: map['goal_id'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Dari JSON string
  factory Transaction.fromJson(String source) => Transaction.fromMap(json.decode(source));

  // Ke JSON Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'date': date.toIso8601String(),
      'goal_id': goalId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Ke JSON string
  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, note: $note, date: $date, goalId: $goalId, userId: $userId, createdAt: $createdAt)';
  }
} 