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
      home: const ViewLeaveApplicationStatusPage(user: null,),
    );
  }
}

class ViewLeaveApplicationStatusPage extends StatefulWidget {
  const ViewLeaveApplicationStatusPage({super.key, this.user});

  final User? user;

  @override
  State<ViewLeaveApplicationStatusPage> createState() => _ViewLeaveApplicationStatusPageState();
}

class _ViewLeaveApplicationStatusPageState extends State<ViewLeaveApplicationStatusPage> {
  String title = '';
  String text = '';
  final _formKey = GlobalKey<FormState>();
  List<LeaveFormData> listLeaveFormData = [];

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
      appBar: AppsBarState().buildAppBar(context, 'LA Status', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: FutureBuilder<List<LeaveFormData>>(
                future: getLeaveFormData(),
                builder: (BuildContext context, AsyncSnapshot<List<LeaveFormData>> snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: buildLeaveFormDataRows(snapshot.data, currentUser),
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
    );
  }

  Widget buildButtonIsActive(LeaveFormData a, User currentUser) {
    return Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 23),
          child: Text.rich(
              TextSpan(
                  children: [
                    TextSpan(text: 'View',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.transparent,
                        shadows: [Shadow(color: Colors.blue, offset: Offset(0, -2))],
                        decorationThickness: 4,
                        decorationColor: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ApplyLeaveFormPage(leaveFormData: a, user: currentUser),
                            ),
                          );
                        },
                    ),
                  ]
              )
          )
      ),
    );
  }

  Widget buildButtonIsAprrove(LeaveFormData a, User currentUser) {
    return Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 23),
          child: Text.rich(
              TextSpan(
                  children: [
                    TextSpan(text: 'Approved',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.transparent,
                        shadows: [Shadow(color: Colors.green, offset: Offset(0, -2))],
                        decorationThickness: 4,
                        decorationColor: Colors.green,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ApplyLeaveFormPage(leaveFormData: a, user: currentUser),
                            ),
                          );
                        },
                    ),
                  ]
              )
          )
      ),
    );
  }

  Widget buildButtonIsReject(LeaveFormData a, User currentUser) {
    return Center(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 23),
          child: Text.rich(
              TextSpan(
                  children: [
                    TextSpan(text: 'Rejected',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: Colors.transparent,
                        shadows: [Shadow(color: Colors.red, offset: Offset(0, -2))],
                        decorationThickness: 4,
                        decorationColor: Colors.red,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ApplyLeaveFormPage(leaveFormData: a, user: currentUser),
                            ),
                          );
                        },
                    ),
                  ]
              )
          )
      ),
    );
  }

  List<Widget> buildLeaveFormDataRows(List<LeaveFormData>? listLeaveFormData, User? currentUser) {
    List<Widget> rows = [];
    rows.add(
        Table(
        border: TableBorder.symmetric(
          // outside:
          // const BorderSide(color: Colors.black, width: 10.0)
        ),
        children: const [
          //This table row is for the table header which is static
          TableRow(
              decoration: BoxDecoration(color: Colors.black45),
              children: [

                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Date From",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Date To",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Leave Type",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Details",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ),
              ]
          ),
        ],
      ),
    );

    for (LeaveFormData a in listLeaveFormData!) {
      rows.add(
        Table(
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Colors.black26),
              children: [

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      a.date_from.toString().substring(0,10),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      a.date_to.toString().substring(0,10),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      a.leave_type,
                    ),
                  ),
                ),
                buildButtonApplicationStatus(a, currentUser!),
              ],
            ),
          ],
        ),
      );
    }
    return rows;
  }

  Widget buildButtonApplicationStatus(LeaveFormData a, User currentUser) {
    if (a.is_reject) {
      return buildButtonIsReject(a, currentUser);
    } else if (a.is_approve) {
      return buildButtonIsAprrove(a, currentUser);
    } else if (a.is_active) {
      return buildButtonIsActive(a, currentUser);
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<List<LeaveFormData>> getLeaveFormData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/leave/request_application_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return LeaveFormData.getLeaveFormDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load leave form data');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }
  }
}