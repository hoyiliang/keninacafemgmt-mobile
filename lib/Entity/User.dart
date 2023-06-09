import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User {
  final int uid;
  final String name;
  final String email;
  final String address;
  final String gender;
  final DateTime dob;

  const User({required this.uid, required this.name, required this.email, required this.address, required this.gender, required this.dob});

  factory User.fromJWT(Map<String, dynamic> jwtDecodedToken) {
    return User(
      uid: jwtDecodedToken['id'],
      name: jwtDecodedToken['name'],
      email: jwtDecodedToken['email'],
      address: jwtDecodedToken['address'],
      gender: jwtDecodedToken['gender'],
      dob: jwtDecodedToken['dob']
    );
  }
}