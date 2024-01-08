import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/User.dart';
import '../Order/manageOrder.dart';
import 'WebSocketSingleton.dart';

class WebSocketSingleton {

  static WebSocketSingleton? _uniqueInstance;
  static Map<String, StreamController> _streamControllers = {};
  static bool _listenedFlag = false;

  factory WebSocketSingleton(Map<String, StreamController> streamControllers) {
    if (_uniqueInstance == null) {
      _uniqueInstance = WebSocketSingleton._internal(streamControllers);
    }
    return _uniqueInstance!;
  }

  WebSocketSingleton._internal(Map<String, StreamController> streamControllers) {
    _streamControllers = streamControllers;
  }

  void listen(BuildContext context, User user) {
    if (!_listenedFlag) {
      // Web Socket
      _streamControllers['order']?.stream.listen((message) {
        final data = jsonDecode(message);
        String content = data['message'];
        if (content == 'New Order') {
          final snackBar = SnackBar(
              content: const Text('Received new order!'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ManageOrderPage(user: user,
                              streamControllers: _streamControllers),
                    ),
                  );
                },
              )
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          print("Received delete/reject order!");
        }
      });

      _streamControllers['announcement']?.stream.listen((message) {
        final data = jsonDecode(message);
        String content = data['message'];
        if (content == 'New Announcement') {
          final snackBar = SnackBar(
              content: const Text('Received new announcement!'),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateAnnouncementPage(user: user,
                              streamControllers: _streamControllers),
                    ),
                  );
                },
              )
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else if (content == 'Delete Announcement') {
          print("Received delete announcement!");
        }
      });

      _streamControllers['attendance']?.stream.listen((message) {
        SnackBar(
            content: const Text('Received new attendance request!'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ManageAttendanceRequestPage(user: user, streamControllers: _streamControllers),
                  ),
                );
              },
            )
        );
      });
      _listenedFlag = true;
    }
  }
}