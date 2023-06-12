import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

@JsonSerializable()
class User {
  final int uid;
  final String image;
  final bool is_staff;
  final String staff_type;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String gender;
  final DateTime dob;
  final String ic;

  const User({
    required this.uid,
    required this.image,
    required this.is_staff,
    required this.staff_type,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.ic,
      });

  factory User.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('User.fromJson: $json');
    }
    return User(
        uid: json['uid'],
        image: json['image'],
        is_staff: json['is_staff'],
        staff_type: json['staff_type'],
        name: json['name'],
        email: json['email'],
        address: json['address'],
        phone: json['phone'],
        gender: json['gender'],
        dob: DateTime.parse(json['dob']),
        ic: json['ic'],
    );
  }

  factory User.fromJWT(String jwtToken) {
    Map<String, dynamic> jwtDecodedToken = JwtDecoder.decode(jwtToken);
    return User(
      uid: jwtDecodedToken['uid'],
      image: jwtDecodedToken['image'],
      is_staff: jwtDecodedToken['is_staff'],
      staff_type: jwtDecodedToken['staff_type'],
      name: jwtDecodedToken['name'],
      email: jwtDecodedToken['email'],
      address: jwtDecodedToken['address'],
      phone: jwtDecodedToken['phone'],
      gender: jwtDecodedToken['gender'],
      dob: DateTime.parse(jwtDecodedToken['dob']),
      ic: jwtDecodedToken['ic'],
    );
  }
}