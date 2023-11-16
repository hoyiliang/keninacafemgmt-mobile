import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'User.dart';

@JsonSerializable()
class VoucherType {
  final int id;
  final String type_name;

  VoucherType({
    required this.id,
    required this.type_name,
  });

  factory VoucherType.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('MenuItem.fromJson: $json');
    // }
    return VoucherType(
      id: json['id'],
      type_name: json['type_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type_name': type_name,
    };
  }

  static List<String> getVoucherTypeList(Map<String, dynamic> json) {
    List<String> voucherTypeList = [];
    for (Map<String,dynamic> voucherType in json['data']) {
      String oneVoucherType = VoucherType.fromJson(voucherType).type_name;
      voucherTypeList.add(oneVoucherType);
    }
    return voucherTypeList ;
  }

}