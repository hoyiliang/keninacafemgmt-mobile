import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/MenuManagement/updateMenuItem.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Announcement/createAnnouncement.dart';
import '../AppsBar.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';


import '../Order/manageOrder.dart';
import '../Utils/error_codes.dart';
import 'createMenuItem.dart';

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
      home: const MenuListPage(user: null, streamControllers: null),
    );
  }
}

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage>{
  String? categoryName;
  String? tempCategoryName;
  final descriptionController = TextEditingController();
  bool deleteUser = false;
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  onGoBack(dynamic value) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Web Socket
    widget.streamControllers!['order']?.stream.listen((message) {
      final snackBar = SnackBar(
          content: const Text('Received new order!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ManageOrderPage(user: getUser(), streamControllers: widget.streamControllers),
                ),
              );
            },
          )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    widget.streamControllers!['announcement']?.stream.listen((message) {
      final data = jsonDecode(message);
      String content = data['message'];
      if (content == 'New Announcement') {
        final snackBar = SnackBar(
            content: const Text('Received new announcement!'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateAnnouncementPage(user: getUser(),
                            streamControllers: widget.streamControllers),
                  ),
                );
              },
            )
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else if (content == 'Delete Announcement') {
        print("Received delete announcement!");
      }
    });

    widget.streamControllers!['attendance']?.stream.listen((message) {
      SnackBar(
          content: const Text('Received new attendance request!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ManageAttendanceRequestPage(user: getUser(), streamControllers: widget.streamControllers),
                ),
              );
            },
          )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return FutureBuilder<List<MenuItem>>(
      future: getItemCategoryList(),
      builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
        if (snapshot.hasData) {
          return DefaultTabController(
            length: snapshot.data!.length,
            child: Scaffold(
              backgroundColor: Colors.white,
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
                          isScrollable: true,
                          tabs: [
                            for (int i = 0; i < snapshot.data!.length; i++)
                              Text(
                                snapshot.data![i].category_name,
                                // style: TextStyle(
                                //   fontWeight: FontWeight.bold,
                                // ),
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
                          unselectedLabelColor: Colors.grey.shade700,
                          labelColor: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  elevation: 0,
                  toolbarHeight: 100,
                  title: const Text("Menu List",
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
                              MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser, streamControllers: widget.streamControllers))
                          );
                        },
                        icon: const Icon(Icons.notifications, size: 35,),
                      ),
                    ),
                  ],
                ),
              ),
              drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers),
              body: SafeArea(
                child: FutureBuilder<List<MenuItem>>(
                  future: getMenuItemList(),
                  builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                          child: TabBarView(
                            children: buildTabBarView(snapshot.data, currentUser),
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
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CreateMenuItemPage(user: currentUser, streamControllers: widget.streamControllers))
                  );
                },
                child: const Icon(
                  Icons.add,
                  size: 27.0,
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              bottomNavigationBar: BottomAppBar(
                height: 20.0,
                color: Theme.of(context).colorScheme.inversePrimary,
                shape: const CircularNotchedRectangle(),
              ),
            ),
          );
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: Text(''));
          }
        }
      }
    );
  }

  List<Widget> buildTabBarView(List<MenuItem>? menuItemList, User currentUser) {
    List<Widget> tabBarView = [];
    for (int i = 0; i < menuItemList!.length; i++) {
      categoryName = menuItemList[i].category_name;
      if (tempCategoryName != categoryName) {
        tempCategoryName = categoryName;
        tabBarView.add(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 15.0),
              child: Column(
                children: [
                  for (int j = i; j < menuItemList.length; j++)
                    if (menuItemList[j].category_name == tempCategoryName)
                      Column(
                        children: [
                          SizedBox(
                            height: 175.0,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                menuItemList[j].name,
                                                style: TextStyle(
                                                  fontSize: 17.0,
                                                  color: Colors.grey.shade900,
                                                  fontFamily: "YoungSerif",
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5.0,),
                                        if (menuItemList[j].hasVariant)
                                          Row(
                                            children: [
                                              Text(
                                                'Variant : ',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: "Oswald",
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${menuItemList[j].variants.split(",")[0]} / ',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: "Oswald",
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                menuItemList[j].variants.split(",")[1],
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: "Oswald",
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (!menuItemList[j].hasVariant)
                                          Row(
                                            children: [
                                              Text(
                                                'Variant : ',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: "Oswald",
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'No variant assigned.',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: "Oswald",
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (menuItemList[j].hasSize)
                                          Row(
                                            children: [
                                              Text(
                                                'Size: ',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: "Oswald",
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${menuItemList[j].sizes.split(",")[0]} / ',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: "Oswald",
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                menuItemList[j].sizes.split(",")[1],
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: "Oswald",
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (!menuItemList[j].hasSize)
                                          Row(
                                            children: [
                                              Text(
                                                'Size : ',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: "Oswald",
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                'No size assigned.',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade700,
                                                  fontFamily: "Oswald",
                                                  // fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        const SizedBox(height: 8.0,),
                                        Row(
                                          children: [
                                            Align(
                                              alignment: Alignment.topLeft,
                                              child: Container(
                                                width: 120.0,
                                                height: 30.0,
                                                padding: const EdgeInsets.only(top: 3),
                                                child: MaterialButton(
                                                  minWidth: double.infinity,
                                                  height: 20,
                                                  onPressed: () {
                                                    descriptionController.text = menuItemList[j].description;
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
                                                                    'Description',
                                                                    style: TextStyle(fontSize: 21.5, fontWeight: FontWeight.bold),
                                                                  ),
                                                                  const Spacer(),
                                                                  IconButton(
                                                                    icon: const Icon(Icons.close),
                                                                    onPressed: () {
                                                                      descriptionController.text = '';
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
                                                                      controller: descriptionController,
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
                                                  color: Colors.grey.shade200,
                                                  child: Text(
                                                    "Description",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                        color: Colors.orangeAccent.shade400
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6.0,),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            Text(
                                              'MYR ${menuItemList[j].price_standard.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                color: Colors.grey.shade900,
                                                fontFamily: "BreeSerif",
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (menuItemList[j].hasSize)
                                              Text(
                                                ' / ${menuItemList[j].price_large.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.grey.shade900,
                                                  fontFamily: "BreeSerif",
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: !menuItemList[j].isOutOfStock? Colors.green : Colors.red),
                                              // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                              onPressed: () async {
                                                showUpdateIsOutOfStockConfirmationDialog(menuItemList[j]);
                                              },
                                              child: !menuItemList[j].isOutOfStock
                                                  ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 18.0,
                                              ) : const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18.0,
                                              )
                                            ),
                                          ),
                                          const SizedBox(width: 20.0),
                                          Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                                              // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                              onPressed: () async {
                                                Route route = MaterialPageRoute(builder: (context) =>UpdateMenuItemPage(user: currentUser, menuItem: menuItemList[j], streamControllers: widget.streamControllers));
                                                Navigator.push(context, route).then(onGoBack);
                                              },
                                              child: Icon(Icons.edit, color: Colors.grey.shade800),
                                            ),
                                          ),
                                          const SizedBox(width: 15.0),
                                          Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                                              // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                              onPressed: () async {
                                                showDeleteConfirmationDialog(menuItemList[j]);
                                              },
                                              child: Icon(Icons.delete, color: Colors.grey.shade800),
                                            ),
                                          ),
                                          const SizedBox(width: 5.0,),
                                        ],
                                      ),
                                      const Spacer(),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15.0),
                                        child: menuItemList[j].image == "" ? Image.asset('images/menuItem.png', width: 100, height: 100,) : Image.memory(base64Decode(menuItemList[j].image), width: 100, height: 100,)
                                      ),
                                    ],
                                  )
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 30.0,),
                        ],
                      )
                ],
              ),
            ),
          ),
        );
      }
    }
    return tabBarView;
  }

  Future<List<MenuItem>> getItemCategoryList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/menu/request_item_category_list'),
        // Uri.parse('http://localhost:8000/menu/request_item_category_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return MenuItem.getItemCategoryExistMenuItemList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the item category exist menu item list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<List<MenuItem>> getMenuItemList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/menu/request_menu_item_list'),
        // Uri.parse('http://localhost:8000/menu/request_menu_item_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return MenuItem.getMenuItemDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the menu item data list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<(String, bool)> _submitDeleteMenuItem(MenuItem currentMenuItem) async {
    var (success, err_code) = await deleteMenuItemData(currentMenuItem);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to delete menu item (${currentMenuItem.name}) data.");
      }
      return (err_code, success);
    }
    return (err_code, success);
  }


  Future<(bool, String)> deleteMenuItemData(MenuItem currentMenuItem) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/menu/delete_menu_item/${currentMenuItem.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No Menu Item (${currentMenuItem.name}) found.');
        }
        return (false, (ErrorCodes.DELETE_MENU_ITEM_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.DELETE_MENU_ITEM_FAIL_API_CONNECTION));
    }
  }

  Future<(String, bool)> _submitIsOutOfStockStatusMenuItem(MenuItem currentMenuItem) async {
    bool outOfStockStatusUpdate = !currentMenuItem.isOutOfStock;
    var (success, err_code) = await updateIsOutOfStockStatusMenuItem(currentMenuItem, outOfStockStatusUpdate);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to update IsOutOfStock status of the menu item (${currentMenuItem.name}) data.");
      }
      return (err_code, success);
    }
    return (err_code, success);
  }


  Future<(bool, String)> updateIsOutOfStockStatusMenuItem(MenuItem currentMenuItem, bool outOfStockStatusUpdate) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/menu/update_is_out_of_stock/${currentMenuItem.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'isOutOfStock': outOfStockStatusUpdate,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No Menu Item (${currentMenuItem.name}) found.');
        }
        return (false, (ErrorCodes.UPDATE_ISOUTOFSTOCK_STATUS_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_ISOUTOFSTOCK_STATUS_FAIL_API_CONNECTION));
    }
  }

  void showUpdateIsOutOfStockConfirmationDialog(MenuItem currentMenuItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: !currentMenuItem.isOutOfStock ? Text('Are you sure you want to disable this menu item (${currentMenuItem.name})?') : Text('Are you sure you want to enable this menu item (${currentMenuItem.name})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (err_code, updateIsOutOfStockStatusAsync) = await _submitIsOutOfStockStatusMenuItem(currentMenuItem);
                setState(() {
                  if (err_code == ErrorCodes.UPDATE_ISOUTOFSTOCK_STATUS_FAIL_BACKEND) {
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Error'),
                          content: Text('An Error occurred while trying to update the IsOutOfStock status of the menu item (${currentMenuItem.name}).\n\nError Code: $err_code'),
                          actions: <Widget>[
                            TextButton(onPressed: () =>
                                Navigator.pop(context, 'Ok'),
                                child: const Text('Ok')),
                          ],
                        ),
                    );
                  } else if (err_code == ErrorCodes.UPDATE_ISOUTOFSTOCK_STATUS_FAIL_API_CONNECTION){
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
                  } else {
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: !currentMenuItem.isOutOfStock ? Text('Disable the Menu Item (${currentMenuItem.name}) Successful') : Text('Enable the Menu Item (${currentMenuItem.name}) Successful'),
                          // content: const Text(''),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                setState(() {});
                                Navigator.of(context).pop();
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => SupplierListWithDeletePage(user: currentUser)),
                                // );
                              },
                            ),
                          ],
                        ),
                    );
                  }
                });
                // saveAnnouncement(title, text);
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

  void showDeleteConfirmationDialog(MenuItem currentMenuItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to delete this menu item (${currentMenuItem.name})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (err_code, deleteMenuItem) = await _submitDeleteMenuItem(currentMenuItem);
                setState(() {
                  if (err_code == ErrorCodes.DELETE_MENU_ITEM_FAIL_BACKEND) {
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Error'),
                          content: Text('An Error occurred while trying to delete the menu item (${currentMenuItem.name}).\n\nError Code: $err_code'),
                          actions: <Widget>[
                            TextButton(onPressed: () =>
                                Navigator.pop(context, 'Ok'),
                                child: const Text('Ok')),
                          ],
                        ),
                    );
                  } else if (err_code == ErrorCodes.DELETE_MENU_ITEM_FAIL_API_CONNECTION){
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
                  } else {
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: Text('Delete This Menu Item (${currentMenuItem.name}) Successful'),
                          // content: const Text(''),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                setState(() {});
                                Navigator.of(context).pop();
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => SupplierListWithDeletePage(user: currentUser)),
                                // );
                              },
                            ),
                          ],
                        ),
                    );
                  }
                });
                // saveAnnouncement(title, text);
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
}