import 'package:flutter/foundation.dart';

class AnnouncementStatus extends ChangeNotifier {
  Set<int> _readAnnouncements = {};

  Set<int> get readAnnouncements => _readAnnouncements;

  void markAsRead(int announcementId) {
    _readAnnouncements.add(announcementId);
    notifyListeners();
  }

  bool isRead(int announcementId) {
    return _readAnnouncements.contains(announcementId);
  }
}