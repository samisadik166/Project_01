import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String childId;
  final String name;
  final int age;
  final String avatarId;
  final DateTime createdAt;
  final int totalStars;

  ChildModel({
    required this.childId,
    required this.name,
    required this.age,
    required this.avatarId,
    required this.createdAt,
    this.totalStars = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'avatarId': avatarId,
      'createdAt': Timestamp.fromDate(createdAt),
      'totalStars': totalStars,
    };
  }

  factory ChildModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChildModel(
      childId: doc.id,
      name: data['name']?.toString() ?? '',
      age: data['age'] is int
          ? data['age'] as int
          : int.tryParse(data['age']?.toString() ?? '') ?? 0,
      avatarId: data['avatarId']?.toString() ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalStars: data['totalStars'] is int
          ? data['totalStars'] as int
          : int.tryParse(data['totalStars']?.toString() ?? '') ?? 0,
    );
  }

  ChildModel copyWith({
    String? childId,
    String? name,
    int? age,
    String? avatarId,
    DateTime? createdAt,
    int? totalStars,
  }) {
    return ChildModel(
      childId: childId ?? this.childId,
      name: name ?? this.name,
      age: age ?? this.age,
      avatarId: avatarId ?? this.avatarId,
      createdAt: createdAt ?? this.createdAt,
      totalStars: totalStars ?? this.totalStars,
    );
  }
}
