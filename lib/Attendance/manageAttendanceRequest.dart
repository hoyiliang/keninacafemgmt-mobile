import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../Announcement/createAnnouncement.dart';
import '../Entity/User.dart';
import '../Entity/Attendance.dart';
import '../Order/manageOrder.dart';
import '../StaffManagement/staffDashboard.dart';

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
      home: const ManageAttendanceRequestPage(user: null, streamControllers: null),
    );
  }
}

class ManageAttendanceRequestPage extends StatefulWidget {
  const ManageAttendanceRequestPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<ManageAttendanceRequestPage> createState() => _ManageAttendanceRequestPageState();
}

class _ManageAttendanceRequestPageState extends State<ManageAttendanceRequestPage> {
  String title = '';
  String text = '';
  bool attendanceRequestUpdated = false;
  bool isHomePage = false;
  bool statusChanged = false;
  DateTime? selectedDateForRequest;
  DateTime? selectedDateForOverview;

  Future<void> _selectDateForRequest(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateForRequest ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDateForRequest) {
      setState(() {
        selectedDateForRequest = picked;
      });
    }
  }

  Future<void> _selectDateForOverview(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateForOverview ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDateForOverview) {
      setState(() {
        selectedDateForOverview = picked;
      });
    }
  }

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
    selectedDateForRequest = DateTime.now();
    selectedDateForOverview = DateTime.now();

    widget.streamControllers!['attendance']?.stream.listen((message) {
      setState(() {
        // do nothing
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return WillPopScope(
      onWillPop: () async {
        // Navigate to the desired page when the Android back button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StaffDashboardPage(user: currentUser, streamControllers: widget.streamControllers)),
        );

        // Prevent the default back button behavior
        return false;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(125),
            child: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_outlined),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => StaffDashboardPage(user: currentUser, streamControllers: widget.streamControllers))
                  );
                },
              ),
              bottom: PreferredSize(
                preferredSize: const Size(0,00),
                child: SizedBox(
                  height: 50.0,
                  child: Material(
                    color: Colors.deepPurple[100],
                    child: TabBar(
                      tabs: const [
                        Text(
                          'Request',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                          ),
                        ),
                        Text(
                          'Overview',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17.0,
                          ),
                        ),
                      ],
                      indicator: BoxDecoration(
                          color: Colors.deepPurple[300]
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      overlayColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.grey.shade200;
                          }
                          return null;
                        },
                      ),
                      unselectedLabelColor: Colors.grey.shade600,
                      labelColor: Colors.white,
                    ),
                  ),
                ),
              ),

              elevation: 0,
              toolbarHeight: 100,
              title: const Text("Attendance",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: IconButton(
                    onPressed: () {
                      // disconnectWS();
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser, streamControllers: widget.streamControllers))
                      );
                    },
                    icon: const Icon(Icons.notifications, size: 35,),
                  ),
                ),
              ],
            ),
          ),
          //drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers),
          body: SafeArea(
            child: TabBarView(
              children: [
                Column(
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
                            onTap: () => _selectDateForRequest(context),
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
                                  selectedDateForRequest != null
                                      ? Text(
                                    '${selectedDateForRequest!.day}/${selectedDateForRequest!.month}/${selectedDateForRequest!.year}',
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

                    if (selectedDateForRequest != null)
                      Expanded(
                        child: SingleChildScrollView (
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 13.0),
                              child: FutureBuilder<List<Attendance>>(
                                  future: getAttendanceRequestList(selectedDateForRequest!),
                                  builder: (BuildContext context, AsyncSnapshot<List<Attendance>> snapshot) {
                                    if (snapshot.hasData) {
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          child: Column(
                                            children: buildAttendanceRequestList(snapshot.data, currentUser),
                                          )
                                      );
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
                              )
                          ),
                        ),
                      ),
                    const SizedBox(height: 20.0,),
                  ],
                ),
                Column(
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
                            onTap: () => _selectDateForOverview(context),
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
                                  selectedDateForOverview != null
                                      ? Text(
                                    '${selectedDateForOverview!.day}/${selectedDateForOverview!.month}/${selectedDateForOverview!.year}',
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

                    if (selectedDateForOverview != null)
                      Expanded(
                        child: SingleChildScrollView (
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 13.0),
                              child: FutureBuilder<List<User>>(
                                  future: getUserAttendanceExistList(selectedDateForOverview!),
                                  builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                                    if (snapshot.hasData) {
                                      return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          child: Column(
                                              children: [
                                                FutureBuilder<List<Widget>> (
                                                    future: buildAttendanceStaffCards(snapshot.data, currentUser),
                                                    builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Column(
                                                            children: snapshot.data!
                                                        );
                                                      }
                                                      return SizedBox();
                                                    }
                                                )
                                              ]
                                          )
                                      );
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
                              )
                          ),
                        ),
                      ),
                    const SizedBox(height: 20.0,),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers),
    //   appBar: AppsBarState().buildAppBar(context, 'Attendance Status', currentUser, widget.streamControllers),
    //   body: SafeArea(
    //     child: SingleChildScrollView(
    //       child: SizedBox(
    //           child: FutureBuilder<List<Attendance>>(
    //               future: getAttendanceData(currentUser),
    //               builder: (BuildContext context, AsyncSnapshot<List<Attendance>> snapshot) {
    //                 if (snapshot.hasData) {
    //                   return Padding(
    //                       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
    //                       child: Column(
    //                         children: buildAttendanceDataRows(snapshot.data, currentUser),
    //                       )
    //                   );
    //
    //                 } else {
    //                   if (snapshot.hasError) {
    //                     return Center(child: Text('Error: ${snapshot.error}'));
    //                   } else {
    //                     return const Center(child: Text('Error: invalid state'));
    //                   }
    //                 }
    //               }
    //           )
    //       ),
    //     ),
    //   ),
    //   bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context, widget.streamControllers),
    // );
  }

  List<Widget> buildAttendanceRequestList(List<Attendance>? attendanceRequestList, User? currentUser) {
    List<Widget> cards = [];
    if (attendanceRequestList!.isEmpty) {
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
                  "No Pending Attendance",
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
        const SizedBox(height: 5.0,),
      );
      for (int i = 0; i < attendanceRequestList.length; i++) {
        if (i == attendanceRequestList.length - 1 || attendanceRequestList[i].user_created_name != attendanceRequestList[i + 1].user_created_name) {
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
                                Text(
                                  attendanceRequestList[i].user_created_name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                    fontFamily: 'Gabarito',
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.greenAccent.shade400),
                                    // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                    onPressed: () async {
                                      showConfirmationUpdateDialog(currentUser!, selectedDateForRequest!, attendanceRequestList[i].user_created_id, "Approve");
                                    },
                                    child: const Icon(Icons.check, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 20.0),
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.red),
                                    onPressed: () async {
                                      showConfirmationUpdateDialog(currentUser!, selectedDateForRequest!, attendanceRequestList[i].user_created_id, "Reject");
                                    },
                                    child: const Icon(Icons.close, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 15.0,),
                              ],
                            ),
                            const SizedBox(height: 5.0,),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    if (attendanceRequestList[i].is_clock_in && !attendanceRequestList[i].is_clock_out)
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
                                      "${attendanceRequestList[i].dateAttendanceTaken.hour.toString().padLeft(2, '0')} : ${attendanceRequestList[i].dateAttendanceTaken.minute.toString().padLeft(2, '0')} : ${attendanceRequestList[i].dateAttendanceTaken.second.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.grey.shade900,
                                        fontFamily: "BreeSerif",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0,),
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
            const SizedBox(height: 10,),
          );
        } else if (attendanceRequestList[i].user_created_name == attendanceRequestList[i].user_created_name) {
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
                                Text(
                                  attendanceRequestList[i].user_created_name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                    fontFamily: 'Gabarito',
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.greenAccent.shade400),
                                    // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                    onPressed: () async {
                                      showConfirmationUpdateDialog(currentUser!, selectedDateForRequest!, attendanceRequestList[i].user_created_id, "Approve");
                                    },
                                    child: const Icon(Icons.check, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 20.0),
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100)),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.red),
                                    onPressed: () async {
                                      showConfirmationUpdateDialog(currentUser!, selectedDateForRequest!, attendanceRequestList[i].user_created_id, "Reject");
                                    },
                                    child: const Icon(Icons.close, color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 15.0,),
                              ],
                            ),
                            const SizedBox(height: 5.0,),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    if (attendanceRequestList[i].is_clock_in && !attendanceRequestList[i].is_clock_out)
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
                                      "${attendanceRequestList[i].dateAttendanceTaken.hour.toString().padLeft(2, '0')} : ${attendanceRequestList[i].dateAttendanceTaken.minute.toString().padLeft(2, '0')} : ${attendanceRequestList[i].dateAttendanceTaken.second.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.grey.shade900,
                                        fontFamily: "BreeSerif",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5.0,),
                                Row(
                                  children: [
                                    if (attendanceRequestList[i + 1].is_clock_in && !attendanceRequestList[i + 1].is_clock_out)
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
                                      "${attendanceRequestList[i + 1].dateAttendanceTaken.hour.toString().padLeft(2, '0')} : ${attendanceRequestList[i + 1].dateAttendanceTaken.minute.toString().padLeft(2, '0')} : ${attendanceRequestList[i + 1].dateAttendanceTaken.second.toString().padLeft(2, '0')}",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.grey.shade900,
                                        fontFamily: "BreeSerif",
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 10.0,),
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
            const SizedBox(height: 10,),
          );
          i = i + 1;
        }
      }
    }
    return cards;
  }

  Future<List<Widget>> buildAttendanceStaffCards(List<User>? attendanceStaffList, User? currentUser) async {
    List<Widget> cards = [];
    for (int i = 0; i < attendanceStaffList!.length; i++) {
      cards.add(
        Card(
          color: Colors.white,
          elevation: 20.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15.0), // Adjust the radius as needed
            // side: BorderSide(color: Colors.deepOrangeAccent.shade200, width: 1.0), // Border color and width
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 4.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: attendanceStaffList[i]!.image == "" ? Image.asset(
                          "images/KE_Nina_Cafe_logo.jpg",
                          width: 80,
                          height: 80,
                        ) : Image.memory(base64Decode(attendanceStaffList[i]!.image), fit: BoxFit.contain, width: 80, height: 80,),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10.0),
                        Row(
                            children: [
                              Text(
                                attendanceStaffList[i] !.name,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.grey.shade900,
                                  fontFamily: "Itim",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]
                        ),
                        const SizedBox(height: 10.0,),
                        FutureBuilder<List<Attendance>>(
                            future: getAttendanceOverviewList(selectedDateForOverview!, attendanceStaffList[i].uid),
                            builder: (BuildContext context, AsyncSnapshot<List<Attendance>> snapshot) {
                              if (snapshot.hasData) {
                                return buildAttendanceStatusButton(snapshot.data, selectedDateForOverview!, attendanceStaffList[i].uid, attendanceStaffList[i].name, currentUser!);
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
                        )
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
      cards.add(const SizedBox(height: 15,),);
    }
    cards.add(const SizedBox(height: 20,));
    return cards;
  }

  Widget buildAttendanceStatusButton(List<Attendance>? attendanceTakenList, DateTime selectedDate, int user_created_id, String user_created_name, User currentUser) {
    bool isApprove = false;
    bool isReject = false;
    bool isPending = false;
    if (attendanceTakenList!.isEmpty) {
      isReject = true;
    } else {
      if (attendanceTakenList[0].is_approve == true && attendanceTakenList[0].is_reject == false && attendanceTakenList[0].is_active == false) {
        isApprove = true;
      } else if (attendanceTakenList[0].is_approve == false && attendanceTakenList[0].is_reject == true && attendanceTakenList[0].is_active == false) {
        isReject = true;
      } else if (attendanceTakenList[0].is_approve == false && attendanceTakenList[0].is_reject == false && attendanceTakenList[0].is_active == true) {
        isPending = true;
      }
    }
    return Row(
      children: [
        Container(
          width: 72.0,
          height: 40.0,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: isApprove ? Colors.greenAccent.shade400 : Colors.grey.shade600,
            borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
          ),
          child: MaterialButton(
            // minWidth: double.infinity,
            height:40,
            onPressed: isApprove == false ? () {
              showConfirmationUpdateStatusDialog(selectedDate, user_created_id, user_created_name, "Approve", currentUser);
            } : null,
            child: const Text(
              "Present",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7.0,),
        Container(
          width: 72.0,
          height: 40.0,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: isReject ? Colors.red : Colors.grey.shade600,
            borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
          ),
          child: MaterialButton(
            // minWidth: double.infinity,
            height:40,
            onPressed: isReject == false ? () {
              showConfirmationUpdateStatusDialog(selectedDate, user_created_id, user_created_name, "Reject", currentUser);
            } : null,
            child: const Text(
              "Absent",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 7.0,),
        Container(
          width: 72.0,
          height: 40.0,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: isPending ? Colors.orange.shade500 : Colors.grey.shade600,
            borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
          ),
          child: MaterialButton(
            // minWidth: double.infinity,
            height:40,
            onPressed: isPending == false && true ? () {
              // showConfirmationUpdateStatusDialog(selectedDate, user_created_id, user_created_name, "Pending", currentUser);
            } : null,
            child: const Text(
              "Pending",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10.5,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showConfirmationUpdateDialog(User currentUser, DateTime selectedDate, int user_created_id, String action) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: action == "Approve" ? const Text('Confirm to approve this attendance request?') : const Text('Confirm to reject this attendance request?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (attendanceRequestUpdatedAsync, err_code) = (false, ErrorCodes.UPDATE_ATTENDANCE_REQUEST_FAIL_BACKEND);
                if (action == 'Approve') {
                  (attendanceRequestUpdatedAsync, err_code) = await approveAttendance(formattedDate, user_created_id, currentUser);
                } else {
                  (attendanceRequestUpdatedAsync, err_code) = await rejectAttendance(formattedDate, user_created_id, currentUser);
                }
                setState(() {
                  Navigator.of(context).pop();
                  attendanceRequestUpdated = attendanceRequestUpdatedAsync;
                  if (!attendanceRequestUpdated) {
                    if (err_code == ErrorCodes.UPDATE_ATTENDANCE_REQUEST_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: action == "Approve" ? Text('An Error occurred while trying to approve this attendance request.\n\nError Code: $err_code') : Text('An Error occurred while trying to reject this attendance request.\n\nError Code: $err_code'),
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
                            title: const Text('Connection Error', style: TextStyle(fontWeight: FontWeight.bold,)),
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
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: action == "Approve" ? const Text('Approved Successfully', style: TextStyle(fontWeight: FontWeight.bold,)) : const Text('Rejected Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: const Text('Attendance status is updated and can be check in the attendance overview.'),
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
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'No',
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

  void showConfirmationUpdateStatusDialog(DateTime selectedDate, int user_created_id, String user_created_name, String action, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to change the attendance status of this user (${user_created_name})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (statusChangedAsync, err_code) = await changeAttendanceStatus(selectedDate, user_created_id, action, currentUser);
                setState(() {
                  Navigator.of(context).pop();
                  statusChanged = statusChangedAsync;
                  if (!statusChanged) {
                    if (err_code == ErrorCodes.CHANGE_ATTENDANCE_REQUEST_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: Text('An Error occurred while trying to change the attendance status of this user ($user_created_name).\n\nError Code: $err_code'),
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
                            title: const Text('Connection Error', style: TextStyle(fontWeight: FontWeight.bold,)),
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
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Changed Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: Text('The attendance status of this user ($user_created_name) has changed.'),
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
                    setState(() {
                    });
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'No',
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

  Future<(bool, String)> changeAttendanceStatus(DateTime selectedDate, int user_created_id, String action, User currentUser) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    bool is_approve = false;
    bool is_reject = false;
    bool is_pending = false;
    if (action == "Approve") {
      is_approve = true;
      is_reject = false;
      is_pending = false;
    } else if (action == "Reject") {
      is_approve = false;
      is_reject = true;
      is_pending = false;
    } else if (action == "Pending") {
      is_approve = false;
      is_reject = false;
      is_pending = true;
    }
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/change_attendance_status'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'is_active': is_pending,
          'is_approve': is_approve,
          'is_reject': is_reject,
          'date_selected': formattedDate,
          'user_created_id': user_created_id,
          'current_user_uid': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Reject Attendance Request Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print('Failed to Reject The Attendance Request.');
        }
        return (false, ErrorCodes.CHANGE_ATTENDANCE_REQUEST_FAIL_BACKEND);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, ErrorCodes.CHANGE_ATTENDANCE_REQUEST_FAIL_API_CONNECTION);
    }
  }

  Future<(bool, String)> approveAttendance(String formattedDate, int user_created_id, User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/update_attendance'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'is_active': false,
          'is_approve': true,
          'is_reject': false,
          'date_selected': formattedDate,
          'user_created_id': user_created_id,
          'current_user_uid': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Approve Attendance Request Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print('Failed to Approve The Attendance Request .');
        }
        return (false, ErrorCodes.UPDATE_ATTENDANCE_REQUEST_FAIL_BACKEND);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, ErrorCodes.UPDATE_ATTENDANCE_REQUEST_FAIL_API_CONNECTION);
    }
  }

  Future<(bool, String)> rejectAttendance(String formattedDate, int user_created_id, User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/update_attendance'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'is_active': false,
          'is_approve': false,
          'is_reject': true,
          'date_selected': formattedDate,
          'user_created_id': user_created_id,
          'current_user_uid': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Reject Attendance Request Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print('Failed to Reject The Attendance Request.');
        }
        return (false, ErrorCodes.UPDATE_ATTENDANCE_REQUEST_FAIL_BACKEND);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, ErrorCodes.UPDATE_ATTENDANCE_REQUEST_FAIL_API_CONNECTION);
    }
  }

  Future<List<Attendance>> getAttendanceRequestList(DateTime selectedDate) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/request_all_attendance_request_list_by_date'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'date_selected': formattedDate,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Attendance.getAttendanceDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load attendance request data list');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }
  }

  Future<List<Attendance>> getAttendanceOverviewList(DateTime selectedDate, int user_created_id) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/request_all_attendance_overview_list_by_date'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'date_selected': formattedDate,
          'user_created_id': user_created_id,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Attendance.getAttendanceDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load attendance request data list');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }
  }

  Future<List<User>> getUserAttendanceExistList(DateTime selectedDate) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/users/request_user_attendance_exist_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'date_selected': formattedDate,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.getStaffDataList(jwtToken));
      } else {
        if (kDebugMode) {
          // print(response.body);
          print('Staff exist in system.');
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
              points: 0,
              date_created: DateTime.now(),
              date_deactivated: DateTime.now()
          )
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
            points: 0,
            date_created: DateTime.now(),
            date_deactivated: DateTime.now()
        )
      ]);
    }
  }
}