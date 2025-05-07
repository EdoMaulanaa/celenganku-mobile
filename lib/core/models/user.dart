import 'dart:convert';

class User {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final String? avatarUrl;

  User({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    this.avatarUrl,
  });

  // Copy with method
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  // Dari JSON Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      displayName: map['display_name'],
      createdAt: DateTime.parse(map['created_at']),
      avatarUrl: map['avatar_url'],
    );
  }

  // Dari JSON string
  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  // Ke JSON Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'display_name': displayName,
      'created_at': createdAt.toIso8601String(),
      'avatar_url': avatarUrl,
    };
  }

  // Ke JSON string
  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'User(id: $id, email: $email, displayName: $displayName, createdAt: $createdAt, avatarUrl: $avatarUrl)';
  }
} 