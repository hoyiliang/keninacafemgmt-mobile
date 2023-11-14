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
      home: const IncomingOrderDetailsPage(user: null,),
    );
  }
}

class IncomingOrderDetailsPage extends StatefulWidget {
  const IncomingOrderDetailsPage({super.key, this.user, this.order});

  final User? user;
  final FoodOrder? order;

  @override
  State<IncomingOrderDetailsPage> createState() => _IncomingOrderDetailsPageState();
}

class _IncomingOrderDetailsPageState extends State<IncomingOrderDetailsPage> {
  final remarksController = TextEditingController();
  bool remarksUpdated = false;
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

  Future showRemarksCard(BuildContext context, String remarks) {
    remarksController.text = remarks;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    'Edit Remarks',
                    style: TextStyle(fontSize: 21.5, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(), // Add a spacer to push the icon to the right
                  IconButton(
                    icon: const Icon(Icons.close), // Replace with your desired icon
                    onPressed: () {
                      remarksController.text = '';
                      Navigator.of(context).pop(); // Close the dialog
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
                      // onChanged: (text) {
                      //   setState(() {
                      //     remarksUpdate = remarksController.text;
                      //   });
                      // },
                      decoration: const InputDecoration(
                        labelText: 'Remarks',
                        labelStyle: TextStyle(color: Colors.black, fontSize: 15.0), // Set label color to white
                      ),
                    ),
                    const SizedBox(height: 5.0),
                  ],
                ),
              ),
            ],
          ),

          actions: [
            ElevatedButton(
              onPressed: () {
                // Save announcement logic goes here
                // Navigator.of(context).pop();
                // if (_formKey.currentState!.validate()) {
                //   showConfirmationDialog(titleController.text, descriptionController.text);
                // }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> buildMenuItemDataRows(List<OrderFoodItemMoreInfo>? orderFoodItemList, FoodOrder currentOrder, User? currentUser) {
    List<Widget> rows = [];
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
                    "Remarks",
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.black,
                      fontFamily: 'Oswald',
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: GestureDetector(
                      onTap: () {
                        // showRemarksCard(context, orderFoodItemList[i].remarks);
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
                                        'Edit Remarks',
                                        style: TextStyle(fontSize: 21.5, fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(), // Add a spacer to push the icon to the right
                                      IconButton(
                                        icon: const Icon(Icons.close), // Replace with your desired icon
                                        onPressed: () {
                                          remarksController.text = '';
                                          Navigator.of(context).pop(); // Close the dialog
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
                                          decoration: const InputDecoration(
                                            labelText: 'Remarks',
                                            labelStyle: TextStyle(color: Colors.black, fontSize: 15.0), // Set label color to white
                                          ),
                                        ),
                                        const SizedBox(height: 5.0),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              actions: [
                                ElevatedButton(
                                  onPressed: () async {
                                    var (remarksUpdatedAsync, err_code) = await updateOrderFoodItemDetails(orderFoodItemList[i]);
                                    remarksUpdated = remarksUpdatedAsync;
                                    if (!remarksUpdated) {
                                      if (err_code == ErrorCodes.UPDATE_ORDER_FOOD_ITEM_REMARKS_FAIL_BACKEND) {
                                        showDialog(context: context, builder: (
                                            BuildContext context) =>
                                            AlertDialog(
                                              title: const Text('Error'),
                                              content: Text('An Error occurred while trying to update the remarks of the food item.\n\nError Code: $err_code'),
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
                                      Navigator.of(context).pop();
                                      setState(() {});
                                    }
                                  },
                                  child: const Text('Confirm'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.insert_comment_sharp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
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
                color: Colors.red,
                // border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
              ),
              child: MaterialButton(
                // minWidth: double.infinity,
                height:40,
                onPressed: () {
                  showConfirmationUpdatedStatusDialog(currentOrder, currentUser!, "RJ");
                },
                // color: Colors.red,
                child: const Text(
                  "Reject",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20.0),
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
                  showConfirmationUpdatedStatusDialog(currentOrder, currentUser!, "CF");
                },
                child: const Text(
                  "Confirm",
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

  void showConfirmationUpdatedStatusDialog(FoodOrder currentOrder, User currentUser, String order_status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: order_status == "CF" ? const Text('Are you sure to confirm this order?') : const Text('Are you sure to reject this order?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (orderStatusUpdatedAsync, err_code) = await updateIncomingOrderStatus(currentOrder, order_status);
                setState(() {
                  orderStatusUpdated = orderStatusUpdatedAsync;
                  if (! orderStatusUpdated) {
                    if (err_code == ErrorCodes.UPDATE_ORDER_STATUS_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error'),
                            content: order_status == "CF" ? Text('An Error occurred while trying to confirm this order.\n\nError Code: $err_code') : Text('An Error occurred while trying to reject this order.\n\nError Code: $err_code'),
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
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: order_status == "CF" ? const Text('Order Confirmed Successful') : const Text('Order Rejected Successful'),
                          content: order_status == "CF" ? const Text('Ask the kitchen to start to prepare the order.') : const Text('Please proceed to other order.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ManageOrderPage(user: currentUser)),
                                );
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

  Future<(bool, String)> updateOrderFoodItemDetails(OrderFoodItemMoreInfo orderFoodItem) async {
    String remarksUpdate = remarksController.text;
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/order/update_order_food_item_remarks/${orderFoodItem.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'remarks': remarksUpdate,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('Update Order Food Item Remarks Failed.');
        }
        return (false, (ErrorCodes.UPDATE_ORDER_FOOD_ITEM_REMARKS_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_ORDER_FOOD_ITEM_REMARKS_FAIL_API_CONNECTION));
    }
  }

  Future<(bool, String)> updateIncomingOrderStatus(FoodOrder currentOrder, String order_status) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/order/update_order_status/${currentOrder.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'order_status': order_status,
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