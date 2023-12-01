import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class StaffType {
  final String name;

  const StaffType({
    required this.name,
  });

  factory StaffType.fromJson(Map<String, dynamic> json) {
    return StaffType(
      name: json['name'],
    );
  }

  static List<StaffType> getStaffTypeList(Map<String, dynamic> json) {
    List<StaffType> staffTypeList = [];
    for (Map<String,dynamic> staffType in json['data']) {
      StaffType oneStaffType = StaffType.fromJson(staffType);
      staffTypeList.add(oneStaffType);
    }
    return staffTypeList;
  }
}