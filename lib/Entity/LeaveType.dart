import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class LeaveType {
  final String name;
  final bool require_attach_in_form;

  const LeaveType({
    required this.name,
    required this.require_attach_in_form,
  });

  factory LeaveType.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('LeaveType.fromJson: $json');
    }
    return LeaveType(
      name: json['name'],
      require_attach_in_form: json['require_attach_in_form'],
    );
  }

  static List<LeaveType> getLeaveTypeList(Map<String, dynamic> json) {
    List<LeaveType> leaveTypeList = [];
    for (Map<String,dynamic> leaveType in json['data']) {
      LeaveType oneLeaveType = LeaveType.fromJson(leaveType);
      leaveTypeList.add(oneLeaveType);
    }
    return leaveTypeList;
  }
}