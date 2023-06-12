import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class Announcement {
  final String title;
  final String description;
  final String name;

  const Announcement({
    required this.title,
    required this.description,
    required this.name,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    if (kDebugMode) {
      print('Announcement.fromJson: $json');
    }
    return Announcement(
      title: json['title'],
      description: json['description'],
      name: json['user_name'],
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