import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

@JsonSerializable()
class Supplier {
  final String image;
  final bool is_active;
  final String name;
  final String pic;
  final String contact;
  final String email;
  final String address;

  const Supplier({
    required this.image,
    required this.is_active,
    required this.name,
    required this.pic,
    required this.contact,
    required this.email,
    required this.address,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Supplier.fromJson: $json');
    }
    return Supplier(
      image: json['image'],
      is_active: json['is_active'],
      name: json['name'],
      pic: json['pic'],
      contact: json['contact'],
      email: json['email'],
      address: json['address'],
    );
  }

  factory Supplier.fromJWT(String jwtToken) {
    final jwt = JWT.verify(jwtToken, SecretKey('authsecret')); // Verify token from legit source
    Map<String, dynamic> jwtDecodedToken = jwt.payload;
    print(jwtDecodedToken['points'].runtimeType);
    return Supplier(
        image: jwtDecodedToken['image'],
        is_active: jwtDecodedToken['is_active'],
        name: jwtDecodedToken['name'],
        pic: jwtDecodedToken['pic'],
        contact: jwtDecodedToken['contact'],
        email: jwtDecodedToken['email'],
        address: jwtDecodedToken['address'],
    );
  }

  static List<Supplier> getSupplierDataList(String jwtToken) {
    final jwt = JWT.verify(jwtToken, SecretKey('authsecret')); // Verify token from legit source
    Map<String,dynamic> jwtDecodedToken = jwt.payload;
    List<Supplier> supplierDataList = [];
    for (Map<String,dynamic> supplierData in jwtDecodedToken['data']) {
      Supplier oneStaffData = Supplier.fromJson(supplierData);
      supplierDataList.add(oneStaffData);
    }
    return supplierDataList;
  }
}