import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import 'package:keninacafe/Attendance/viewAttendanceStatus.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Announcement/createAnnouncement.dart';
import '../Entity/User.dart';
import '../Entity/Attendance.dart';
import '../Order/manageOrder.dart';
import 'manageAttendanceRequest.dart';

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
      home: const TakeAttendancePage(user: null, streamControllers: null),
    );
  }
}

class TakeAttendancePage extends StatefulWidget {
  const TakeAttendancePage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<TakeAttendancePage> createState() => _TakeAttendanceState();
}

class _TakeAttendanceState extends State<TakeAttendancePage> {
  bool attendanceCreated = false;
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

    // Web Socket
    widget.streamControllers!['order']?.stream.listen((message) {
      final snackBar = SnackBar(
          content: const Text('Received new order!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ManageOrderPage(user: getUser(), streamControllers: widget.streamControllers),
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
                  builder: (context) => ManageAttendanceRequestPage(user: getUser(), streamControllers: widget.streamControllers),
                ),
              );
            },
          )
      );
    });
  }

  void showConfirmationClockInOutDialog(DateTime dateAttendanceTaken, User currentUser, bool isClockIn, bool isClockOut) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(DateTime.now().toUtc().toLocal().toString().substring(0,10), style: const TextStyle(fontWeight: FontWeight.bold,)),
          content: isClockIn == true ? const Text('Confirm to clock in?') : const Text('Confirm to clock out?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (attendanceCreatedAsync, err_code) = await _submitAttendanceDetails(dateAttendanceTaken, currentUser, isClockIn, isClockOut);
                setState(() {
                  attendanceCreated = attendanceCreatedAsync;
                  if (!attendanceCreated) {
                    if (err_code == ErrorCodes.CREATE_ATTENDANCE_DATA_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error'),
                            content: isClockIn == true ? Text(
                              'An Error occurred while trying to clock in.\n\nError Code: $err_code')
                            : Text(
                              'An Error occurred while trying to clock out.\n\nError Code: $err_code'),
                            actions: <Widget>[
                              TextButton(onPressed: () =>
                                  Navigator.pop(context, 'Ok'),
                                  child: const Text('Ok')),
                            ],
                          ),
                      );
                    } else {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Connection Error'),
                            content: Text(
                                'Unable to establish connection to our services. Please make sure you have an internet connection.\n\nError Code: $err_code'),
                            actions: <Widget>[
                              TextButton(onPressed: () =>
                                  Navigator.pop(context, 'Ok'),
                                  child: const Text('Ok')),
                            ],
                          ),
                      );
                    }
                  } else {
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: isClockIn == true ? const Text('Clock In Successful') : const Text('Clock Out Successful'),
                          content: const Text(
                              'Status can be viewed in the Attendance status page.'),
                          actions: <Widget>[
                            TextButton(onPressed: () =>
                                Navigator.pop(context, 'Ok'),
                                child: const Text('Ok')),
                          ],
                        ),
                    );
                  }
                });
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
  }

  void showHaveNotClockInDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clock Out Failed', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('You have not clock in yet.'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Ok',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    DateTime now = DateTime.now();
    int dayOfWeek = now.weekday;
    String dayName = _getDayName(dayOfWeek);
    String formattedDate = "${now.year}/${now.month}/${now.day}";
    String formattedDateBeforeTenth = "${now.year}/${now.month}/0${now.day}";

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers),
      appBar: AppsBarState().buildAppBarDetails(context, 'Take Attendance', currentUser, widget.streamControllers!),
      body: SafeArea(
        child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20,),
            child: Align(
              alignment: Alignment.center,
              child: Column(
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Colors.grey.shade900,
                        fontFamily: 'Gabarito',
                      ),
                    ),
                    const SizedBox(height: 5.0,),
                    if (now.day >= 10)
                      Text(
                        "( $formattedDate )",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.grey.shade800,
                          // fontFamily: 'Itim',
                        ),
                      )
                    else
                      Text(
                        "( $formattedDateBeforeTenth )",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.grey.shade800,
                          // fontFamily: 'Itim',
                        ),
                      ),
                    const SizedBox(height: 20.0,),
                    FutureBuilder<bool>(
                      future: getAttendanceClockIn(currentUser, DateFormat('yyyy-MM-dd').format(now)),
                      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                        if (snapshot.hasData) {
                          return buildClockInButton (snapshot.data, currentUser);
                        } else {
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            return Center(
                              child: LoadingAnimationWidget.threeRotatingDots(
                                color: Colors.black,
                                size: 50,
                              ),
                            );
                          }
                        }
                      }
                    ),
                    const SizedBox(height: 20.0,),
                    FutureBuilder<bool>(
                        future: getAttendanceClockOut(currentUser, DateFormat('yyyy-MM-dd').format(now)),
                        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                          if (snapshot.hasData) {
                            return buildClockOutButton (snapshot.data, currentUser);
                          } else {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              return Center(
                                child: LoadingAnimationWidget.threeRotatingDots(
                                  color: Colors.black,
                                  size: 50,
                                ),
                              );
                            }
                          }
                        }
                    ),
                  ]
              ),
            )
        ),
      ),
    );
  }

  Widget buildClockInButton (bool? haveClockIn, User currentUser) {
    bool isClockIn = true;
    bool isClockOut = false;
    return Container(
      width: 200.0,
      height: 116.0,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: haveClockIn == false ? Colors.greenAccent.shade400 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
      ),
      child: MaterialButton(
          height:116,
          onPressed: haveClockIn == false ? () {
            showConfirmationClockInOutDialog(DateTime.now(), currentUser, isClockIn, isClockOut);
          } : null,
          child: const Column(
            children: [
              SizedBox(height: 10.0,),
              Icon(
                Icons.access_time,
                color: Colors.white,
                size: 55,
              ),
              SizedBox(height: 5.0,),
              Text(
                "Clock In",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.0,),
            ],
          )
      ),
    );
  }

  Widget buildClockOutButton (bool? haveClockOut, User currentUser) {
    bool isClockIn = false;
    bool isClockOut = true;
    return Container(
      width: 200.0,
      height: 116.0,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: haveClockOut == false ? Colors.orange.shade500 : Colors.grey.shade400,
        borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
      ),
      child: MaterialButton(
          height:116,
          onPressed: haveClockOut == false ? () async {
            bool cnClockOut = await getAttendanceClockIn(currentUser, DateFormat('yyyy-MM-dd').format(DateTime.now()));
            if (!cnClockOut) {
              showHaveNotClockInDialog();
            } else {
              showConfirmationClockInOutDialog(DateTime.now(), currentUser, isClockIn, isClockOut);
            }
          } : null,
          child: const Column(
            children: [
              SizedBox(height: 10.0,),
              Icon(
                Icons.free_breakfast_outlined,
                color: Colors.white,
                size: 55,
              ),
              SizedBox(height: 5.0,),
              Text(
                "Clock Out",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.0,),
            ],
          )
      ),
    );
  }

  Future<(bool, String)> _submitAttendanceDetails(DateTime nowDateTime, User currentUser, bool isClockIn, bool isClockOut) async {
    String dateAttendanceTaken = nowDateTime.toString();
    int userCreatedId = currentUser.uid;

    if (kDebugMode) {
      print('dateAttendanceTaken: $dateAttendanceTaken');
      print('user_created_id: $userCreatedId');
    }

    var (success, err_code) = await createAttendanceData(dateAttendanceTaken, userCreatedId, isClockIn, isClockOut);
    return (success, err_code);
  }

  Future<(bool, String)> createAttendanceData(String dateAttendanceTaken, int userCreatedId, bool isClockIn, bool isClockOut) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/attendance_data'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'dateAttendanceTaken': dateAttendanceTaken,
          'user_created_id': userCreatedId,
          'is_clock_in': isClockIn,
          'is_clock_out': isClockOut,
        }),
      );


      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Create Attendance Data Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print('Failed to Create Attendance Data.');
        }
        return (false, ErrorCodes.CREATE_ATTENDANCE_DATA_FAIL_BACKEND);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, ErrorCodes.CREATE_ATTENDANCE_DATA_FAIL_API_CONNECTION);
    }
  }

  Future<bool> getAttendanceClockIn(User currentUser, String now) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/request_one_attendance_for_checking_button/${currentUser.uid}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'is_clock_in': true,
          'is_clock_out': false,
          'dateTaken': now,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Attendance.getAttendanceDateList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load clock in attendance date');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }
  }

  Future<bool> getAttendanceClockOut(User currentUser, String now) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/request_one_attendance_for_checking_button/${currentUser.uid}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'is_clock_in': false,
          'is_clock_out': true,
          'dateTaken': now,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Attendance.getAttendanceDateList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load clock out attendance date');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }
  }

}