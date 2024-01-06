import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/StaffManagement/staffDashboard.dart';
import 'package:keninacafe/StaffManagement/updateStaff.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/User.dart';
import '../Order/manageOrder.dart';
import 'createStaff.dart';

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
      home: const StaffListPage(user: null, streamControllers: null),
    );
  }
}

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  String title = '';
  String text = '';
  final _formKey = GlobalKey<FormState>();
  final addressController = TextEditingController();
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
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

  void showViewAddressDialog(String address) {
    addressController.text = address;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                child: Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 23.5,
                    fontFamily: "Itim",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      addressController.text = "";
                      Navigator.of(context).pop();
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.grey.shade300,
                      // border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    // padding: const EdgeInsets.all(1),
                    child: Icon(
                      Icons.close_outlined,
                      size: 25.0,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ]
          ),
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: addressController,
                  maxLines: null,
                  enabled: false,
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    errorBorder: OutlineInputBorder( // Border style for error state
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.red,
                        width: 2.0,),
                    ),
                    // hintText: 'Please enter your email',
                    // hintStyle: TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showConfirmationDeleteDialog(User staffData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to delete this staff (${staffData.name}) ?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (err_code, currentStaffDeleted) = await _submitDeleteStaffDetails(staffData);
                setState(() {
                  if (err_code == ErrorCodes.DELETE_STAFF_FAIL_BACKEND) {
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Error'),
                          content: Text('An Error occurred while trying to delete this staff (${staffData.name}).\n\nError Code: $err_code'),
                          actions: <Widget>[
                            TextButton(onPressed: () =>
                                Navigator.pop(context, 'Ok'),
                                child: const Text('Ok')),
                          ],
                        ),
                    );
                  } else if (err_code == ErrorCodes.DELETE_STAFF_FAIL_API_CONNECTION){
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
                          title: Text('Delete Staff (${staffData.name}) Successful'),
                          // content: const Text('The Leave Form Data can be viewed in the LA status page.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return WillPopScope(
      onWillPop: () async {
        // Navigate to the desired page when the Android back button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StaffDashboardPage(user: currentUser, streamControllers: widget.streamControllers)),
        );

        // Prevent the default back button behavior
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers),
        appBar: AppsBarState().buildStaffListAppBarDetails(context, 'Staff List', currentUser, widget.streamControllers),
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 15,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: FutureBuilder<List<User>>(
                      future: getStaffList(),
                      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: buildStaffCards(snapshot.data, currentUser),
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
                    )
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CreateStaffPage(user: currentUser, streamControllers: widget.streamControllers))
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
  }

  List<Widget> buildStaffCards(List<User>? listStaff, User? currentUser) {
    List<Widget> cards = [];
    for (User a in listStaff!) {
      if (a.staff_type == "Restaurant Owner") {

      }
      if (a.uid != currentUser?.uid && a.is_active == true) {
        cards.add(
          Card(
            child: Container(
              // height: 220,
              constraints: const BoxConstraints(
                maxHeight: double.infinity,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey, width: 4.0),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  a.name,
                                  style: TextStyle(
                                    fontSize: 18.0,
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
                          Row(
                            children: [
                              Text(
                                "IC : ",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                a.ic,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2.0,),
                          Row(
                            children: [
                              Text(
                                "Email : ",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                a.email,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2.0,),
                          Row(
                            children: [
                              Text(
                                "Contact : ",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                a.phone,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2.0,),
                          // Row(
                          //   children: [
                          //     Text(
                          //       a.address,
                          //       style: TextStyle(
                          //         fontSize: 15.0,
                          //         color: Colors.grey.shade700,
                          //         fontFamily: "Oswald",
                          //         // fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 2.0,),
                          // Row(
                          //   children: [
                          //     Text(
                          //       a.gender,
                          //       style: TextStyle(
                          //         fontSize: 15.0,
                          //         color: Colors.grey.shade700,
                          //         fontFamily: "Oswald",
                          //         // fontWeight: FontWeight.bold,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(height: 2.0,),
                          Row(
                            children: [
                              Text(
                                "DOB : ",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                a.dob.toString().substring(0,10),
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0,),
                          // const Spacer(),
                          Row(
                            children: [
                              Text(
                                '${a.staff_type} ( ${a.gender} )',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: Colors.grey.shade900,
                                  fontFamily: "BreeSerif",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5.0,),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 13, 5),
                    child: Column(
                      children: [
                        const SizedBox(height: 5.0,),
                        if (currentUser?.staff_type == "Restaurant Manager" && a.staff_type != "Restaurant Owner" || currentUser?.staff_type == "Restaurant Owner")
                          Row(
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                                  // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                  onPressed: () async {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => UpdateStaffPage(staff: a, user: currentUser, streamControllers: widget.streamControllers))
                                    );
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
                                    showConfirmationDeleteDialog(a);
                                  },
                                  child: Icon(Icons.delete, color: Colors.grey.shade800),
                                ),
                              ),
                              const SizedBox(width: 5.0,),
                            ],
                          ),
                        const SizedBox(height: 18.0,),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: a.image == "" ? Image.asset('images/menuItem.png', width: 100, height: 100,) : Image.memory(base64Decode(a.image), width: 100, height: 100,)
                        ),
                        const SizedBox(height: 10.0,),
                        // const Spacer(),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                width: 100.0,
                                height: 30.0,
                                padding: const EdgeInsets.only(top: 3),
                                child: MaterialButton(
                                  minWidth: double.infinity,
                                  height: 20,
                                  onPressed: () {
                                    showViewAddressDialog(a.address);
                                  },
                                  color: Colors.grey.shade300,
                                  child: Text(
                                    "Address",
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
                        const SizedBox(height: 5.0,),
                      ],
                    )
                  ),
                ],
              ),
            ),
          ),
        );
        cards.add(const SizedBox(height: 15,),);
      }
    }
    cards.add(const SizedBox(height: 20,));
    return cards;
  }

  Future<List<User>> getStaffList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/users/request_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.getStaffDataList(jwtToken));
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Staff exist in system.');
        }
        return ([
          User(uid: -1,
              image: '',
              is_staff: false,
              is_active: false,
              staff_type: '',
              name: '',
              ic: '',
              address: '',
              email: '',
              gender: '',
              dob: DateTime.now(),
              phone: '',
              points: 0,
              date_created: DateTime.now(),
              date_deactivated: DateTime.now()
          )
        ]);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return ([
        User(uid: -1,
            image: '',
            is_staff: false,
            is_active: false,
            staff_type: '',
            name: '',
            ic: '',
            address: '',
            email: '',
            gender: '',
            dob: DateTime.now(),
            phone: '',
            points: 0,
            date_created: DateTime.now(),
            date_deactivated: DateTime.now()
        )
      ]);
    }
  }

  Future<(String, User)> _submitDeleteStaffDetails(User currentUser) async {
    var (thisUser, err_code) = await deleteStaffProfile(currentUser);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to delete User data.");
      }
      return (err_code, currentUser);
    }
    currentUser = thisUser;
    return (err_code, currentUser);
  }

  Future<(User, String)> deleteStaffProfile(User staffData) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/users/delete_user_profile/${staffData.uid}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'is_active': false,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No User found.');
        }
        return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.DELETE_STAFF_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.DELETE_STAFF_FAIL_API_CONNECTION));
    }
    //   } else {
    //     if (kDebugMode) {
    //       print('Failed to Approve Leave Application.');
    //     }
    //     return (false, ErrorCodes.PERSONAL_PROFILE_UPDATE_FAIL_BACKEND);
    //   }
    // } on Exception catch (e) {
    //   if (kDebugMode) {
    //     print('API Connection Error. $e');
    //   }
    //   return (false, ErrorCodes.PERSONAL_PROFILE_UPDATE_FAIL_API_CONNECTION);
    // }
  }
}