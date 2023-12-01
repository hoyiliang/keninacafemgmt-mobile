import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class StockReceipt {
  final int id;
  final String receipt_number;
  final double price;
  final String user_created_name;
  final String user_updated_name;
  final String pdf_file_name;
  final DateTime date_receipt;
  List stock_name;
  final String supplier_name;

  StockReceipt({
    required this.id,
    required this.receipt_number,
    required this.price,
    required this.user_created_name,
    required this.user_updated_name,
    required this.pdf_file_name,
    required this.date_receipt,
    required this.stock_name,
    required this.supplier_name,
  });

  factory StockReceipt.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('StockReceipt.fromJson: $json');
    // }

    List<String> stockNameList = [];
    if (json['stock_name'] is List) {
      stockNameList = List<String>.from(json['stock_name']);
    } else {
      stockNameList = [json['stock_name'].toString()];
    }

    return StockReceipt(
      id: json['id'],
      receipt_number: json['receipt_number'],
      price: json['price'],
      user_created_name: json['user_created_name'],
      user_updated_name: json['user_updated_name'] ?? "",
      pdf_file_name: json['pdf_file_name'],
      date_receipt: DateTime.parse(json['date_receipt']),
      stock_name: stockNameList,
      supplier_name: json['supplier_name'] ?? "",
    );
  }

  static List<StockReceipt> getStockReceiptList(Map<String, dynamic> json) {
    List<StockReceipt> stockReceiptList = [];
    List<Map<String, dynamic>> stockReceiptDataList =  List<Map<String, dynamic>>.from(json['data']);
    for (int i = 0; i < stockReceiptDataList.length; i++) {
      Map<String, dynamic> currentStockReceiptData = stockReceiptDataList[i];
      StockReceipt currentStockReceipt = StockReceipt.fromJson(currentStockReceiptData);
      if (i == stockReceiptDataList.length - 1) {
        stockReceiptList.add(currentStockReceipt);
        break;
      } else {
        for (int j = i; j < stockReceiptDataList.length - 1; j++) {
          Map<String, dynamic> nextStockReceiptData = stockReceiptDataList[j+1];
          StockReceipt nextStockReceipt = StockReceipt.fromJson(nextStockReceiptData);
          if (currentStockReceipt.receipt_number == nextStockReceipt.receipt_number) {
            currentStockReceipt.stock_name.add(StockReceipt.fromJson(nextStockReceiptData).stock_name[0]);
            if ((j + 1)== stockReceiptDataList.length - 1) {
              stockReceiptList.add(currentStockReceipt);
              i = j + 1;
              break;
            }
          } else {
            stockReceiptList.add(currentStockReceipt);
            i = j;
            break;
          }
        }
      }
    }
    return stockReceiptList;
  }
}