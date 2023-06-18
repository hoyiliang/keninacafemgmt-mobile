import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Attendance {
  final int id;
  final DateTime dateAttendanceTaken;
  final bool is_active;
  final bool is_approve;
  final bool is_reject;
  final String name;

  const Attendance({
    required this.id,
    required this.dateAttendanceTaken,
    required this.is_active,
    required this.is_approve,
    required this.is_reject,
    required this.name,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Attendance.fromJson: $json');
    }
    return Attendance(
      id: json['id'],
      dateAttendanceTaken: DateTime.parse(json['dateAttendanceTaken']),
      is_active: json['is_active'],
      is_approve: json['is_approve'],
      is_reject: json['is_reject'],
      name: json['user_name'],
    );
  }

  static bool getAttendanceDateList(Map<String, dynamic> json) {
    for (Map<String,dynamic> attendanceDate in json['data']) {
      Attendance oneAttendanceDate = Attendance.fromJson(attendanceDate);
      if (oneAttendanceDate.dateAttendanceTaken.toString().substring(0,10) == DateTime.now().toString().substring(0,10)) {
        return false;
      }
    }
    return true;
  }

  static List<Attendance> getAttendanceDataList(Map<String, dynamic> json) {
    List<Attendance> attendanceDataList = [];
    for (Map<String,dynamic> attendanceData in json['data']) {
      Attendance oneAttendanceData = Attendance.fromJson(attendanceData);
      attendanceDataList.add(oneAttendanceData);
    }
    return attendanceDataList;
  }
}
