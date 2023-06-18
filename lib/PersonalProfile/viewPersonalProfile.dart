import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:keninacafe/Auth/login.dart';
import 'package:keninacafe/PersonalProfile/changePassword.dart';
import 'package:keninacafe/PersonalProfile/editPersonalProfile.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
import '../Entity/User.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ViewPersonalProfilePage(user: null,),
    );
  }
}

class ViewPersonalProfilePage extends StatefulWidget {
  const ViewPersonalProfilePage({super.key, this.user});

  final User? user;

  @override
  State<ViewPersonalProfilePage> createState() => _ViewPersonalProfilePageState();
}

class _ViewPersonalProfilePageState extends State<ViewPersonalProfilePage> {
  var iconColor = true ? Colors.blue : Colors.red;

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
      drawer: AppsBarState().buildDrawer(context),
      appBar: AppsBarState().buildAppBar(context, 'Profile', currentUser!),
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
                            child: Image.memory(base64Decode(widget.user!.image))),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child: const Icon(
                            LineAwesomeIcons.alternate_pencil,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(currentUser.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  Text(currentUser.email, style: const TextStyle(fontSize: 15),),
                  const SizedBox(height: 20),

                  /// -- BUTTON
                  SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () => {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => EditPersonalProfilePage(user: currentUser))
                        ),
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, side: BorderSide.none, shape: const StadiumBorder()),
                      child: const Text('Edit Profile', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Divider(),

                  GestureDetector(
                    onTap: () {
                      // Handle button press
                      // Put your logic here
                      // For example, call a function or navigate to another screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePasswordPage(user: currentUser),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: iconColor.withOpacity(0.1),
                        ),
                        child: Icon(LineAwesomeIcons.key, color: iconColor),
                      ),
                      title: const Text('Change Password', style: TextStyle(color: Colors.black, fontSize: 15)),
                      trailing: true
                          ? Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          child: const Column(
                            children: [
                              Icon(LineAwesomeIcons.angle_right, size: 18.0, color: Colors.grey)
                            ],
                          )
                      )
                          : null,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  GestureDetector(
                    onTap: () {
                      // Handle button press
                      // Put your logic here
                      // For example, call a function or navigate to another screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: iconColor.withOpacity(0.1),
                        ),
                        child: Icon(LineAwesomeIcons.alternate_sign_out, color: iconColor),
                      ),
                      title: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 15)),
                      trailing: true
                          ? Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          child: const Column(
                            children: [
                              Icon(LineAwesomeIcons.angle_right, size: 18.0, color: Colors.grey)
                            ],
                          )
                      )
                          : null,
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }
}