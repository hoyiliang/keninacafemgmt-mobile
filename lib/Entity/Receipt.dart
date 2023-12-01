import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Receipt {
  final int id;
  final String receipt_number;
  final DateTime date_receipt;
  final double price;
  final String pdf_file_name;
  final String pdf_file;
  final String user_created_name;
  final String user_updated_name;


  const Receipt({
    required this.id,
    required this.receipt_number,
    required this.date_receipt,
    required this.price,
    required this.pdf_file_name,
    required this.pdf_file,
    required this.user_created_name,
    required this.user_updated_name,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      receipt_number: json['receipt_number'],
      date_receipt: DateTime.parse(json['date_receipt']),
      price: json['price'],
      pdf_file_name: json['pdf_file_name'],
      pdf_file: json['pdf_file'],
      user_created_name: json['user_created_name'],
      user_updated_name: json['user_updated_name'] ?? "",
    );
  }

  static String getPdfFile(Map<String, dynamic> json) {
    String pdfFile = "";
    for (Map<String,dynamic> receipt in json['data']) {
      pdfFile = Receipt.fromJson(receipt).pdf_file;
    }
    return pdfFile;
  }
}