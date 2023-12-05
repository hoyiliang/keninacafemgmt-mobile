import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/Entity/User.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Order/manageOrder.dart';
import '../Security/Encryptor.dart';
import '../StaffManagement/staffDashboard.dart';
import '../Utils/WebSockPaths.dart';
import '../Dashboard.dart';

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
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool userFound = false;
  bool submittedOnce = false;
  bool securePasswordText = true;
  late SharedPreferences prefs;
  late User currentUser;

  @override
  void initState() {
    super.initState();

  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void _togglePasswordView() {
    setState(() {
      securePasswordText = !securePasswordText;
    });
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    return MaterialApp(
      title: 'Login Page',
      home: Scaffold(
          body: ListView (
            children: [
              Image.asset('images/KE_Nina_Cafe_logo.jpg'),
              // const SizedBox(height: 20.0,),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Text('KE Nina Café Management', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: const TextStyle(color: Colors.black), // Set label color to white
                          prefixIcon: const Icon(Icons.email, color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black, width: 4.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black, width: 4.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          errorBorder: OutlineInputBorder( // Border style for error state
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.red, width: 4.0,),
                          ),
                          // hintText: 'Please enter your email',
                          // hintStyle: TextStyle(color: Colors.white),
                          contentPadding: const EdgeInsets.symmetric(vertical: 25),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: TextFormField(
                        obscureText: securePasswordText,
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Colors.black),
                          prefixIcon: const Icon(Icons.lock, color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black, width: 4.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black, width: 4.0),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          errorBorder: OutlineInputBorder( // Border style for error state
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: const BorderSide(color: Colors.red, width: 4.0,),
                          ),
                          suffix: InkWell(
                            onTap: _togglePasswordView,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Icon(securePasswordText ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          // hintText: 'Please enter your password',
                          // hintStyle: const TextStyle(color: Colors.white),
                          contentPadding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),
                    // const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(25.0, 5.0, 0, 0),
                        child: TextButton(
                          onPressed: () {
                            // Handle forgot password button press
                          },
                          child: Text(
                            'Forgot Password ?',
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.transparent,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.blue.shade900, offset: Offset(0, -4))],
                              decorationThickness: 4,
                              decorationColor: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(seconds: 1),
                      opacity: 1.0,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var (userFoundAsync, currentUser, err_code) = await _submitLoginDetails(emailController, passwordController);
                            setState(() {
                              userFound = userFoundAsync;
                              print(userFound);
                              if (!userFound) {
                                passwordController.text = '';
                                if (err_code == ErrorCodes.LOGIN_FAIL_NO_USER) {
                                  showDialog(context: context, builder: (
                                      BuildContext context) =>
                                      AlertDialog(
                                        title: const Text('User Not Found'),
                                        content: Text(
                                            'Please sign up first before login.\n\nError Code: $err_code'),
                                        actions: <Widget>[
                                          TextButton(onPressed: () =>
                                              Navigator.pop(context, 'Ok'),
                                              child: const Text('Ok')),
                                        ],
                                      ),
                                  );
                                } else if (err_code == ErrorCodes.LOGIN_FAIL_PASSWORD_INCORRECT) {
                                  showDialog(context: context, builder: (
                                      BuildContext context) =>
                                      AlertDialog(
                                        title: const Text('Details Mismatch'),
                                        content: Text(
                                            'Wrong combination of email and password. Please check your details.\n\nError Code: $err_code'),
                                        actions: <Widget>[
                                          TextButton(onPressed: () =>
                                              Navigator.pop(context, 'Ok'),
                                              child: const Text('Ok')),
                                        ],
                                      ),
                                  );
                                } else if (err_code == ErrorCodes.LOGIN_FAIL_USER_DEACTIVATED_DELETED ){
                                  showDialog(context: context, builder: (
                                      BuildContext context) =>
                                      AlertDialog(
                                        title: const Text('User Deactivated or Deleted'),
                                        content: Text(
                                            'User have been deactivated or deleted.\n\nError Code: $err_code'),
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
                                print('yes');
                                showDialog(context: context, builder: (
                                    BuildContext context) =>
                                    AlertDialog(
                                      title: const Text('Login Successful'),
                                      content: Text(
                                          'Happy Working Day, ${currentUser.name}!'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            final receiveOrderChannel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/${WebSockPaths.RECEIVE_NEW_ORDER}'));
                                            final receiveOrderReminderChannel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/${WebSockPaths.RECEIVE_UNPAID_ORDER_REMINDER}'));
                                            final receiveAnnouncementChannel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/${WebSockPaths.RECEIVE_ANNOUNCEMENT_UPDATES}'));
                                            final receiveAttendanceRequestChannel = WebSocketChannel.connect(Uri.parse('ws://10.0.2.2:8000/${WebSockPaths.RECEIVE_NEW_ATTENDANCE_REQUEST}'));

                                            final receiveOrderStreamController = StreamController.broadcast();
                                            receiveOrderStreamController.addStream(receiveOrderChannel.stream);
                                            final receiveOrderReminderStreamController = StreamController.broadcast();
                                            receiveOrderReminderStreamController.addStream(receiveOrderReminderChannel.stream);
                                            final receiveAnnouncementStreamController = StreamController.broadcast();
                                            receiveAnnouncementStreamController.addStream(receiveAnnouncementChannel.stream);
                                            final receiveAttendanceRequestStreamController = StreamController.broadcast();
                                            receiveAttendanceRequestStreamController.addStream(receiveAttendanceRequestChannel.stream);

                                            Map<String, StreamController> streamControllers = {
                                              'order': receiveOrderStreamController,
                                              'orderReminder': receiveOrderReminderStreamController,
                                              'announcement': receiveAnnouncementStreamController,
                                              'attendance': receiveAttendanceRequestStreamController,
                                            };

                                            if (currentUser.staff_type == "Restaurant Owner") {
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(builder: (context) => DashboardPage(user: currentUser, streamControllers: streamControllers,))
                                              );
                                            } else if (currentUser.staff_type == "Restaurant Manager") {
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(builder: (context) => StaffDashboardPage(user: currentUser, streamControllers: streamControllers,))
                                              );
                                            } else if (currentUser.staff_type == "Restaurant Worker") {
                                              Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(builder: (context) => ManageOrderPage(user: currentUser, streamControllers: streamControllers,))
                                              );
                                            }
                                          },
                                          child: const Text('Ok'),
                                        ),
                                      ],
                                    ),
                                );
                                // Navigator.of(context).pushReplacement(
                                //     MaterialPageRoute(builder: (context) => HomePage(user: currentUser, streamControllers: streamControllers,))
                                // );
                              }
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(200, 50),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ]
          )
      )
    );
  }

  Future<(bool, User, String)> _submitLoginDetails(TextEditingController emailController, TextEditingController passwordController) async {
    String email = emailController.text;
    String password = passwordController.text;
    if (kDebugMode) {
      print('Email: $email');
      print('Password: $password');
    }
    String enc_pw = Encryptor().encryptPassword(password);
    if (kDebugMode) {
      print(enc_pw);
    }
    var (thisUser, err_code) = await createUser(email, enc_pw);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to retrieve User data.");
      }
      return (false, thisUser, err_code);
    }
    return (true, thisUser, err_code);
  }

  Future<(User, String)> createUser(String email, String enc_pw) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': enc_pw,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        if (kDebugMode) {
          print('User found.');
          print('JWT Token: $jwtToken');
        }
        return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        var jsonResp = jsonDecode(response.body);
        var error = jsonResp['detail'];
        print(error);
        if (error == "User not found!") {
          print(error);
          return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.LOGIN_FAIL_NO_USER));
        }
        else if (error == "Incorrect password!") {
          print(error);
          return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.LOGIN_FAIL_PASSWORD_INCORRECT));
        }
        else if (error == "User deactivated or deleted!") {
          print(error);
          return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.LOGIN_FAIL_USER_DEACTIVATED_DELETED));
        }

        if (kDebugMode) {
          print('No User found.');
        }
        return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.LOGIN_FAIL_NO_USER));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.LOGIN_FAIL_API_CONNECTION));
    }
  }

  Widget pleaseLogin() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
      child:
        Text('Please Log In.', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold),),
    );
  }
}
