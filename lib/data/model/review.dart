import 'package:pizza_management/data/model/pizza.dart';
import 'package:pizza_management/data/model/user.dart';

class Review {
  final int id;
  final int userId;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final User ? user;
  final Pizza ? pizza;

  Review({
    required this.id,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.user,
    this.pizza,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Review && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      userId: json['userId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      pizza: json['pizza'] != null ? Pizza.fromJson(json['pizza']) : null,
    );
  }

  @override
  String toString () => 'Review(id : $id, userId : $userId)';
}