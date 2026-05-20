import 'package:flutter_demo/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int age;
  final String role;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        age: json['age'] as int? ?? 0,
        role: json['role'] as String? ?? 'user',
      );

  UserEntity toEntity() => UserEntity(
        id: id,
        username: username,
        email: email,
        firstName: firstName,
        lastName: lastName,
        age: age,
        role: role,
      );
}
