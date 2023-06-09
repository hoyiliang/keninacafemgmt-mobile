import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

@JsonSerializable()
class User {
  final int uid;
  final String image;
  final bool is_staff;
  final bool is_active;
  final String staff_type;
  final String name;
  final String email;
  final String address;
  final String phone;
  final String gender;
  final DateTime dob;
  final String ic;
  final int points;

  const User({
    required this.uid,
    required this.image,
    required this.is_staff,
    required this.is_active,
    required this.staff_type,
    required this.name,
    required this.email,
    required this.address,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.ic,
    required this.points,
      });

  factory User.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('User.fromJson: $json');
    }
    return User(
        uid: json['uid'],
        image: json['image'],
        is_staff: json['is_staff'],
        is_active: json['is_active'],
        staff_type: json['staff_type'],
        name: json['name'],
        email: json['email'],
        address: json['address'],
        phone: json['phone'],
        gender: json['gender'],
        dob: DateTime.parse(json['dob']),
        ic: json['ic'],
        points: json['points'],
    );
  }

  factory User.fromJWT(String jwtToken) {
    final jwt = JWT.verify(jwtToken, SecretKey('authsecret')); // Verify token from legit source
    Map<String, dynamic> jwtDecodedToken = jwt.payload;
    print(jwtDecodedToken['points'].runtimeType);
    return User(
      uid: jwtDecodedToken['uid'],
      image: jwtDecodedToken['image'],
      is_staff: jwtDecodedToken['is_staff'],
      is_active: jwtDecodedToken['is_active'],
      staff_type: jwtDecodedToken['staff_type'],
      name: jwtDecodedToken['name'],
      email: jwtDecodedToken['email'],
      address: jwtDecodedToken['address'],
      phone: jwtDecodedToken['phone'],
      gender: jwtDecodedToken['gender'],
      dob: DateTime.parse(jwtDecodedToken['dob']),
      ic: jwtDecodedToken['ic'],
      points: jwtDecodedToken['points']
    );
  }

  static List<User> getStaffDataList(String jwtToken) {
    final jwt = JWT.verify(jwtToken, SecretKey('authsecret')); // Verify token from legit source
    Map<String,dynamic> jwtDecodedToken = jwt.payload;
    List<User> staffDataList = [];
    for (Map<String,dynamic> staffData in jwtDecodedToken['users']) {
      User oneStaffData = User.fromJson(staffData);
      staffDataList.add(oneStaffData);
    }
    return staffDataList;
  }

  // static List<User> getStaffDataList(Map<String, dynamic> json) {
  //   List<User> staffDataList = [];
  //   for (Map<String,dynamic> staffData in json['data']) {
  //     User oneStaffData = User.fromJson(staffData);
  //     staffDataList.add(oneStaffData);
  //   }
  //   return staffDataList;
  // }
}