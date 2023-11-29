import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'Stock.dart';
import 'User.dart';

@JsonSerializable()
class Supplier {
  final int id;
  final String image;
  final bool is_active;
  final String name;
  final String PIC;
  final String contact;
  final String email;
  final String address;
  final String user_created_name;
  final String user_updated_name;

  const Supplier({
    required this.id,
    required this.image,
    required this.is_active,
    required this.name,
    required this.PIC,
    required this.contact,
    required this.email,
    required this.address,
    required this.user_created_name,
    required this.user_updated_name,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('Supplier.fromJson: $json');
    // }
    return Supplier(
      id: json['id'],
      image: json['image'] ?? '',
      is_active: json['is_active'],
      name: json['name'],
      PIC: json['PIC'],
      contact: json['contact'],
      email: json['email'],
      address: json['address'],
      user_created_name: json['user_created_name'] ?? '',
      user_updated_name: json['user_updated_name'] ?? '',
    );
  }

  static List<Supplier> getSupplierDataList(Map<String, dynamic> json) {
    List<Supplier> supplierDataList = [];
    for (Map<String,dynamic> supplierData in json['data']) {
      Supplier oneSupplierData = Supplier.fromJson(supplierData);
      supplierDataList.add(oneSupplierData);
    }
    return supplierDataList;
  }
}