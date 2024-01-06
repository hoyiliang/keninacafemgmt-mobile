import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/SupplierManagement/stockReceiptList.dart';
import 'package:keninacafe/SupplierManagement/supplierListWithDelete.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/User.dart';
import '../Order/manageOrder.dart';

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
      home: const SupplierDashboardPage(user: null, streamControllers: null),
    );
  }
}

class SupplierDashboardPage extends StatefulWidget {
  const SupplierDashboardPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<SupplierDashboardPage> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboardPage> {
  bool isHomePage = false;

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

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
              content: const Text('Are you sure to exit the apps?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
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
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers!),
        appBar: AppsBarState().buildSupplierDashboardAppBar(context, 'Supplier Dashboard', currentUser, widget.streamControllers!),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 20,),
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
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => SupplierListWithDeletePage(user: currentUser, streamControllers: widget.streamControllers)));
                                },
                                child: Column(
                                  children: [
                                    Image.asset('images/supplierManagement.png',),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      child: Text('Suppliers', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
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
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => StockReceiptListPage(user: currentUser, streamControllers: widget.streamControllers)));
                                },
                                child: Column(
                                  children: [
                                    Image.asset('images/stockReceipt.png'),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      child: Text('Stock Receipt', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),),
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
      ),
    );
  }
}