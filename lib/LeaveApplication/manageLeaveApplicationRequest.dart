import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/LeaveApplication/applyLeaveForm.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import '../Entity/User.dart';
import '../Entity/LeaveFormData.dart';

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
      home: const ManageLeaveApplicationRequestPage(user: null,),
    );
  }
}

class ManageLeaveApplicationRequestPage extends StatefulWidget {
  const ManageLeaveApplicationRequestPage({super.key, this.user});

  final User? user;

  @override
  State<ManageLeaveApplicationRequestPage> createState() => _ManageLeaveApplicationRequestPageState();
}

class _ManageLeaveApplicationRequestPageState extends State<ManageLeaveApplicationRequestPage> {
  String title = '';
  String text = '';
  final _formKey = GlobalKey<FormState>();

  User? getUser() {
    return widget.user;
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    print(currentUser?.name);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context),
      appBar: AppsBarState().buildAppBar(context, 'LA Request'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const SizedBox(height: 15,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: FutureBuilder<List<LeaveFormData>>(
                      future: getLeaveFormData(),
                      builder: (BuildContext context, AsyncSnapshot<List<LeaveFormData>> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: buildLeaveFormDataCards(snapshot.data, currentUser),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildLeaveFormDataCards(List<LeaveFormData>? listLeaveFormData, User? currentUser) {
    List<Widget> cards = [];
    for (LeaveFormData a in listLeaveFormData!) {
      if (a.is_active) {
        cards.add(
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 15,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  color: Colors.grey[350],
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 8.0),
                    child: Text(
                      a.leave_type,
                      style: const TextStyle(fontSize: 20,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey[100],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(),
                      child: Column(
                          children: [
                            Align(
                              alignment: const Alignment(-1, -1),
                              child: Text(
                                'Date From: ${a.date_from.toString().substring(
                                    0, 10)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(-1, -1),
                              child: Text(
                                'Date To: ${a.date_to.toString().substring(
                                    0, 10)}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(-1, -1),
                              child: Text(
                                'Applied by: ${a.user_name}',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(-1, -1),
                              child: Text(
                                'Total Day(s): ${a.total_day.toString()
                                    .substring(a.total_day
                                    .toString()
                                    .length - 3, a.total_day
                                    .toString()
                                    .length - 2)}', textAlign: TextAlign.left,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ]
                      ),
                    ),
                  ),
                ),
                Container(
                    color: Colors.grey[350],
                    child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Align(
                            alignment: Alignment.center,
                            child: Text.rich(
                                TextSpan(
                                    children: [
                                      TextSpan(text: 'Review',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          color: Colors.transparent,
                                          shadows: [
                                            Shadow(color: Colors.blue,
                                                offset: Offset(0, -2))
                                          ],
                                          decorationThickness: 4,
                                          decorationColor: Colors.blue,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                    context) => ApplyLeaveFormPage(leaveFormData: a, user: currentUser),
                                              ),
                                            );
                                          },
                                      ),
                                    ]
                                )
                            )
                        )
                    )
                ),
              ],
            ),
          ),
        );
        cards.add(const SizedBox(height: 15,),);
      }
    }
    return cards;
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