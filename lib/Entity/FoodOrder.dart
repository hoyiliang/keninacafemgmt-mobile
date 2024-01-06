import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class FoodOrder {
  final int id;
  final String order_status;
  final double gross_total;
  final double grand_total;
  final String voucher_assign_id;
  final String user_created_name;
  final String user_updated_name;
  final DateTime dateTime;
  final String order_mode;
  final String table_num;

  FoodOrder({
    required this.id,
    required this.order_status,
    required this.gross_total,
    required this.grand_total,
    required this.voucher_assign_id,
    required this.user_created_name,
    required this.user_updated_name,
    required this.dateTime,
    required this.order_mode,
    required this.table_num,
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
      voucher_assign_id: json['voucher_assign_id'] ?? '',
      user_created_name: json['user_created_name'] ?? '',
      user_updated_name: json['user_updated_name'] ?? '',
      dateTime: DateTime.parse(json['date_created']),
      order_mode: json['order_mode'],
      table_num: json['table_num'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_status': order_status,
      'gross_total': gross_total,
      'grand_total': grand_total,
      'voucher_assign_id': voucher_assign_id,
      'user_created_name': user_created_name,
      'user_updated_name': user_updated_name,
      'dateTime': dateTime,
      'order_mode': order_mode,
      'table_num': table_num,
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