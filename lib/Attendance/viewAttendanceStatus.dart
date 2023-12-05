import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
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
      home: const ViewAttendanceStatusPage(user: null, streamControllers: null),
    );
  }
}

class ViewAttendanceStatusPage extends StatefulWidget {
  const ViewAttendanceStatusPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<ViewAttendanceStatusPage> createState() => _ViewAttendanceStatusPageState();
}

class _ViewAttendanceStatusPageState extends State<ViewAttendanceStatusPage> {
  List<Attendance> listAttendanceData = [];
  bool isHomePage = false;
  DateTime? selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers),
      appBar: AppsBarState().buildAppBarDetails(context, 'Status', currentUser, widget.streamControllers),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(13.0),
                      child: Text(
                        'Select Date: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 25.0,
                          fontFamily: 'Gabarito',
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      width: 200.0,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8.0),
                          selectedDate != null
                              ? Text(
                            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ) : const Text(
                            '',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (selectedDate != null)
              Expanded(
                child: SingleChildScrollView (
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 0),
                      child: FutureBuilder<List<Attendance>>(
                          future: getAttendanceWithStatusList(DateFormat('yyyy-MM-dd').format(selectedDate!), currentUser),
                          builder: (BuildContext context, AsyncSnapshot<List<Attendance>> snapshot) {
                            if (snapshot.hasData) {
                              return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                  child: Column(
                                    children: buildAttendanceWithStatusList(snapshot.data, currentUser)
                                  )
                              );

                            } else {
                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else {
                                return const Center(child: Text('Loading...'));
                              }
                            }
                          }
                      )
                  ),
                ),
              ),
          ],
        ),
        // child: SingleChildScrollView(
        //   child: SizedBox(
        //       child: FutureBuilder<List<Attendance>>(
        //           future: getAttendanceData(currentUser),
        //           builder: (BuildContext context, AsyncSnapshot<List<Attendance>> snapshot) {
        //             if (snapshot.hasData) {
        //               return Padding(
        //                 padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        //                 child: Column(
        //                   children: buildAttendanceDataRows(snapshot.data, currentUser),
        //                 )
        //               );
        //
        //             } else {
        //               if (snapshot.hasError) {
        //                 return Center(child: Text('Error: ${snapshot.error}'));
        //               } else {
        //                 return const Center(child: Text('Error: invalid state'));
        //               }
        //             }
        //           }
        //       )
        //   ),
        // ),
      ),
    );
  }

  Widget buildStatusIsActive() {
    return SizedBox(
      height: 20,
      width: 70,
      child: Material(
          elevation: 3.0, // Add elevation to simulate a border
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.grey.shade600, // Border color
              width: 2.0, // Border width
            ),
            borderRadius: BorderRadius.circular(200), // Apply border radius if needed
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "Pending",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 9.0,
                color: Colors.grey.shade700,
              ),
            ),
          )
      ),
    );
  }

  Widget buildStatusIsApprove() {
    return SizedBox(
      height: 20,
      width: 70,
      child: Material(
          elevation: 3.0, // Add elevation to simulate a border
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.green.shade400, // Border color
              width: 2.0, // Border width
            ),
            borderRadius: BorderRadius.circular(200), // Apply border radius if needed
          ),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "Approved",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 9.0,
                color: Colors.green.shade500,
              ),
            ),
          )
      ),
    );
  }

  Widget buildStatusIsReject() {
    return SizedBox(
      height: 20,
      width: 70,
      child: Material(
          elevation: 3.0, // Add elevation to simulate a border
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Colors.red, // Border color
              width: 2.0, // Border width
            ),
            borderRadius: BorderRadius.circular(200), // Apply border radius if needed
          ),
          child: const Align(
            alignment: Alignment.center,
            child: Text(
              "Rejected",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 9.0,
                color: Colors.red,
              ),
            ),
          )
      ),
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

  List<Widget> buildAttendanceWithStatusList(List<Attendance>? listAttendanceData, User? currentUser) {
    List<Widget> cards = [];
    if (listAttendanceData!.isEmpty) {
      cards.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 50, 0, 20),
              child: Image.asset(
                "images/emptyAttendance.png",
                width: 250,
                height: 250,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Text(
                  "No Attendance Record",
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      cards.add(
        const SizedBox(height: 10.0,),
      );
      cards.add(
        Card(
          child: Container(
            constraints: const BoxConstraints(
              maxHeight: double.infinity,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey, width: 4.0),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _getDayName(listAttendanceData[0].dateAttendanceTaken.weekday),
                                style: TextStyle(
                                  fontSize: 22.0,
                                  color: Colors.grey.shade900,
                                  fontFamily: "YoungSerif",
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            ),
                            const Spacer(),
                            buildAttendanceStatus(listAttendanceData[0]),
                            const SizedBox(width: 2.0,),
                          ],
                        ),
                        const SizedBox(height: 5.0,),
                        Row(
                          children: [
                            if (listAttendanceData[0].is_clock_in && !listAttendanceData[0].is_clock_out)
                              Text(
                                "Time Clock In : ",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            else
                              Text(
                                "Time Clock Out : ",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Text(
                              "${listAttendanceData[0].dateAttendanceTaken.hour.toString().padLeft(2, '0')} : ${listAttendanceData[0].dateAttendanceTaken.minute.toString().padLeft(2, '0')} : ${listAttendanceData[0].dateAttendanceTaken.second.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.grey.shade800,
                                fontFamily: "BreeSerif",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2.0,),
                        if (listAttendanceData.length == 2)
                          Row(
                            children: [
                              if (listAttendanceData[1].is_clock_in && !listAttendanceData[1].is_clock_out)
                                Text(
                                  "Time Clock In : ",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.grey.shade700,
                                    fontFamily: "Oswald",
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                Text(
                                  "Time Clock Out : ",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.grey.shade700,
                                    fontFamily: "Oswald",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Text(
                                "${listAttendanceData[1].dateAttendanceTaken.hour.toString().padLeft(2, '0')} : ${listAttendanceData[1].dateAttendanceTaken.minute.toString().padLeft(2, '0')} : ${listAttendanceData[1].dateAttendanceTaken.second.toString().padLeft(2, '0')}",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.grey.shade800,
                                  fontFamily: "BreeSerif",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 2.0,),
                        if (listAttendanceData[0].user_updated_name != "")
                          Row(
                            children: [
                              Text(
                                "Updated By : ",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                listAttendanceData[0].user_updated_name,
                                style: TextStyle(
                                  fontSize: 19.0,
                                  color: Colors.grey.shade800,
                                  fontFamily: "BreeSerif",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 5.0,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      cards.add(
        const SizedBox(height: 20,),
      );
    }
    return cards;
  }

  Widget buildAttendanceStatus(Attendance a) {
    print(a.is_active);
    print(a.is_reject);
    print(a.is_approve);
    if (a.is_reject) {
      return buildStatusIsReject();
    } else if (a.is_approve) {
      return buildStatusIsApprove();
    } else if (a.is_active) {
      return buildStatusIsActive();
    } else {
      return const SizedBox.shrink();
    }
  }

  Future<List<Attendance>> getAttendanceWithStatusList(String selectedDate, User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/request_attendance_with_status_list_by_date/${currentUser.uid}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'date_selected': selectedDate,
        }),
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