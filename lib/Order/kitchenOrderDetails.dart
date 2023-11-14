import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/Entity/LeaveFormData.dart';
import 'package:keninacafe/LeaveApplication/applyViewLeaveApplication.dart';
import 'package:keninacafe/LeaveApplication/applyLeaveForm.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import '../Entity/FoodOrder.dart';
import '../Entity/OrderFoodItemMoreInfo.dart';
import '../Entity/User.dart';
import '../Entity/Attendance.dart';
import 'manageOrder.dart';

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
      home: const KitchenOrderDetailsPage(user: null,),
    );
  }
}

class KitchenOrderDetailsPage extends StatefulWidget {
  const KitchenOrderDetailsPage({super.key, this.user, this.order});

  final User? user;
  final FoodOrder? order;

  @override
  State<KitchenOrderDetailsPage> createState() => _KitchenOrderDetailsPageState();
}

class _KitchenOrderDetailsPageState extends State<KitchenOrderDetailsPage> {
  final remarksController = TextEditingController();
  bool orderFoodItemStatusUpdated = false;
  bool orderStatusUpdated = false;

  User? getUser() {
    return widget.user;
  }

  FoodOrder? getOrder() {
    return widget.order;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    FoodOrder? currentOrder = getOrder();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildDetailsAppBar(context, 'Order Details', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
              child: FutureBuilder<List<OrderFoodItemMoreInfo>>(
                  future: getOrderFoodItemDetails(currentOrder!),
                  builder: (BuildContext context, AsyncSnapshot<List<OrderFoodItemMoreInfo>> snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          child: Column(
                            children: buildMenuItemDataRows(snapshot.data, currentOrder, currentUser),
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
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }

  List<Widget> buildMenuItemDataRows(List<OrderFoodItemMoreInfo>? orderFoodItemList, FoodOrder currentOrder, User? currentUser) {
    List<Widget> rows = [];
    bool is_order_done = true;
    rows.add(
      Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "Order :  ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: "Itim",
                    ),
                  ),
                  Text(
                    "# ${orderFoodItemList?[0].food_order}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: "Itim",
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  Text(
                    "Table :  ",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Itim",
                    ),
                  ),
                  Text(
                    "13",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: "Itim",
                    ),
                  ),
                ],
              )
            ],
          )
      ),
    );
    rows.add(
      Table(
        children: [
          TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade300),
              children: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Item (s)",
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                        fontFamily: 'Oswald',
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Quantity",
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                        // fontWeight: FontWeight.bold,
                        fontFamily: 'Oswald',
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "View / Mark",
                      style: TextStyle(
                        fontSize: 19,
                        color: Colors.black,
                        fontFamily: 'Oswald',
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ]
          ),
        ],
      ),
    );

    for (int i = 0; i < orderFoodItemList!.length; i++) {
      if (orderFoodItemList[i].is_done == false) {
        is_order_done = false;
      }
      rows.add(
        Table(
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Colors.white),
              children: [
                Center(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  orderFoodItemList[i].menu_item_name,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    color: Colors.grey.shade700,
                                    fontFamily: 'Oswald',
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                              if (orderFoodItemList[i].remarks != "")
                                const Text(
                                  '*',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.red,
                                    fontFamily: 'BebasNeue',
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                              children: [
                                if (orderFoodItemList[i].size != "" || orderFoodItemList[i].variant != "")
                                  Row(
                                    children: [
                                      const Text(
                                        "( ",
                                        style: TextStyle(
                                          fontSize: 8.0,
                                          color: Colors.red,
                                          // fontFamily: 'YoungSerif',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (orderFoodItemList[i].variant != "")
                                        Text(
                                          orderFoodItemList[i].variant,
                                          style: const TextStyle(
                                            fontSize: 8.0,
                                            color: Colors.red,
                                            // fontFamily: 'YoungSerif',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (orderFoodItemList[i].size != "" && orderFoodItemList[i].variant != "")
                                        const Text(
                                          ", ",
                                          style: TextStyle(
                                            fontSize: 8.0,
                                            color: Colors.red,
                                            // fontFamily: 'YoungSerif',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      if (orderFoodItemList[i].size != "")
                                        Text(
                                          orderFoodItemList[i].size,
                                          style: const TextStyle(
                                            fontSize: 8.0,
                                            color: Colors.red,
                                            // fontFamily: 'YoungSerif',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      const Text(
                                        // menuItemList[i].variantChosen,
                                        " )",
                                        style: TextStyle(
                                          fontSize: 8.0,
                                          color: Colors.red,
                                          // fontFamily: 'YoungSerif',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                              ]
                          )
                        ],
                      )
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      orderFoodItemList[i].numOrder.toInt().toString(),
                      style: TextStyle(
                        fontSize: 14.5,
                        color: Colors.grey.shade700,
                        fontFamily: 'Oswald',
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye), // Replace with your desired icon
                      onPressed: () {
                        remarksController.text = orderFoodItemList[i].remarks;
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Remarks',
                                        style: TextStyle(fontSize: 21.5, fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: const Icon(Icons.close),
                                        onPressed: () {
                                          remarksController.text = '';
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  ),
                                  Form(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextFormField(
                                          maxLines: null,
                                          controller: remarksController,
                                          readOnly: true,
                                          decoration: const InputDecoration(
                                            labelStyle: TextStyle(color: Colors.black, fontSize: 15.0),
                                          ),
                                        ),
                                        const SizedBox(height: 5.0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Checkbox(
                        value: orderFoodItemList[i].is_done,
                        onChanged: (bool? value) async {
                          if (value != null) {
                            var (orderFoodItemStatusUpdatedAsync, err_code) = await updateOrderFoodItemStatus(orderFoodItemList[i], value);
                            orderFoodItemStatusUpdated = orderFoodItemStatusUpdatedAsync;
                            if (!orderFoodItemStatusUpdated) {
                              if (err_code == ErrorCodes.UPDATE_ORDER_FOOD_ITEM_STATUS_FAIL_BACKEND) {
                                showDialog(context: context, builder: (
                                    BuildContext context) =>
                                    AlertDialog(
                                      title: const Text('Error'),
                                      content: Text('An Error occurred while trying to update the status of the food item.\n\nError Code: $err_code'),
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
                                      title: const Text('Connection Error'),
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
                              setState(() {
                                orderFoodItemStatusUpdated = false;
                              });
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TableRow(
              children: [
                Divider(color: Colors.grey.shade200, height: 0,), // Add a divider
                Divider(color: Colors.grey.shade200, height: 0,),
                Divider(color: Colors.grey.shade200, height: 0,),
              ],
            ),
          ],
        ),
      );
    }
    rows.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 130.0,
              height: 40.0,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.greenAccent.shade400,
                borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
              ),
              child: MaterialButton(
                // minWidth: double.infinity,
                height:40,
                onPressed: () {
                  showCompletedDialog(is_order_done, currentOrder, currentUser!);
                },
                child: const Text(
                  "Complete",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return rows;
  }

  Future<void> showCompletedDialog(bool is_order_done, FoodOrder currentOrder, User currentUser) async {
    if (is_order_done) {
      var (orderStatusUpdatedAsync, err_code) = await updateKitchenOrderStatus(currentOrder, is_order_done);
      setState(() {
        orderStatusUpdated = orderStatusUpdatedAsync;
        if (!orderStatusUpdated) {
          if (err_code == ErrorCodes.UPDATE_ORDER_STATUS_FAIL_BACKEND) {
            showDialog(context: context, builder: (
                BuildContext context) =>
                AlertDialog(
                  title: const Text('Error'),
                  content: Text('An Error occurred while trying to update the order status to completed.\n\nError Code: $err_code'),
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
                  title: const Text('Connection Error'),
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
                title: const Text('Order Completed'),
                content: const Text('All the food ordered are prepared to the customers.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Ok'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
          );
        }
      });
    } else {
      showDialog(context: context, builder: (
          BuildContext context) =>
          AlertDialog(
            title: const Text('Incomplete'),
            content: const Text('This Order Have Not Completed Yet.'),
            actions: <Widget>[
              TextButton(onPressed: () =>
                  Navigator.pop(context, 'Ok'),
                  child: const Text('Ok')),
            ],
          ),
      );
    }
  }

  Future<List<OrderFoodItemMoreInfo>> getOrderFoodItemDetails(FoodOrder currentOrder) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/order/request_order_details/${currentOrder.id}/'),
        // Uri.parse('http://localhost:8000/menu/request_item_category_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return OrderFoodItemMoreInfo.getOrderFoodItemDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the order details.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<(bool, String)> updateOrderFoodItemStatus(OrderFoodItemMoreInfo orderFoodItem, bool is_done) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/order/update_order_food_item_status/${orderFoodItem.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'is_done': is_done,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('Update Order Food Item Status Failed.');
        }
        return (false, (ErrorCodes.UPDATE_ORDER_FOOD_ITEM_STATUS_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_ORDER_FOOD_ITEM_STATUS_FAIL_API_CONNECTION));
    }
  }

  Future<(bool, String)> updateKitchenOrderStatus(FoodOrder currentOrder, bool is_order_done) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/order/update_order_status/${currentOrder.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'order_status': "CP",
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('Update Order Status Failed.');
        }
        return (false, (ErrorCodes.UPDATE_ORDER_STATUS_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_ORDER_STATUS_FAIL_API_CONNECTION));
    }
  }
}