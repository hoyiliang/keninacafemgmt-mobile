import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keninacafe/Announcement/createAnnouncement.dart';
import 'package:keninacafe/Entity/Transaction.dart';
import 'package:keninacafe/Order/manageOrder.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'Attendance/manageAttendanceRequest.dart';
import 'Entity/User.dart';
import 'package:keninacafe/AppsBar.dart';

import 'Utils/WebSocketSingleton.dart';
import 'Utils/ip_address.dart';

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
      home: const DashboardPage(user: null, streamControllers: null),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isHomePage = true;
  DateTime? selectedDate;
  bool isLoading = true;
  bool displayYearGraph = false;
  DateTime selectedMonthYear = DateTime.now();

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
        selectedMonthYear = picked;
        displayYearGraph = false;
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
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    WebSocketSingleton(widget.streamControllers!).listen(context, widget.user!);
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
        drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers),
        appBar: AppsBarState().buildAppBar(context, 'Dashboard', currentUser, widget.streamControllers),
        body: SafeArea(
          child: SingleChildScrollView (
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(13, 13, 5, 13),
                          child: Text(
                            'Overall Data on ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              fontFamily: 'Gabarito',
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          width: 200.0,
                          padding: const EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 8.0),
                              const Icon(
                                Icons.calendar_today,
                                size: 20.0,
                              ),
                              const SizedBox(width: 15.0),
                              selectedDate != null
                                  ? Text(
                                '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gabarito',
                                ),
                              ) : const Text(
                                '',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 5.0,),
                    ],
                  ),
                ),

                if (selectedDate != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 0),
                    child: FutureBuilder<List<Transaction>>(
                      future: getTransactionDataByDate(selectedDate!),
                      builder: (BuildContext context, AsyncSnapshot<List<Transaction>> snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              child: Column(
                                  children: [buildOverallTransactionDataCard(snapshot.data)],
                              )
                          );

                        } else {
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            return Center(child: Center(
                              child: LoadingAnimationWidget.horizontalRotatingDots(
                                color: Colors.black,
                                size: 50,
                              ),
                            ),);
                          }
                        }
                      }
                    )
                  ),
                const SizedBox(width: 5.0,),
                const SizedBox(height: 18.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(13, 13, 5, 13),
                        child: Text(
                          'Overall Profit',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            fontFamily: 'Gabarito',
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 100.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          // color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        child: MaterialButton(
                          // minWidth: double.infinity,
                          height:40,
                          onPressed: () {
                            setState(() {
                              displayYearGraph = true;
                            });
                          },
                          child: Text(
                            "Month",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15.0,),
                  ],
                ),
                Center(
                  child: FutureBuilder(
                    future: loadWebView(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 50.0),
                          child: Center(
                            child: LoadingAnimationWidget.threeRotatingDots(
                              color: Colors.black,
                              size: 50,
                            ),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error loading web page'),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: SizedBox(
                            height: 393,
                            width: 380,
                            child: WebView(
                              initialUrl: displayYearGraph ? '${IpAddress.ip_addr}/transaction/request_owner_dashboard_graph/all/' : '${IpAddress.ip_addr}/transaction/request_owner_dashboard_graph/${DateFormat('yyyy-MM-dd').format(selectedMonthYear)}/',
                              javascriptMode: JavascriptMode.unrestricted,
                              onPageFinished: (String url) {
                              },
                            ),
                          ),
                        );
                      }
                    },
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOverallTransactionDataCard(List<Transaction>? currentDateTransactionData) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: const Color(0xFFE7E6FB),
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: 160.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 8.0),
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Material(
                          elevation: 3.0,
                          color: const Color(0xFFE7E6FB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.trending_up,
                                size: 35.0,
                                color: Color(0xFF6151FB),
                              )
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Profit",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey.shade700,
                            fontFamily: "Itim",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentDateTransactionData!.isNotEmpty)
                          Text(
                            (currentDateTransactionData![0].total_revenue-currentDateTransactionData[0].total_spend_stock_receipt).toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Itim"
                            ),
                          )
                        else
                          const Text(
                            "0",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Itim"
                            ),
                          ),
                        const SizedBox(height: 10.0,),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12.0,),
            Card(
              color: const Color(0xFFDFEDF7),
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: 160.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 8.0),
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Material(
                          elevation: 3.0,
                          color: const Color(0xFFDFEDF7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                          ),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.attach_money,
                                size: 35.0,
                                color: Color(0xFF1B8BE3),
                              )
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Revenue",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey.shade700,
                            fontFamily: "Itim",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentDateTransactionData.isNotEmpty)
                          Text(
                            currentDateTransactionData[0].total_revenue.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Itim"
                            ),
                          )
                        else
                          const Text(
                            "0",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Itim"
                            ),
                          ),
                        const SizedBox(height: 10.0,),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Colors.pink.shade50,
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                width: 160.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 8.0),
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Material(
                          elevation: 3.0,
                          color: Colors.pink.shade50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                          ),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.trending_down,
                                size: 35.0,
                                color: Color(0xFFED1D4D),
                              )
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Expenses",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey.shade700,
                            fontFamily: "Itim",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentDateTransactionData.isNotEmpty)
                          Text(
                            currentDateTransactionData[0].total_spend_stock_receipt.toStringAsFixed(2),
                            style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Itim"
                            ),
                          )
                        else
                          const Text(
                            "0",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Itim"
                            ),
                          ),
                        const SizedBox(height: 10.0,),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12.0,),
            Card(
              color: const Color(0xFFFBEDD9),
              elevation: 10.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
              ),
              child: Container(
                width: 160.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(4.0, 4.0, 4.0, 8.0),
                      child: SizedBox(
                        height: 60,
                        width: 60,
                        child: Material(
                          elevation: 3.0,
                          color: const Color(0xFFFBEDD9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
                          ),
                          child: const Align(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.receipt_long,
                                size: 35.0,
                                color: Color(0xFFFFA01F),
                              )
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Orders",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey.shade700,
                            fontFamily: "Itim",
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (currentDateTransactionData.isNotEmpty)
                          Text(
                            currentDateTransactionData[0].num_transaction.toString(),
                            style: const TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Itim"
                            ),
                          )
                        else
                          const Text(
                            "0",
                            style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Itim"
                            ),
                          ),
                        const SizedBox(height: 10.0,),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Future<List<Transaction>> getTransactionDataByDate(DateTime selectedDate) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    try {
      final response = await http.post(
        Uri.parse('${IpAddress.ip_addr}/transaction/request_transaction_by_date'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'date_selected': formattedDate,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Transaction.getOneTransaction(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the transaction data by date.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<String> fetchGraphData() async {
    try{
      final response = await http.get(
        Uri.parse('${IpAddress.ip_addr}/transaction/request_owner_dashboard_graph'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to load graph data');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<void> loadWebView() async {
    // Simulate loading delay (replace with your actual loading logic)
    await Future.delayed(Duration(seconds: 2));
    // You can perform any asynchronous tasks here before returning
  }
  // Future<String> testing() async {
  //   try{
  //     final response = await http.post(
  //       Uri.parse('${IpAddress.ip_addr}/transaction/request_testing'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       return response.body;
  //     } else {
  //       throw Exception('Failed to load graph data');
  //     }
  //   } on Exception catch (e) {
  //     throw Exception('API Connection Error. $e');
  //   }
  // }
}