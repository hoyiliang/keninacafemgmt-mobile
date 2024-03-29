import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:keninacafe/PersonalProfile/changePassword.dart';
import 'package:keninacafe/PersonalProfile/editPersonalProfile.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
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
      home: const ViewPersonalProfilePage(user: null, streamControllers: null),
    );
  }
}

class ViewPersonalProfilePage extends StatefulWidget {
  const ViewPersonalProfilePage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<ViewPersonalProfilePage> createState() => _ViewPersonalProfilePageState();
}

class _ViewPersonalProfilePageState extends State<ViewPersonalProfilePage> {
  var iconColor = true ? Colors.blue : Colors.red;
  String base64Image = "";
  Widget? image;
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

    if (base64Image == "") {
      base64Image = widget.user!.image;
      if (base64Image == "") {
        image = Image.asset("images/profile.png");
        print("nothing in base64");
      } else {
        image = Image.memory(base64Decode(base64Image));
      }
    } else {
      image = Image.memory(base64Decode(base64Image));
    }
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
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers!),
        appBar: AppsBarState().buildAppBar(context, 'Profile', currentUser, widget.streamControllers!),
        body: SingleChildScrollView(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Align(
                child: Column(
                  children: [

                /// -- IMAGE
                    Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: image,
                          )
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 35,
                            height: 35,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                            child: currentUser.staff_type == "Restaurant Owner" ? const Icon(
                              LineAwesomeIcons.alternate_pencil,
                              color: Colors.black,
                              size: 20,
                            ) : const Icon(
                              Icons.remove_red_eye,
                              color: Colors.black,
                              size: 20.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(currentUser.name, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "Gabarito", fontSize: 25),),
                    const SizedBox(height: 2),
                    Text(currentUser.email, style: const TextStyle(fontSize: 15, fontFamily: "Gabarito"),),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: () => {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => EditPersonalProfilePage(user: currentUser, streamControllers: widget.streamControllers))
                          ),
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent.shade400, side: BorderSide.none, shape: const StadiumBorder()),
                        child: currentUser.staff_type == "Restaurant Owner" ? const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0)) : const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16.0))
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: iconColor.withOpacity(0.1),
                        ),
                        child: Icon(LineAwesomeIcons.key, color: iconColor),
                      ),
                      title: const Text('Change Password', style: TextStyle(color: Colors.black, fontFamily: "Oswald", fontSize: 17)),
                      trailing: true
                        ? SizedBox(
                        width: 35,
                        height: 35,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(2, 1, 0, 0), backgroundColor: Colors.grey.shade200),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChangePasswordPage(user: currentUser, streamControllers: widget.streamControllers),
                              ),
                            );
                          },
                          child: Icon(Icons.arrow_forward_ios_sharp, color: Colors.grey.shade700, size: 19.0,),
                        ),
                      ) : null,
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}