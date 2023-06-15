import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class LeaveFormData {
  final int id;
  final String leave_type;
  final DateTime date_from ;
  final DateTime date_to;
  final double total_day;
  final String comments;
  final bool is_active;
  final bool is_approve;
  final bool is_reject;
  final String user_name;

  const LeaveFormData({
    required this.id,
    required this.leave_type,
    required this.date_from,
    required this.date_to,
    required this.total_day,
    required this.comments,
    required this.is_active,
    required this.is_approve,
    required this.is_reject,
    required this.user_name,
  });

  factory LeaveFormData.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('LeaveFormData.fromJson: $json');
    }
    return LeaveFormData(
      id: json['id'],
      leave_type: json['leave_type_name'],
      date_from: DateTime.parse(json['date_from']),
      date_to: DateTime.parse(json['date_to']),
      total_day: json['total_day'],
      comments: json['comments'],
      is_active: json['is_active'],
      is_approve: json['is_approve'],
      is_reject: json['is_reject'],
      user_name: json['user_name'],
    );
  }

  static List<LeaveFormData> getLeaveFormDataList(Map<String, dynamic> json) {
    List<LeaveFormData> leaveFormDataList = [];
    for (Map<String,dynamic> leaveFormData in json['data']) {
      LeaveFormData oneLeaveFormData = LeaveFormData.fromJson(leaveFormData);
      leaveFormDataList.add(oneLeaveFormData);
    }
    return leaveFormDataList;
  }
}