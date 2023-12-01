import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class AnnouncementAssignUserMoreInfo {
  final int id;
  final int announcement_id;
  final String title;
  final String description;
  final DateTime date_created;
  final String user_created_name;
  final String user_updated_name;
  final bool is_read;

  const AnnouncementAssignUserMoreInfo({
    required this.id,
    required this.announcement_id,
    required this.title,
    required this.description,
    required this.date_created,
    required this.user_created_name,
    required this.user_updated_name,
    required this.is_read,
  });

  factory AnnouncementAssignUserMoreInfo.fromJson(Map<String, dynamic> json) {
    // if (kDebugMode) {
    //   print('AnnouncementAssignUserMoreInfo.fromJson: $json');
    // }
    return AnnouncementAssignUserMoreInfo(
      id: json['id'],
      announcement_id: json['announcement_id'] ?? 0,
      title: json['title'],
      description: json['description'],
      user_created_name: json['user_created_name'] ?? "",
      user_updated_name: json['user_updated_name'] ?? "",
      date_created: DateTime.parse(json['date_created']),
      is_read: json['is_read'],
    );
  }

  static List<AnnouncementAssignUserMoreInfo> getAnnouncementList(Map<String, dynamic> json) {
    List<AnnouncementAssignUserMoreInfo> announcementList = [];
    for (Map<String,dynamic> announcement in json['data']) {
      AnnouncementAssignUserMoreInfo oneAnnouncement = AnnouncementAssignUserMoreInfo.fromJson(announcement);
      announcementList.add(oneAnnouncement);
    }
    return announcementList;
  }
}