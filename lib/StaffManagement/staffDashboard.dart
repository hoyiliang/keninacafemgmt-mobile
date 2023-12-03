import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/StaffManagement/staffList.dart';

import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/User.dart';
import '../Order/manageOrder.dart';
import '../Utils/WebSocketManager.dart';

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
      home: const StaffDashboardPage(user: null, webSocketManagers: null),
    );
  }
}

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key, this.user, this.webSocketManagers});

  final User? user;
  final Map<String,WebSocketManager>? webSocketManagers;

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboardPage> {
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  void disconnectWS() {
    for (String key in widget.webSocketManagers!.keys) {
      widget.webSocketManagers![key]?.disconnectFromWebSocket();
    }
  }

  @override
  void initState() {
    super.initState();

    // Web Socket
    for (String key in widget.webSocketManagers!.keys) {
      widget.webSocketManagers![key]?.connectToWebSocket();
    }
    widget.webSocketManagers!['order']?.listenToWebSocket((message) {
      final snackBar = SnackBar(
          content: const Text('Received new order!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              disconnectWS();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ManageOrderPage(user: getUser(), webSocketManagers: widget.webSocketManagers),
                ),
              );
            },
          )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    widget.webSocketManagers!['announcement']?.listenToWebSocket((message) {
      final snackBar = SnackBar(
          content: const Text('Received new announcement!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              disconnectWS();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateAnnouncementPage(user: getUser(), webSocketManagers: widget.webSocketManagers),
                ),
              );
            },
          )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    widget.webSocketManagers!['attendance']?.listenToWebSocket((message) {
      SnackBar(
        content: const Text('Received new attendance request!'),
        // action: SnackBarAction(
        //   label: 'View',
        //   onPressed: () {
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) => (user: getUser(), webSocketManagers: widget.webSocketManagers),
        //       ),
        //     );
        //   },
        // )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.webSocketManagers!),
      appBar: AppsBarState().buildAppBar(context, 'Staff Dashboard', currentUser, widget.webSocketManagers!),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20,),
          child: Align(
            alignment: Alignment.center,
            child: Column(
                children: [
                  SizedBox(
                    width: 210.0,
                    // height: 300,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20,),
                          child: ElevatedButton(
                            onPressed: () {
                              disconnectWS();
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => StaffListPage(user: currentUser, webSocketManagers: widget.webSocketManagers)));
                            },
                            child: Column(
                              children: [
                                Image.asset('images/staffManagement.png',),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  child: Text('Management', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 210,
                    // height: 300,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20,),
                          child: ElevatedButton(
                            onPressed: () {
                              disconnectWS();
                              Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => ManageAttendanceRequestPage(user: currentUser, webSocketManagers: widget.webSocketManagers)));
                            },
                            child: Column(
                              children: [
                                Image.asset('images/viewApplication.png'),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  child: Text('Attendance', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
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
          )
        ),
      ),
    );
  }
}