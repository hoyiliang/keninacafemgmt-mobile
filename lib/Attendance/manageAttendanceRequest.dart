import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/Entity/LeaveFormData.dart';
import 'package:keninacafe/LeaveApplication/applyViewLeaveApplication.dart';
import 'package:keninacafe/LeaveApplication/applyLeaveForm.dart';
import 'package:keninacafe/Utils/error_codes.dart';
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

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ManageAttendanceRequestPage(user: null,),
    );
  }
}

class ManageAttendanceRequestPage extends StatefulWidget {
  const ManageAttendanceRequestPage({super.key, this.user});

  final User? user;

  @override
  State<ManageAttendanceRequestPage> createState() => _ManageAttendanceRequestPageState();
}

class _ManageAttendanceRequestPageState extends State<ManageAttendanceRequestPage> {
  String title = '';
  String text = '';
  bool attendanceRequestUpdated = false;
  // final _formKey = GlobalKey<FormState>();
  // List<Attendance> listAttendanceData = [];

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    print(currentUser?.name);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildAppBar(context, 'Attendance Status', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
              child: FutureBuilder<List<Attendance>>(
                  future: getAttendanceData(currentUser),
                  builder: (BuildContext context, AsyncSnapshot<List<Attendance>> snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          child: Column(
                            children: buildAttendanceDataRows(snapshot.data, currentUser),
                          )
                      );

                    } else {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return const Center(child: Text('Error: invalid state'));
                      }
                    }
                  }
              )
          ),
        ),
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }

  Widget buildStatusIsActive(Attendance a, User currentUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          width: 100,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.blue[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: const Center(
            child: Text(
              'Pending',
              style: TextStyle(
                // fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
  //
  Widget buildStatusIsAprrove(Attendance a, User currentUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          width: 100,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.green[300],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: const Center(
            child: Text(
              'Approve',
              style: TextStyle(
                // fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStatusIsReject(Attendance a, User currentUser) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Container(
          width: 100,
          height: 25,
          decoration: BoxDecoration(
            color: Colors.red[400],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.black,
              width: 2,
            ),
          ),
          child: const Center(
            child: Text(
              'Reject',
              style: TextStyle(
                // fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildAttendanceDataRows(List<Attendance>? listAttendanceData, User? currentUser) {
    List<Widget> rows = [];
    rows.add(
      Table(
        border: TableBorder.symmetric(
            outside:
            BorderSide(color: Colors.grey[700]!, width: 1.5)
        ),
        children: [
          //This table row is for the table header which is static
          TableRow(
              decoration: BoxDecoration(color: Colors.grey[400]),
              children: const [

                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Date",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Staff",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Status",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
              ]
          ),
        ],
      ),
    );

    for (Attendance a in listAttendanceData!) {
      rows.add(
        Table(
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                        a.dateAttendanceTaken.toString().substring(0,10), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                        a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                    ),
                  ),
                ),

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.green,
                            // border: Border.all(
                            //   color: Colors.green,
                            //   width: 2.0,
                            // ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () {
                              showConfirmationUpdateDialog('Are you sure you want to approve the attendance?', 'An Error occurred while trying to approve the attendance.', 'Approve Attendance Successful', 'Can update the status to the Restaurant Staff', currentUser!, a, "Approve");
                              print('Correct button pressed');
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.check,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: InkWell(
                            onTap: () {
                              showConfirmationUpdateDialog('Are you sure you want to reject the attendance?', 'An Error occurred while trying to reject the attendance.', 'Reject Attendance Successful', 'Can update the status to the Restaurant Staff', currentUser!, a, "Reject");
                              print('Wrong button pressed');
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return rows;
  }

  void showConfirmationUpdateDialog(String question, String error, String information, String informationContent, User currentUser, Attendance attendanceData, String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text(question),
          // content: const Text('Are you sure you want to submit the leave form?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Perform save logic here
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                // if (_formKey.currentState!.validate()) {
                var (attendanceRequestUpdatedAsync, err_code) = (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_BACKEND);
                if (action == 'Approve') {
                  (attendanceRequestUpdatedAsync, err_code) = await approveAttendance(attendanceData, currentUser);
                } else {
                  (attendanceRequestUpdatedAsync, err_code) = await rejectAttendance(attendanceData, currentUser);
                }

                setState(() {
                  attendanceRequestUpdated = attendanceRequestUpdatedAsync;
                  if (!attendanceRequestUpdated) {
                    if (err_code == ErrorCodes.UPDATE_ATTENDANCE_REQUEST_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error'),
                            content: Text('$error\n\nError Code: $err_code'),
                            // content: Text('An Error occurred while trying to create a new leave form data.\n\nError Code: $err_code'),
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
                          title: Text(information),
                          content: Text(informationContent),
                          // title: const Text('Create New Leave Form Data Successful'),
                          // content: const Text('The Leave Form Data can be viewed in the LA status page.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                    );
                  }
                });
                // }
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

  Future<(bool, String)> approveAttendance(Attendance attendanceData, User currentUser) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/attendance/update_attendance/${attendanceData.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'is_active': !attendanceData.is_active,
          'is_approve': !attendanceData.is_approve,
          'is_reject': attendanceData.is_reject,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Approve Attendance Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print('Failed to Approve The Attendance.');
        }
        return (false, ErrorCodes.UPDATE_ATTENDANCE_REQUEST_FAIL_BACKEND);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, ErrorCodes.CUPDATE_ATTENDANCE_REQUEST_FAIL_API_CONNECTION);
    }
  }

  Future<(bool, String)> rejectAttendance(Attendance attendanceData, User currentUser) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/attendance/update_attendance/${attendanceData.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          // 'id': leaveFormData.id,
          'is_active': !attendanceData.is_active,
          'is_approve': attendanceData.is_approve,
          'is_reject': !attendanceData.is_reject,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Reject Attendance Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print('Failed to Reject The Attendance.');
        }
        return (false, ErrorCodes.UPDATE_ATTENDANCE_REQUEST_FAIL_BACKEND);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, ErrorCodes.CUPDATE_ATTENDANCE_REQUEST_FAIL_API_CONNECTION);
    }
  }

  Future<List<Attendance>> getAttendanceData(User currentUser) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/attendance/request_all_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Attendance.getAttendanceDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load attendance data');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }
  }
}