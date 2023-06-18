import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/LeaveApplication/applyLeaveForm.dart';
import 'package:keninacafe/LeaveApplication/viewLeaveApplicationStatus.dart';
import 'package:keninacafe/StaffManagement/staffList.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import 'package:keninacafe/Attendance/viewAttendanceStatus.dart';

import '../Entity/User.dart';
import '../Entity/Attendance.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AttendanceDashboardPage(user: null,),
    );
  }
}

class AttendanceDashboardPage extends StatefulWidget {
  const AttendanceDashboardPage({super.key, this.user});

  final User? user;

  @override
  State<AttendanceDashboardPage> createState() => _AttendanceDashboardState();
}

class _AttendanceDashboardState extends State<AttendanceDashboardPage> {
  bool attendanceCreated = false;
  bool dateNotExist = true;

  User? getUser() {
    return widget.user;
  }

  void showConfirmationDialog(DateTime dateAttendanceTaken, User currentUser) {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<bool>(
            future: getAttendance(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData) {
                dateNotExist = snapshot.data!;
                if (dateNotExist) {
                  return AlertDialog(
                    title: Text(DateTime.now().toUtc().toLocal().toString().substring(0,10), style: const TextStyle(fontWeight: FontWeight.bold,)),
                    content: const Text('Confirm to take the attendance on this day?'),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          // Perform save logic here
                          // Navigator.of(context).pop();
                          // Navigator.of(context).pop();
                          // if (_formKey.currentState!.validate()) {
                          var (attendanceCreatedAsync, err_code) = await _submitAttendanceDetails(dateAttendanceTaken, currentUser!);
                          setState(() {
                            attendanceCreated = attendanceCreatedAsync;
                            if (!attendanceCreated) {
                              if (err_code == ErrorCodes.ANNOUNCEMENT_CREATE_FAIL_BACKEND) {
                                showDialog(context: context, builder: (
                                    BuildContext context) =>
                                    AlertDialog(
                                      title: const Text('Error'),
                                      content: Text(
                                          'An Error occurred while trying to submit the attendance.\n\nError Code: $err_code'),
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
                                    title: const Text('Submit The Attendance Successful'),
                                    content: const Text(
                                        'The attendance taken can be viewed in the Announcement status page.'),
                                    actions: <Widget>[
                                      TextButton(onPressed: () =>
                                          Navigator.pop(context, 'Ok'),
                                          child: const Text('Ok')),
                                    ],
                                  ),
                              );
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         const HomePage(),
                              //   ),
                              // );
                            }
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const HomePage(),
                            //   ),
                            // );
                            // }
                          });
                        },
                        // saveAnnouncement(title, text);
                        // },
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
                }
                else {
                  return AlertDialog(
                    title: const Text('Today attendance has been taken', style: TextStyle(fontWeight: FontWeight.bold,)),
                    // content: const Text('Confirm to take the attendance on this day?'),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Yes'),

                      ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     Navigator.of(context).pop();
                      //   },
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.red,
                      //   ),
                      //   child: const Text('No'),
                      // ),
                    ],
                  );
                }
                // return AlertDialog(
                //   title: Text(DateTime.now().toString().substring(0,10), style: const TextStyle(fontWeight: FontWeight.bold,)),
                //   content: const Text('Confirm to take the attendance on this day?'),
                //   actions: [
                //     ElevatedButton(
                //       onPressed: () async {
                //         // Perform save logic here
                //         // Navigator.of(context).pop();
                //         // Navigator.of(context).pop();
                //         // if (_formKey.currentState!.validate()) {
                //         var (attendanceCreatedAsync, err_code) = await _submitAttendanceDetails(dateAttendanceTaken, currentUser!);
                //         setState(() {
                //           attendanceCreated = attendanceCreatedAsync;
                //           if (!attendanceCreated) {
                //             if (err_code == ErrorCodes.ANNOUNCEMENT_CREATE_FAIL_BACKEND) {
                //               showDialog(context: context, builder: (
                //                   BuildContext context) =>
                //                   AlertDialog(
                //                     title: const Text('Error'),
                //                     content: Text(
                //                         'An Error occurred while trying to submit the attendance.\n\nError Code: $err_code'),
                //                     actions: <Widget>[
                //                       TextButton(onPressed: () =>
                //                           Navigator.pop(context, 'Ok'),
                //                           child: const Text('Ok')),
                //                     ],
                //                   ),
                //               );
                //             } else {
                //               showDialog(context: context, builder: (
                //                   BuildContext context) =>
                //                   AlertDialog(
                //                     title: const Text('Connection Error'),
                //                     content: Text(
                //                         'Unable to establish connection to our services. Please make sure you have an internet connection.\n\nError Code: $err_code'),
                //                     actions: <Widget>[
                //                       TextButton(onPressed: () =>
                //                           Navigator.pop(context, 'Ok'),
                //                           child: const Text('Ok')),
                //                     ],
                //                   ),
                //               );
                //             }
                //           } else {
                //             Navigator.of(context).pop();
                //             showDialog(context: context, builder: (
                //                 BuildContext context) =>
                //                 AlertDialog(
                //                   title: const Text('Submit The Attendance Successful'),
                //                   content: const Text(
                //                       'The attendance taken can be viewed in the Announcement status page.'),
                //                   actions: <Widget>[
                //                     TextButton(onPressed: () =>
                //                         Navigator.pop(context, 'Ok'),
                //                         child: const Text('Ok')),
                //                   ],
                //                 ),
                //             );
                //             // Navigator.push(
                //             //   context,
                //             //   MaterialPageRoute(
                //             //     builder: (context) =>
                //             //         const HomePage(),
                //             //   ),
                //             // );
                //           }
                //           // Navigator.push(
                //           //   context,
                //           //   MaterialPageRoute(
                //           //     builder: (context) =>
                //           //         const HomePage(),
                //           //   ),
                //           // );
                //           // }
                //         });
                //       },
                //       // saveAnnouncement(title, text);
                //       // },
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.green,
                //       ),
                //       child: const Text('Yes'),
                //
                //     ),
                //     ElevatedButton(
                //       onPressed: () {
                //         Navigator.of(context).pop();
                //       },
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.red,
                //       ),
                //       child: const Text('No'),
                //     ),
                //   ],
                // );
                // );
              } else {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return const Center(child: Text('Error: invalid state'));
                }
              }
            }
        );
        // return AlertDialog(
        //   title: Text(DateTime.now().toString().substring(0,10), style: const TextStyle(fontWeight: FontWeight.bold,)),
        //   content: const Text('Confirm to take the attendance on this day?'),
        //   actions: [
        //     ElevatedButton(
        //       onPressed: () async {
        //         // Perform save logic here
        //         // Navigator.of(context).pop();
        //         // Navigator.of(context).pop();
        //         // if (_formKey.currentState!.validate()) {
        //           var (attendanceCreatedAsync, err_code) = await _submitAttendanceDetails(dateAttendanceTaken, currentUser!);
        //           setState(() {
        //             attendanceCreated = attendanceCreatedAsync;
        //             if (!attendanceCreated) {
        //               if (err_code == ErrorCodes.ANNOUNCEMENT_CREATE_FAIL_BACKEND) {
        //                 showDialog(context: context, builder: (
        //                     BuildContext context) =>
        //                     AlertDialog(
        //                       title: const Text('Error'),
        //                       content: Text(
        //                           'An Error occurred while trying to submit the attendance.\n\nError Code: $err_code'),
        //                       actions: <Widget>[
        //                         TextButton(onPressed: () =>
        //                             Navigator.pop(context, 'Ok'),
        //                             child: const Text('Ok')),
        //                       ],
        //                     ),
        //                 );
        //               } else {
        //                 showDialog(context: context, builder: (
        //                     BuildContext context) =>
        //                     AlertDialog(
        //                       title: const Text('Connection Error'),
        //                       content: Text(
        //                           'Unable to establish connection to our services. Please make sure you have an internet connection.\n\nError Code: $err_code'),
        //                       actions: <Widget>[
        //                         TextButton(onPressed: () =>
        //                             Navigator.pop(context, 'Ok'),
        //                             child: const Text('Ok')),
        //                       ],
        //                     ),
        //                 );
        //               }
        //             } else {
        //               Navigator.of(context).pop();
        //               showDialog(context: context, builder: (
        //                   BuildContext context) =>
        //                   AlertDialog(
        //                     title: const Text('Submit The Attendance Successful'),
        //                     content: const Text(
        //                         'The attendance taken can be viewed in the Announcement status page.'),
        //                     actions: <Widget>[
        //                       TextButton(onPressed: () =>
        //                           Navigator.pop(context, 'Ok'),
        //                           child: const Text('Ok')),
        //                     ],
        //                   ),
        //               );
        //               // Navigator.push(
        //               //   context,
        //               //   MaterialPageRoute(
        //               //     builder: (context) =>
        //               //         const HomePage(),
        //               //   ),
        //               // );
        //             }
        //             // Navigator.push(
        //             //   context,
        //             //   MaterialPageRoute(
        //             //     builder: (context) =>
        //             //         const HomePage(),
        //             //   ),
        //             // );
        //             // }
        //           });
        //         },
        //         // saveAnnouncement(title, text);
        //       // },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.green,
        //       ),
        //       child: const Text('Yes'),
        //
        //     ),
        //     ElevatedButton(
        //       onPressed: () {
        //         Navigator.of(context).pop();
        //       },
        //       style: ElevatedButton.styleFrom(
        //         backgroundColor: Colors.red,
        //       ),
        //       child: const Text('No'),
        //     ),
        //   ],
        // );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    print(currentUser?.name);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildAppBar(context, 'Attendance', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20,),
          child: Row(
              children: [
                SizedBox(
                  width: 196.5,
                  // height: 300,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20,),
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.of(context).push(
                            //     MaterialPageRoute(builder: (context) => StaffListPage(user: currentUser)));
                            showConfirmationDialog(DateTime.now(), currentUser);
                          },
                          child: Column(
                            children: [
                              Image.asset('images/status.png',),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Text('Submit Attendance', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
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
                                MaterialPageRoute(builder: (context) => ViewAttendanceStatusPage(user: currentUser)));
                          },
                          child: Column(
                            children: [
                              Image.asset('images/attendance.png'),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Text('Attendance Status', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
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
        ),
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }

  Future<(bool, String)> _submitAttendanceDetails(DateTime nowDateTime, User currentUser) async {
    String dateAttendanceTaken = nowDateTime.toString();
    int user_created_id = currentUser.uid;

    if (kDebugMode) {
      print('dateAttendanceTaken: $dateAttendanceTaken');
      print('user_created_id: $user_created_id');
    }

    var (success, err_code) = await createAttendanceData(dateAttendanceTaken, user_created_id);
    return (success, err_code);
  }

  Future<(bool, String)> createAttendanceData(String dateAttendanceTaken, int user_created_id) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/attendance_data'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'dateAttendanceTaken': dateAttendanceTaken,
          'user_created_id': user_created_id,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Create Attendance Data Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print('Failed to Create Attendance Data Announcement.');
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

  Future<bool> getAttendance() async {
    // String title = titleController.text;
    // String description = descriptionController.text;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/attendance/request_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {

        return Attendance.getAttendanceDateList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load attendance date');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }

    // if (kDebugMode) {
    //   print('title: $title');
    //   print('description: $description');
    // }
    //
    // var (success, err_code) = await createAnnouncement(title, description, currentUser);
    // return (success, err_code);
  }

}