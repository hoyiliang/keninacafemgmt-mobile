import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/MenuManagement/updateMenuItem.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Announcement/createAnnouncement.dart';
import '../AppsBar.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';


import '../Order/manageOrder.dart';
import '../Utils/error_codes.dart';
import '../Utils/ip_address.dart';
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
      home: const MenuListPage(user: null, tabIndex: null, itemCategoryList: null, menuItemList: null, streamControllers: null),
    );
  }
}

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key, this.user, this.tabIndex, this.itemCategoryList, this.menuItemList, this.streamControllers});

  final User? user;
  final int? tabIndex;
  final List<MenuItem>? itemCategoryList;
  final List<MenuItem>? menuItemList;
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
  int selectedTabIndex = 1000;
  List<MenuItem>? itemCategoryList;
  List<MenuItem>? menuItemList;

  User? getUser() {
    return widget.user;
  }

  List<MenuItem>? getItemCategoryStoredList() {
    return widget.itemCategoryList;
  }

  List<MenuItem>? getMenuItemStoredList() {
    return widget.menuItemList;
  }

  int? getTabIndex() {
    return widget.tabIndex;
  }

  onGoBack(dynamic value) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    if (menuItemList == null || menuItemList!.isEmpty) {
      menuItemList = getMenuItemStoredList();
    }
    if (itemCategoryList == null || itemCategoryList!.isEmpty) {
      itemCategoryList = getItemCategoryStoredList();
    }
    if (selectedTabIndex == 1000) {
      selectedTabIndex = widget.tabIndex!;
    }

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
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
        return false;
      },
      // child: FutureBuilder<List<MenuItem>>(
      //   future: getItemCategoryList(),
      //   builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
      //     if (snapshot.hasData) {
      child: DefaultTabController(
        length: 18,
        initialIndex: selectedTabIndex,
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
                    child: (itemCategoryList == null || itemCategoryList!.isEmpty) ? FutureBuilder<List<MenuItem>>(
                        future: getItemCategoryList(),
                        builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
                          if (snapshot.hasData) {
                            itemCategoryList = snapshot.data;
                            return TabBar(
                              isScrollable: true,
                              onTap: (value) {
                                setState(() {
                                  selectedTabIndex = value;
                                });
                              },
                              tabs: buildItemCategoryList(snapshot.data),
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
                            );
                          } else {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              return Center(
                                child: LoadingAnimationWidget.horizontalRotatingDots(
                                  color: Colors.black,
                                  size: 25,
                                ),
                              );
                            }
                          }
                        }
                    ) : TabBar(
                      isScrollable: true,
                      onTap: (value) {
                        setState(() {
                          selectedTabIndex = value;
                        });
                      },
                      tabs: buildItemCategoryList(itemCategoryList),
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
                    // child: TabBar(
                    //   isScrollable: true,
                    //
                    //   tabs: [
                    //   ],
                    //   indicator: BoxDecoration(
                    //       color: Colors.deepPurple[300]
                    //   ),
                    //   indicatorSize: TabBarIndicatorSize.tab,
                    //   overlayColor: MaterialStateProperty.resolveWith<Color?>(
                    //         (Set<MaterialState> states) {
                    //       if (states.contains(MaterialState.hovered)) {
                    //         return Colors.grey.shade200;
                    //       }
                    //       return null;
                    //     },
                    //   ),
                    //   unselectedLabelColor: Colors.grey.shade700,
                    //   labelColor: Colors.white,
                    // );
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
            child: (menuItemList == null || menuItemList!.isEmpty) ? FutureBuilder<List<MenuItem>>(
              future: getMenuItemList(),
              builder: (BuildContext context, AsyncSnapshot<List<MenuItem>> snapshot) {
                if (snapshot.hasData) {
                  menuItemList = snapshot.data;
                  return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      child: TabBarView(
                        children: buildTabBarView(snapshot.data, currentUser, selectedTabIndex),
                      )
                  );

                } else {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return Center(
                      child: LoadingAnimationWidget.threeRotatingDots(
                        color: Colors.black,
                        size: 50,
                      ),
                    );
                  }
                }
              }
            ) : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: TabBarView(
                  children: buildTabBarView(menuItemList, currentUser, selectedTabIndex),
                )
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreateMenuItemPage(user: currentUser, tabIndex: selectedTabIndex, menuItemList: menuItemList, itemCategoryList: itemCategoryList, streamControllers: widget.streamControllers))
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
      ),
    );
  }

  List<Widget> buildTabBarView(List<MenuItem>? menuItemList, User currentUser, int currentTabIndex) {
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
                            height: 198.0,
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
                                        const SizedBox(height: 10.0,),
                                        // const Spacer(),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.shopping_cart_outlined,
                                              size: 23.0,
                                              color: Colors.grey.shade700,
                                            ),
                                            const SizedBox(width: 3.0,),
                                            Text(
                                              menuItemList[j].total_num_ordered.toString(),
                                              style: TextStyle(
                                                fontSize: 17.0,
                                                fontFamily: "Itim",
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
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
                                            // const Spacer(),
                                            // Icon(
                                            //   Icons.shopping_cart_outlined,
                                            //   size: 23.0,
                                            //   color: Colors.grey.shade700,
                                            // ),
                                            // const SizedBox(width: 3.0,),
                                            // Text(
                                            //   menuItemList[j].total_num_ordered.toString(),
                                            //   style: TextStyle(
                                            //     fontSize: 17.0,
                                            //     fontFamily: "Itim",
                                            //     color: Colors.grey.shade700,
                                            //   ),
                                            // ),
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
                                                showUpdateIsOutOfStockConfirmationDialog(menuItemList[j], currentUser);
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
                                                Route route = MaterialPageRoute(builder: (context) =>UpdateMenuItemPage(user: currentUser, menuItem: menuItemList[j], tabIndex: selectedTabIndex, streamControllers: widget.streamControllers));
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
                                                showDeleteConfirmationDialog(menuItemList[j], currentUser, currentTabIndex);
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
                                        child: menuItemList[j].image == "" ? Image.asset('images/menuItem.png', width: 100, height: 100,) : buildImage(menuItemList[j])
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

  Widget buildImage(MenuItem currentMenuItem) {
    String base64Image = currentMenuItem.image;
    Widget image;
    if (!currentMenuItem.hasImageStored) {
      if (base64Image == "") {
        image = Image.asset('images/menuItem.png', width: 100, height: 100,);
        print("nothing in base64");
      } else {
        image = Image.memory(base64Decode(base64Image), width: 100, height: 100,);
        currentMenuItem.imageStored = image!;
        currentMenuItem.hasImageStored = true;
      }
    } else {
      image = currentMenuItem.imageStored;
    }
    return image;
  }

  List<Widget> buildItemCategoryList(List<MenuItem>? listItemCategory) {
    List<Widget> tabs = [];
    for (int i = 0; i < listItemCategory!.length; i++) {
      tabs.add(
        Text(
          listItemCategory[i].category_name,
          // style: TextStyle(
          //   fontWeight: FontWeight.bold,
          // ),
        ),
      );
    }
    return tabs;
  }

  Future<List<MenuItem>> getItemCategoryList() async {
    try {
      final response = await http.get(
        Uri.parse('${IpAddress.ip_addr}/menu/request_item_category_list_with_no_image'),
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
        Uri.parse('${IpAddress.ip_addr}/menu/request_menu_item_list'),
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
        Uri.parse('${IpAddress.ip_addr}/menu/delete_menu_item/${currentMenuItem.id}/'),
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

  Future<(String, bool)> _submitIsOutOfStockStatusMenuItem(MenuItem currentMenuItem, User currentUser) async {
    bool outOfStockStatusUpdate = !currentMenuItem.isOutOfStock;
    var (success, err_code) = await updateIsOutOfStockStatusMenuItem(currentMenuItem, outOfStockStatusUpdate, currentUser);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to update IsOutOfStock status of the menu item (${currentMenuItem.name}) data.");
      }
      return (err_code, success);
    }
    return (err_code, success);
  }


  Future<(bool, String)> updateIsOutOfStockStatusMenuItem(MenuItem currentMenuItem, bool outOfStockStatusUpdate, User currentUser) async {
    try {
      final response = await http.put(
        Uri.parse('${IpAddress.ip_addr}/menu/update_is_out_of_stock/${currentMenuItem.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'isOutOfStock': outOfStockStatusUpdate,
          'user_updated_id': currentUser.uid,
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

  void showUpdateIsOutOfStockConfirmationDialog(MenuItem currentMenuItem, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: !currentMenuItem.isOutOfStock ? Text('Are you sure you want to disable this menu item (${currentMenuItem.name})?') : Text('Are you sure you want to enable this menu item (${currentMenuItem.name})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (err_code, updateIsOutOfStockStatusAsync) = await _submitIsOutOfStockStatusMenuItem(currentMenuItem, currentUser);
                setState(() {
                  Navigator.of(context).pop();
                  if (err_code == ErrorCodes.UPDATE_ISOUTOFSTOCK_STATUS_FAIL_BACKEND) {
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
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
                          title: const Text('Connection Error', style: TextStyle(fontWeight: FontWeight.bold,)),
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
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: !currentMenuItem.isOutOfStock ? const Text('Disabled Successfully', style: TextStyle(fontWeight: FontWeight.bold,)) : const Text('Enabled Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: !currentMenuItem.isOutOfStock ? Text('The Menu Item (${currentMenuItem.name}) has been disabled.') : Text('The Menu Item (${currentMenuItem.name}) has been enabled.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                setState(() {
                                  currentMenuItem.isOutOfStock = !currentMenuItem.isOutOfStock;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialog(MenuItem currentMenuItem, User currentUser, int currentTabIndex) {
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
                  Navigator.of(context).pop();
                  if (err_code == ErrorCodes.DELETE_MENU_ITEM_FAIL_BACKEND) {
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
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
                          title: const Text('Connection Error', style: TextStyle(fontWeight: FontWeight.bold,)),
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
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Deleted Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: Text('The Menu Item (${currentMenuItem.name}) has been deleted from the menu list'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                setState(() {
                                  menuItemList = [];
                                  itemCategoryList = [];
                                });
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MenuListPage(user: currentUser, tabIndex: currentTabIndex, menuItemList: menuItemList, itemCategoryList: itemCategoryList, streamControllers: widget.streamControllers)),
                                );
                              },
                            ),
                          ],
                        ),
                    );
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),

            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}