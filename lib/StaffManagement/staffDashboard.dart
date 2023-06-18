import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/LeaveApplication/applyLeaveForm.dart';
import 'package:keninacafe/LeaveApplication/viewLeaveApplicationStatus.dart';
import 'package:keninacafe/StaffManagement/staffList.dart';

import '../Attendance/manageAttendanceRequest.dart';
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
      home: const StaffDashboardPage(user: null,),
    );
  }
}

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key, this.user});

  final User? user;

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboardPage> {

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
      appBar: AppsBarState().buildAppBar(context, 'Staff Dashboard', currentUser!),
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
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => StaffListPage(user: currentUser)));
                          },
                          child: Column(
                            children: [
                              Image.asset('images/staffManagement.png',),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Text('Staff Management', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
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
                                MaterialPageRoute(builder: (context) => ManageAttendanceRequestPage(user: currentUser)));
                          },
                          child: Column(
                            children: [
                              Image.asset('images/viewApplication.png'),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                child: Text('Attendance Request', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
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
}