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
      home: const ViewAttendanceStatusPage(user: null,),
    );
  }
}

class ViewAttendanceStatusPage extends StatefulWidget {
  const ViewAttendanceStatusPage({super.key, this.user});

  final User? user;

  @override
  State<ViewAttendanceStatusPage> createState() => _ViewAttendanceStatusPageState();
}

class _ViewAttendanceStatusPageState extends State<ViewAttendanceStatusPage> {
  String title = '';
  String text = '';
  final _formKey = GlobalKey<FormState>();
  List<Attendance> listAttendanceData = [];

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
      drawer: AppsBarState().buildDrawer(context),
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
                buildAttendanceStatus(a, currentUser!),
              ],
            ),
          ],
        ),
      );
    }
    return rows;
  }

  Widget buildAttendanceStatus(Attendance a, User currentUser) {
    if (a.is_reject) {
      return buildStatusIsReject(a, currentUser);
    } else if (a.is_approve) {
      return buildStatusIsAprrove(a, currentUser);
    } else if (a.is_active) {
      return buildStatusIsActive(a, currentUser);
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<List<Attendance>> getAttendanceData(User currentUser) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/attendance/request_list/${currentUser.uid}'),
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