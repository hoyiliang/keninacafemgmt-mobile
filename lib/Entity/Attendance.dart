import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Attendance {
  final int id;
  final DateTime dateAttendanceTaken;
  final bool is_active;
  final bool is_approve;
  final bool is_reject;
  final int user_created_id;
  final String user_created_name;
  final String user_updated_name;
  final String user_created_image;
  final bool is_clock_in;
  final bool is_clock_out;

  const Attendance({
    required this.id,
    required this.dateAttendanceTaken,
    required this.is_active,
    required this.is_approve,
    required this.is_reject,
    required this.user_created_id,
    required this.user_created_name,
    required this.user_updated_name,
    required this.user_created_image,
    required this.is_clock_in,
    required this.is_clock_out,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('Attendance.fromJson: $json');
    // }
    return Attendance(
      id: json['id'],
      dateAttendanceTaken: DateTime.parse(json['dateAttendanceTaken']),
      is_active: json['is_active'],
      is_approve: json['is_approve'],
      is_reject: json['is_reject'],
      user_created_id: json['user_created_id'],
      user_created_name: json['user_created_name'],
      user_updated_name: json['user_updated_name'] ?? "",
      user_created_image: json['user_created_image'] ?? "",
      is_clock_in: json['is_clock_in'],
      is_clock_out: json['is_clock_out'],
    );
  }

  static bool getAttendanceDateList(Map<String, dynamic> json) {
    for (Map<String,dynamic> attendanceDate in json['data']) {
      Attendance oneAttendanceDate = Attendance.fromJson(attendanceDate);
      return true;
    }
    return false;
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
