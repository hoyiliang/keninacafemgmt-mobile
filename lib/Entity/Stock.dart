import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tuple/tuple.dart';

@JsonSerializable()
class Stock {
  final int id;
  final String name;
  final String supplier_name;
  final DateTime date_start;
  final DateTime date_end;

  Stock({
    required this.id,
    required this.name,
    required this.supplier_name,
    required this.date_start,
    required this.date_end,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('Stock.fromJson: $json');
    // }
    return Stock(
      id: json['id'],
      name: json['name'],
      supplier_name: json['supplier_name'] ?? "",
      date_start: DateTime.parse(json['date_start']),
      date_end: json['date_end'] != null && json['date_end'].isNotEmpty ? DateTime.parse(json['date_end']) : DateTime.parse(json['date_start']),
    );
  }

  static List<String> getSupplierListWithStock(Map<String, dynamic> json) {
    List<String> supplierListWithStock = [];
    String tempSupplierNameWithStock = "";
    for (Map<String,dynamic> supplierWithStock in json['data']) {
      String oneSupplierWithStock = Stock.fromJson(supplierWithStock).supplier_name;
      if (tempSupplierNameWithStock == "") {
        tempSupplierNameWithStock = oneSupplierWithStock;
        supplierListWithStock.add(oneSupplierWithStock);
        continue;
      } else {
        if (tempSupplierNameWithStock == oneSupplierWithStock) {
          continue;
        } else {
          tempSupplierNameWithStock = oneSupplierWithStock;
          supplierListWithStock.add(oneSupplierWithStock);
        }
      }
    }
    return supplierListWithStock;
  }

  static List<Stock> getStockNameList(Map<String, dynamic> json) {
    List<Stock> stockNameList = [];
    for (Map<String,dynamic> stockData in json['data']) {
      Stock oneStockName = Stock.fromJson(stockData);
      stockNameList.add(oneStockName);
    }
    return stockNameList;
  }

  static List<String> getStockUnderSupplierList(Map<String, dynamic> json) {
    List<String> stockUnderSupplierList = [];
    for (Map<String,dynamic> stockData in json['data']) {
      String oneStockUnderSupplierName = Stock.fromJson(stockData).name;
      stockUnderSupplierList.add(oneStockUnderSupplierName);
    }
    return stockUnderSupplierList;
  }

  static Tuple2<List<String>, List<String>> getStockDataListWithSupplier(Map<String, dynamic> json) {
    List<String> stockNameList = [];
    List<String> stockNameListWithSupplier = [];
    List<Map<String, dynamic>> allStock = List<Map<String, dynamic>>.from(json['data']['all_stock']);
    List<Map<String, dynamic>> allStockWithCurrentSupplier = List<Map<String, dynamic>>.from(json['data']['all_stock_with_current_supplier']);
    for (Map<String,dynamic> stockData in allStock) {
      Stock oneStockName = Stock.fromJson(stockData);
      stockNameList.add(oneStockName.name);
    }
    for (Map<String,dynamic> stockDataWithSupplier in allStockWithCurrentSupplier) {
      Stock oneStockNameWithSupplier = Stock.fromJson(stockDataWithSupplier);
      stockNameListWithSupplier.add(oneStockNameWithSupplier.name);
    }
    if (kDebugMode) {
      print(stockNameList);
      print(stockNameListWithSupplier);
    }
    return Tuple2<List<String>, List<String>>(stockNameList, stockNameListWithSupplier);
    // return (stockNameList, stockNameListWithSupplier);
  }
}