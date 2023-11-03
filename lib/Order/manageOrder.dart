import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Announcement/createAnnouncement.dart';
import '../AppsBar.dart';
import '../Entity/FoodOrder.dart';
import '../Entity/User.dart';
import '../Utils/error_codes.dart';

import 'package:flutter/cupertino.dart';

import 'incomingOrderDetails.dart';
import 'kitchenOrderDetails.dart';

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
      home: ManageOrderPage(user: null),
    );
  }
}

class ManageOrderPage extends StatefulWidget {
  const ManageOrderPage({super.key, this.user});

  final User? user;

  @override
  State<ManageOrderPage> createState() => _ManageOrderPageState();
}

class _ManageOrderPageState extends State<ManageOrderPage>{

  User? getUser() {
    return widget.user;
  }

  onGoBack(dynamic value) {
    setState(() {});
  }

  void navigateKitchenOrderDetailsPage(FoodOrder currentOrder, User currentUser) {
    Route route = MaterialPageRoute(builder: (context) => KitchenOrderDetailsPage(order: currentOrder, user: currentUser,));
    Navigator.push(context, route).then(onGoBack);
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade200,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(125),
          child: AppBar(
            bottom: PreferredSize(
              preferredSize: const Size(0,00),
              child: SizedBox(
                height: 50.0,
                child: Material(
                  color: Colors.deepPurple[100],
                  child: TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.access_time)),
                      Tab(icon: Icon(Icons.restaurant)),
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
            title: const Text("Order",
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
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser))
                    );
                  },
                  icon: const Icon(Icons.notifications, size: 35,),
                ),
              ),
            ],
          ),
        ),
        drawer: AppsBarState().buildDrawer(context),
        body: SafeArea(
          child: TabBarView(
            children: [
              SingleChildScrollView (
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 20.0),
                    child: FutureBuilder<List<FoodOrder>>(
                      future: getIncomingOrderList(currentUser!),
                      builder: (BuildContext context, AsyncSnapshot<List<FoodOrder>> snapshot) {
                        if (snapshot.hasData) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                              child: Column(
                                children: buildIncomingOrderList(snapshot.data, currentUser),
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
              SingleChildScrollView (
                child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 20.0),
                    child: FutureBuilder<List<FoodOrder>>(
                        future: getKitchenOrderList(currentUser!),
                        builder: (BuildContext context, AsyncSnapshot<List<FoodOrder>> snapshot) {
                          if (snapshot.hasData) {
                            return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                child: Column(
                                  children: buildKitchenOrderList(snapshot.data, currentUser),
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
            ],
          ),
        ),
        bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser!, context),
      ),
    );
  }

  List<Widget> buildIncomingOrderList(List<FoodOrder>? orderList, User? currentUser) {
    List<Widget> card = [];
    for (int i = 0; i < orderList!.length; i++) {
      DateTime dateTime = orderList[i].dateTime;
      String formattedDate = DateFormat('yyyy-MM-dd  HH:mm:ss').format(dateTime);
      card.add(
        Card(
          color: Colors.white,
          elevation: 20.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15.0), // Adjust the radius as needed
            // side: BorderSide(color: Colors.deepOrangeAccent.shade200, width: 1.0), // Border color and width
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) => IncomingOrderDetailsPage(user: currentUser, order: orderList[i],))
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 4.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        // padding: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            "images/KE_Nina_Cafe_logo.jpg",
                            width: 80,
                            height: 80,
                          ),
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
                                  "Order  ",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.grey.shade900,
                                    fontFamily: "Itim",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "#${orderList[i].id}",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.grey.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Itim"
                                  ),
                                ),
                              ]
                          ),
                          const SizedBox(height: 10.0,),
                          if (orderList[i].order_status == "PL")
                            SizedBox(
                              height: 30,
                              width: 130,
                              child: Material(
                                  elevation: 3.0,
                                  color: Colors.grey.shade500,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        200), // Apply border radius if needed
                                  ),
                                  child: const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Pending Payment",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                              ),
                            ),
                          if (orderList[i].order_status == "CF")
                            SizedBox(
                              height: 30,
                              width: 90,
                              child: Material(
                                  elevation: 3.0,
                                  color: const Color(0xFFFFD700),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                  ),
                                  child: const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Preparing",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order Time",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade600,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade800,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                        ],
                      )
                  ),
                  const SizedBox(height: 6.0),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Table",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade600,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                          Text(
                            "13",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade800,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                        ],
                      )
                  ),
                  const SizedBox(height: 6.0),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade600,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                          Text(
                            "MYR ${orderList[i].grand_total.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade800,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      card.add(
        const SizedBox(height: 20.0,),
      );
    }
    return card;
  }

  List<Widget> buildKitchenOrderList(List<FoodOrder>? orderList, User? currentUser) {
    List<Widget> card = [];
    for (int i = 0; i < orderList!.length; i++) {
      DateTime dateTime = orderList[i].dateTime;
      String formattedDate = DateFormat('yyyy-MM-dd  HH:mm:ss').format(dateTime);
      card.add(
        Card(
          color: Colors.white,
          elevation: 20.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                15.0), // Adjust the radius as needed
            // side: BorderSide(color: Colors.deepOrangeAccent.shade200, width: 1.0), // Border color and width
          ),
          child: InkWell(
            onTap: () {
              // Navigator.push(context,
              //     MaterialPageRoute(
              //         builder: (context) => KitchenOrderDetailsPage(user: currentUser, order: orderList[i],))
              // );
              navigateKitchenOrderDetailsPage(orderList[i], currentUser!);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                  horizontal: 4.0, vertical: 8.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        // padding: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            "images/KE_Nina_Cafe_logo.jpg",
                            width: 80,
                            height: 80,
                          ),
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
                                  "Order  ",
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.grey.shade900,
                                    fontFamily: "Itim",
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "#${orderList[i].id}",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color: Colors.grey.shade900,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Itim"
                                  ),
                                ),
                              ]
                          ),
                          const SizedBox(height: 10.0,),
                          if (orderList[i].order_status == "PL")
                            SizedBox(
                              height: 30,
                              width: 130,
                              child: Material(
                                  elevation: 3.0,
                                  color: Colors.grey.shade500,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        200), // Apply border radius if needed
                                  ),
                                  child: const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Pending Payment",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                              ),
                            ),
                          if (orderList[i].order_status == "CF")
                            SizedBox(
                              height: 30,
                              width: 90,
                              child: Material(
                                  elevation: 3.0,
                                  color: const Color(0xFFFFD700),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                  ),
                                  child: const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Preparing",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                              ),
                            ),
                        ],
                      )
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order Time",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade600,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade800,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                        ],
                      )
                  ),
                  const SizedBox(height: 6.0),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Table",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade600,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                          Text(
                            "13",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade800,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                        ],
                      )
                  ),
                  const SizedBox(height: 6.0),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade600,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                          Text(
                            "MYR ${orderList[i].grand_total.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17.0,
                              color: Colors.grey.shade800,
                              fontFamily: "Rajdhani",
                            ),
                          ),
                        ],
                      )
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      card.add(
        const SizedBox(height: 20.0,),
      );
    }
    return card;
  }

  Future<List<FoodOrder>> getIncomingOrderList(User currentUser) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/order/request_incoming_order'),
        // Uri.parse('http://localhost:8000/menu/request_item_category_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FoodOrder.getOrderList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the incoming order list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<List<FoodOrder>> getKitchenOrderList(User currentUser) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/order/request_kitchen_order'),
        // Uri.parse('http://localhost:8000/menu/request_item_category_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return FoodOrder.getOrderList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the kitchen order list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}