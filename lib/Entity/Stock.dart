import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';
import 'Supplier.dart';

@JsonSerializable()
class Stock {
  final int id;
  final String name;
  final Supplier supplier;

  Stock({
    required this.id,
    required this.name,
    required this.supplier,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Stock.fromJson: $json');
    }
    return Stock(
      id: json['id'],
      name: json['name'],
      // supplier: json['supplier'],
      supplier: json['supplier'] != null ? Supplier.fromJson(json['supplier']) : Supplier(id: 0, image: '', name: '', PIC: '', contact: '', email: '', address: '', is_active: false, user_created_name: '', user_updated_name: ''),
    );
  }

  static List<String> getStockNameList(Map<String, dynamic> json) {
    List<String> stockNameList = [];
    for (Map<String,dynamic> stockData in json['data']) {
      String oneStockName = Stock.fromJson(stockData).name;
      stockNameList.add(oneStockName);
    }
    return stockNameList;
  }

  static Tuple2<List<String>, List<String>> getStockDataListWithSupplier(Map<String, dynamic> json) {
    List<String> stockNameList = [];
    List<String> stockNameListWithSupplier = [];
    List<Map<String, dynamic>> all_stock = List<Map<String, dynamic>>.from(json['data']['all_stock']);
    List<Map<String, dynamic>> all_stock_with_current_supplier = List<Map<String, dynamic>>.from(json['data']['all_stock_with_current_supplier']);
    for (Map<String,dynamic> stockData in all_stock) {
      Stock oneStockName = Stock.fromJson(stockData);
      stockNameList.add(oneStockName.name);
    }
    for (Map<String,dynamic> stockDataWithSupplier in all_stock_with_current_supplier) {
      Stock oneStockNameWithSupplier = Stock.fromJson(stockDataWithSupplier);
      stockNameListWithSupplier.add(oneStockNameWithSupplier.name);
    }
    return Tuple2<List<String>, List<String>>(stockNameList, stockNameListWithSupplier);
    // return (stockNameList, stockNameListWithSupplier);
  }
}