import 'dart:convert';

class Goal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String? description;
  final DateTime? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    this.description,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });

  // Getter untuk progress dalam persentase
  double get progressPercentage {
    if (targetAmount <= 0) return 0;
    double percentage = (currentAmount / targetAmount) * 100;
    return percentage > 100 ? 100 : percentage;
  }

  // Getter untuk sisa jumlah yang perlu ditabung
  double get remainingAmount {
    return targetAmount - currentAmount < 0 ? 0 : targetAmount - currentAmount;
  }

  // Getter untuk mengecek apakah tujuan sudah tercapai
  bool get isAchieved {
    return currentAmount >= targetAmount;
  }

  // Getter untuk mengecek apakah target date sudah lewat
  bool get isOverdue {
    if (targetDate == null) return false;
    return DateTime.now().isAfter(targetDate!) && !isAchieved;
  }

  // Copy with method untuk membuat salinan dengan beberapa field yang diubah
  Goal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? description,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      description: description ?? this.description,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
    );
  }

  // Dari JSON Map
  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      targetAmount: map['target_amount']?.toDouble() ?? 0.0,
      currentAmount: map['current_amount']?.toDouble() ?? 0.0,
      description: map['description'],
      targetDate: map['target_date'] != null 
          ? DateTime.parse(map['target_date']) 
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      userId: map['user_id'],
    );
  }

  // Dari JSON string
  factory Goal.fromJson(String source) => Goal.fromMap(json.decode(source));

  // Ke JSON Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'description': description,
      'target_date': targetDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }

  // Ke JSON string
  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Goal(id: $id, title: $title, targetAmount: $targetAmount, currentAmount: $currentAmount, description: $description, targetDate: $targetDate, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId)';
  }
} 