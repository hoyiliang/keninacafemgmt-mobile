import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class Transaction {
  final int id;
  final DateTime date;
  final int num_transaction;
  final double total_revenue;
  final double total_spend_stock_receipt;

  Transaction({
    required this.id,
    required this.date,
    required this.num_transaction,
    required this.total_revenue,
    required this.total_spend_stock_receipt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      date: DateTime.parse(json['date']),
      num_transaction: json['num_transaction'],
      total_revenue: json['total_revenue'],
      total_spend_stock_receipt: json['total_spend_stock_receipt'],
    );
  }

  static List<Transaction> getOneTransaction(Map<String, dynamic> json) {
    List<Transaction> transactionDataList = [];
    for (Map<String,dynamic> transactionData in json['data']) {
      Transaction oneTransactionData = Transaction.fromJson(transactionData);
      transactionDataList.add(oneTransactionData);
    }
    return transactionDataList;
  }

}