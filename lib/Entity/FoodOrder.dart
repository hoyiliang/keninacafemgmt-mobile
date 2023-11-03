import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'User.dart';

@JsonSerializable()
class FoodOrder {
  final int id;
  final String order_status;
  final double gross_total;
  final double grand_total;
  final String voucher;
  final String user_created_name;
  final String user_updated_name;
  final DateTime dateTime;

  FoodOrder({
    required this.id,
    required this.order_status,
    required this.gross_total,
    required this.grand_total,
    required this.voucher,
    required this.user_created_name,
    required this.user_updated_name,
    required this.dateTime,
  });

  factory FoodOrder.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('MenuItem.fromJson: $json');
    // }
    return FoodOrder(
      id: json['id'],
      order_status: json['order_status'],
      gross_total: json['gross_total'],
      grand_total: json['grand_total'],
      voucher: json['voucher_name'] != null ? json['voucher_name'] : '',
      user_created_name: json['user_created_name'] != null ? json['user_created_name'] : '',
      user_updated_name: json['user_updated_name'] != null ? json['user_updated_name'] : '',
      dateTime: DateTime.parse(json['date_created']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_status': order_status,
      'gross_total': gross_total,
      'grand_total': grand_total,
      'voucher': voucher,
      'user_created_name': user_created_name,
      'user_updated_name': user_updated_name,
      'dateTime': dateTime,
    };
  }

  static List<FoodOrder> getOrderList(Map<String, dynamic> json) {
    List<FoodOrder> orderList = [];
    for (Map<String,dynamic> order in json['data']) {
      FoodOrder oneOrder = FoodOrder.fromJson(order);
      orderList.add(oneOrder);
    }
    return orderList;
  }

// static List<MenuItem> getItemCategoryExistMenuItemList(Map<String, dynamic> json) {
//   List<MenuItem> itemCategoryExistMenuItemList = [];
//   for (Map<String,dynamic> itemCategoryExistMenuItem in json['data']) {
//     MenuItem oneitemCategoryExistMenuItem = MenuItem.fromJson(itemCategoryExistMenuItem);
//     itemCategoryExistMenuItemList.add(oneitemCategoryExistMenuItem);
//   }
//   return itemCategoryExistMenuItemList;
// }

}