import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final int age;
  final String role;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.role,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'age': age,
        'role': role,
      };

  factory UserEntity.fromMap(Map<String, dynamic> map) => UserEntity(
        id: map['id'] as int,
        username: map['username'] as String,
        email: map['email'] as String,
        firstName: map['first_name'] as String,
        lastName: map['last_name'] as String,
        age: map['age'] as int,
        role: map['role'] as String,
      );

  @override
  List<Object?> get props =>
      [id, username, email, firstName, lastName, age, role];
}
