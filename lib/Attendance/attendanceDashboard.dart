import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/Attendance/takeAttendance.dart';
import 'package:keninacafe/Attendance/viewAttendanceStatus.dart';

import '../Entity/User.dart';

void main() {
  runApp(const MyApp());
}

void enterFullScreen() {
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AttendanceDashboardPage(user: null, streamControllers: null),
    );
  }
}

class AttendanceDashboardPage extends StatefulWidget {
  const AttendanceDashboardPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<AttendanceDashboardPage> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboardPage> {
  bool attendanceCreated = false;
  bool dateNotExist = true;
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers),
      appBar: AppsBarState().buildAppBar(context, 'Attendance', currentUser, widget.streamControllers),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20,),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(
                    width: 210.0,
                    // height: 300,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20,),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => TakeAttendancePage(user: currentUser, streamControllers: widget.streamControllers)));
                            },
                            child: Column(
                              children: [
                                Image.asset('images/status.png', width: 140, height: 150,),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(10, 4, 10, 13),
                                  child: Text('Clock In / Out', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 196,
                    // height: 300,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20,),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => ViewAttendanceStatusPage(user: currentUser, streamControllers: widget.streamControllers,)));
                            },
                            child: Column(
                              children: [
                                Image.asset('images/attendance.png'),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  child: Text('Attendance Status', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                                ),
                              ]
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ]
              ),
            )
        ),
      ),
    );
  }
}