import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Announcement {
  final int id;
  final String title;
  final String description;
  final DateTime date_created;
  final String user_created_name;
  final String user_updated_name;

  const Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.date_created,
    required this.user_created_name,
    required this.user_updated_name,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Announcement.fromJson: $json');
    }
    return Announcement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      user_created_name: json['user_created_name'] ?? "",
      user_updated_name: json['user_updated_name'] ?? "",
      date_created: DateTime.parse(json['date_created']),
    );
  }

  static List<Announcement> getAnnouncementList(Map<String, dynamic> json) {
    List<Announcement> announcementList = [];
    for (Map<String,dynamic> announcement in json['data']) {
      Announcement oneAnnouncement = Announcement.fromJson(announcement);
      announcementList.add(oneAnnouncement);
    }
    return announcementList;
  }
}