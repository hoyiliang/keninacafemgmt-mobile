import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/LeaveApplication/applyLeaveForm.dart';
import 'package:keninacafe/LeaveApplication/viewLeaveApplicationStatus.dart';
import 'package:keninacafe/StaffManagement/staffList.dart';
import 'package:keninacafe/SupplierManagement/stockReceiptList.dart';
import 'package:keninacafe/SupplierManagement/supplierListWithDelete.dart';

import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/User.dart';
import 'createStockReceipt.dart';

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
      home: const SupplierDashboardPage(user: null,),
    );
  }
}

class SupplierDashboardPage extends StatefulWidget {
  const SupplierDashboardPage({super.key, this.user});

  final User? user;

  @override
  State<SupplierDashboardPage> createState() => _SupplierDashboardState();
}

class _SupplierDashboardState extends State<SupplierDashboardPage> {
  bool isHomePage = false;

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
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage),
      appBar: AppsBarState().buildSupplierDashboardAppBar(context, 'Supplier Dashboard', currentUser!),
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
                                    MaterialPageRoute(builder: (context) => SupplierListWithDeletePage(user: currentUser)));
                              },
                              child: Column(
                                children: [
                                  Image.asset('images/supplierManagement.png',),
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
                                Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => StockReceiptListPage(user: currentUser)));
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
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }
}