import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:keninacafe/AppsBar.dart';
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
      home: const ManageRestaurantWorkerAttendancePage(staff_data: null, user: null,),
    );
  }
}

class ManageRestaurantWorkerAttendancePage extends StatefulWidget {
  const ManageRestaurantWorkerAttendancePage({super.key, this.user, this.staff_data});

  final User? user;
  final User? staff_data;

  @override
  State<ManageRestaurantWorkerAttendancePage> createState() => _ManageRestaurantWorkerAttendancePageState();
}

class _ManageRestaurantWorkerAttendancePageState extends State<ManageRestaurantWorkerAttendancePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDate = DateTime.now();
  final Map<DateTime, List> _events = {};
  bool eventsGet = false;
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  User? getStaffData() {
    return widget.staff_data;
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    print(currentUser?.name);

    User? staff_data = getStaffData();
    print(staff_data?.name);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage),
      appBar: AppsBarState().buildAppBar(context, 'Manage Attendance', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
            child: SizedBox(
              child: FutureBuilder<List<Attendance>>(
                  future: getAttendanceData(staff_data),
                  builder: (BuildContext context, AsyncSnapshot<List<Attendance>> snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                          child: Column(
                            children: [
                              buildCalender(snapshot.data, currentUser),
                              ElevatedButton(
                                onPressed: () {
                                  // Open the pop-up modal for editing presence/absence
                                  _showEditModal(context, _selectedDate);
                                },
                                child: const Text('Edit'),
                              ),
                            ]
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
          // ElevatedButton(
          //   onPressed: () {
          //     // Open the pop-up modal for editing presence/absence
          //     _showEditModal(context, _selectedDate);
          //   },
          //   child: const Text('Edit'),
          // ),
          ),
        ),
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }

  // void syncEvents(List<Attendance>? listAttendanceData) async {
  //   for (Attendance a in listAttendanceData!) {
  //     if (a.is_approve) {
  //       _setPresence(a.dateAttendanceTaken);
  //     } else if (a.is_reject) {
  //       _setAbsence(a.dateAttendanceTaken);
  //     }
  //   }
  // }

  Widget buildCalender(List<Attendance>? listAttendanceData, User currentUser) {
    // _events[date] = [];
    if (kDebugMode) {
      print("buildCalendar events: $_events");
    }
    return TableCalendar(
      calendarFormat: _calendarFormat,
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      focusedDay: _selectedDate,
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2023, 12, 31),
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDate, day);
      },
      eventLoader: (day) {
        return _events[day] ?? [];
      },
      calendarStyle: CalendarStyle(
        markersMaxCount: 1,
        markerDecoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        markerSizeScale: 0.25,
        todayDecoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue, width: 2),
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDate = selectedDay;
        });
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          return Stack(
            children: [
              if (events.contains('presence'))
                Positioned(
                  top: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                  ),
                ),
              if (events.contains('absence'))
                Positioned(
                  top: 1,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showEditModal(BuildContext context, DateTime date) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Attendance'),
          content: Text('Choose presence or absence for ${date.day}/${date.month}/${date.year}'),
          actions: [
            TextButton(
              onPressed: () {
                // Set presence for the selected date
                _setPresence(date);
                Navigator.pop(context);
              },
              child: const Text('Presence'),
            ),
            TextButton(
              onPressed: () {
                // Set absence for the selected date
                _setAbsence(date);
                Navigator.pop(context);
              },
              child: const Text('Absence'),
            ),
          ],
        );
      },
    );
  }

  void _setPresence(DateTime date) {
      _events[date] = ['presence'];
  }

  void _setAbsence(DateTime date) {
      _events[date] = ['absence'];
  }

  Future<List<Attendance>> getAttendanceData(User? staff_data) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/attendance/request_all_list_per_staff/${staff_data?.uid}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        List<Attendance> listAttendanceData = Attendance.getAttendanceDataList(jsonDecode(response.body));
        for (Attendance a in listAttendanceData) {
          if (a.is_approve) {
            _setPresence(DateTime(a.dateAttendanceTaken.year, a.dateAttendanceTaken.month, a.dateAttendanceTaken.day).toUtc());
          } else if (a.is_reject) {
            _setAbsence(DateTime(a.dateAttendanceTaken.year, a.dateAttendanceTaken.month, a.dateAttendanceTaken.day).toUtc());
          }
        }
        return listAttendanceData;
      } else {
        throw Exception('Failed to load attendance data');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }
  }

}