import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class Voucher {
  final int id;
  final String voucher_code;
  final String voucher_type_name;
  final int cost_off;
  final String user_created_name;
  final String user_updated_name;
  final String applicable_menu_item_name;
  final String free_menu_item_name;
  final int min_spending;
  final int redeem_point;
  final bool is_available;

  Voucher({
    required this.id,
    required this.voucher_code,
    required this.voucher_type_name,
    required this.cost_off,
    required this.user_created_name,
    required this.user_updated_name,
    required this.applicable_menu_item_name,
    required this.free_menu_item_name,
    required this.min_spending,
    required this.redeem_point,
    required this.is_available,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('MenuItem.fromJson: $json');
    // }
    return Voucher(
      id: json['id'],
      voucher_code: json['voucher_code'],
      voucher_type_name: json['voucher_type_name'],
      cost_off: json['cost_off'] ?? 0,
      user_created_name: json['user_created_name'] ?? '',
      user_updated_name: json['user_updated_name'] ?? '',
      applicable_menu_item_name: json['applicable_menu_item_name'] ?? '',
      free_menu_item_name: json['free_menu_item_name'] ?? '',
      min_spending: json['min_spending'] ?? 0,
      redeem_point: json['redeem_point'] ?? 0,
      is_available: json['is_available'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'voucher_code': voucher_code,
      'voucher_type_name': voucher_type_name,
      'cost_off': cost_off,
      'user_created_name': user_created_name,
      'user_updated_name': user_updated_name,
      'applicable_menu_item_name': applicable_menu_item_name,
      'free_menu_item_name': free_menu_item_name,
      'min_spending': min_spending,
      'redeem_point': redeem_point,
      'is_available': is_available,
    };
  }

  static List<Voucher> getAvailableVoucherList(Map<String, dynamic> json) {
    List<Voucher> availableVoucherList = [];
    for (Map<String,dynamic> availableVoucher in json['data']) {
      Voucher oneAvailableVoucher = Voucher.fromJson(availableVoucher);
      availableVoucherList .add(oneAvailableVoucher);
    }
    return availableVoucherList ;
  }

  static List<Voucher> getVoucherAppliedDetails(Map<String, dynamic> json) {
    List<Voucher> voucherAppliedDetails = [];
    for (Map<String,dynamic> voucherApplied in json['data']) {
      Voucher oneVoucherAppliedDetails = Voucher.fromJson(voucherApplied);
      voucherAppliedDetails.add(oneVoucherAppliedDetails);
    }
    return voucherAppliedDetails ;
  }

}