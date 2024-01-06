import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/StaffManagement/staffList.dart';
import 'package:http/http.dart' as http;

import '../Announcement/createAnnouncement.dart';
import '../Attendance/downloadAttendanceRecord.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/User.dart';
import '../Order/manageOrder.dart';
import '../Utils/error_codes.dart';

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
      home: const StaffDashboardPage(user: null, streamControllers: null),
    );
  }
}

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboardPage> {
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();

    if (widget.user?.staff_type != "Restaurant Owner") {
      // Web Socket
      widget.streamControllers!['order']?.stream.listen((message) {
        final snackBar = SnackBar(
            content: const Text('Received new order!'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ManageOrderPage(user: getUser(),
                            streamControllers: widget.streamControllers),
                  ),
                );
              },
            )
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      });

      widget.streamControllers!['announcement']?.stream.listen((message) {
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
                          CreateAnnouncementPage(user: getUser(),
                              streamControllers: widget.streamControllers),
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

      widget.streamControllers!['attendance']?.stream.listen((message) {
        SnackBar(
            content: const Text('Received new attendance request!'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        ManageAttendanceRequestPage(user: getUser(),
                            streamControllers: widget.streamControllers),
                  ),
                );
              },
            )
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
              content: const Text('Are you sure to exit the apps?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Yes'),

                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('No'),
                ),
              ],
            );
          },
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers!),
        appBar: AppsBarState().buildAppBar(context, 'Staff Dashboard', currentUser, widget.streamControllers!),
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
                                    MaterialPageRoute(builder: (context) => StaffListPage(user: currentUser, streamControllers: widget.streamControllers)));
                              },
                              child: Column(
                                children: [
                                  Image.asset('images/staffManagement.png',),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    child: Text('Management', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 210,
                      // height: 300,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20,),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => ManageAttendanceRequestPage(user: currentUser, streamControllers: widget.streamControllers)));
                              },
                              child: Column(
                                children: [
                                  Image.asset('images/viewApplication.png'),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    child: Text('Attendance', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 210.0,
                      // height: 300,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20,),
                            child: ElevatedButton(
                              onPressed: () {
                                // downloadAttendanceRecordInExcelFile();
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => DownloadAttendanceRecordPage(user: currentUser, streamControllers: widget.streamControllers)));
                              },
                              child: Column(
                                children: [
                                  Image.asset('images/excelFile.png',),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    child: Text('Download Attendance Record', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
              ),
            )
          ),
        ),
      ),
    );
  }

  // Future<(dynamic, String)> downloadAttendanceRecord() async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://10.0.2.2:8000/attendance/download_all_staff_attendance_by_month'),
  //
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(<String, dynamic> {
  //         'month': 12,
  //         'year': 2023,
  //       }),
  //     );
  //     print('hi');
  //     final responseData = json.decode(response.body);
  //     print(responseData['data']);
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       return (responseData['data'], (ErrorCodes.OPERATION_OK));
  //     } else {
  //       return ("", (ErrorCodes.DOWNLOAD_ATTENDANCE_RECORD_FAIL_BACKEND));
  //     }
  //   } on Exception catch (e) {
  //     return ("", (ErrorCodes.DOWNLOAD_ATTENDANCE_RECORD_FAIL_API_CONNECTION));
  //   }
  // }
}