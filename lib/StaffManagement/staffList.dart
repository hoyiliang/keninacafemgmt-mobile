import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/LeaveApplication/applyLeaveForm.dart';
import 'package:keninacafe/StaffManagement/deleteStaff.dart';
import 'package:keninacafe/Attendance/manageRestaurantWorkerAttendance.dart';
import 'package:keninacafe/StaffManagement/staffDashboard.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import '../Entity/User.dart';
import '../Entity/LeaveFormData.dart';
import 'createStaff.dart';

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
      home: const StaffListPage(user: null,),
    );
  }
}

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key, this.user});

  final User? user;

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
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
      appBar: AppsBarState().buildAppBar(context, 'Staff List', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                const SizedBox(height: 15,),

                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: FutureBuilder<List<User>>(
                        future: getStaffList(),
                        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: buildStaffCards(snapshot.data, currentUser),
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
                // SizedBox(
                //   height: 100,
                //   width: 50,
                //   child: Stack(
                //     children: [
                //       Positioned(
                //         bottom: 16.0,
                //         left: 16.0,
                //         child: FloatingActionButton(
                //           onPressed: () {
                //             // Add your button's action here
                //           },
                //           child: Icon(Icons.add),
                //         ),
                //       ),
                //     ],
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => CreateStaffPage(user: currentUser))
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }

  List<Widget> buildStaffCards(List<User>? listStaff, User? currentUser) {
    List<Widget> cards = [];
    for (User a in listStaff!) {
      if (a.uid != currentUser?.uid && a.is_active == true) {
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
                    child: Container(
                      color: Colors.grey[350],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 8.0),
                            child: Text(
                              a.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(builder: (context) => ManageRestaurantWorkerAttendancePage(user: currentUser, staff_data: a,))
                              );
                            },
                          ),
                        ],
                      ),
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
                                'Staff Type: ${a.staff_type}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(-1, -1),
                              child: Text(
                                'Email: ${a.email}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(-1, -1),
                              child: Text(
                                'Phone Number: ${a.phone}',
                                textAlign: TextAlign.left,
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
                                                    // context) => ManageRestaurantWorkerAttendancePage(staff_data: a, user: currentUser),
                                                    context) => DeleteStaffPage(staff_data: a, user: currentUser),
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

  Future<List<User>> getStaffList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/users/request_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.getStaffDataList(jwtToken));
      } else {
        if (kDebugMode) {
          print(response.body);
          print('User exist in system.');
        }
        return ([
          User(uid: -1,
              image: '',
              is_staff: false,
              is_active: false,
              staff_type: '',
              name: '',
              ic: '',
              address: '',
              email: '',
              gender: '',
              dob: DateTime.now(),
              phone: '',
              points: 0)
        ]);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return ([
        User(uid: -1,
            image: '',
            is_staff: false,
            is_active: false,
            staff_type: '',
            name: '',
            ic: '',
            address: '',
            email: '',
            gender: '',
            dob: DateTime.now(),
            phone: '',
            points: 0)
      ]);
    }
  }

  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       return User.getStaffDataList(jsonDecode(response.body));
  //     } else {
  //       throw Exception('Failed to load staff data list');
  //     }
  //   } on Exception catch (e) {
  //     throw Exception('Failed to connect API $e');
  //   }
  // }
}