import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/Attendance/manageRestaurantWorkerAttendance.dart';
import 'package:keninacafe/Entity/User.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import 'package:keninacafe/Announcement/createAnnouncement.dart';
import 'package:keninacafe/LeaveApplication/applyLeaveForm.dart';
import 'package:keninacafe/LeaveApplication/viewLeaveApplicationStatus.dart';
import 'package:keninacafe/LeaveApplication/applyViewLeaveApplication.dart';
import 'package:keninacafe/LeaveApplication/manageLeaveApplicationRequest.dart';
import 'package:keninacafe/PersonalProfile/viewPersonalProfile.dart';
import 'package:keninacafe/StaffManagement/createStaff.dart';
import 'package:keninacafe/StaffManagement/staffDashboard.dart';
import 'package:keninacafe/Attendance/attendanceDashboard.dart';
import 'package:keninacafe/Attendance/manageAttendanceRequest.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../Security/Encryptor.dart';
import '../StaffManagement/staffList.dart';
import '../home.dart';

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
  bool userFound = false;
  bool submittedOnce = false;
  bool securePasswordText = true;
  late SharedPreferences prefs;
  late User  currentUser;

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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return MaterialApp(
      title: 'Login Page',
      home: Scaffold(
          body: ListView (
            children: [
              Image.asset('images/KE_Nina_Cafe_logo.jpg'),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                child: Text('Welcome Back!', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                child:
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                child:
                  TextField(
                    obscureText: securePasswordText,
                    controller: passwordController,
                    enableSuggestions: false,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      suffix: InkWell(
                        onTap: _togglePasswordView,
                        child: const Icon( Icons.visibility),
                      ),
                      hintText: 'Password',
                    ),
                  )
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                child:
                  FilledButton(onPressed: () async {
                    var (userFoundAsync, err_code) = await _submitLoginDetails(emailController, passwordController);
                    setState(() {
                      userFound = userFoundAsync;
                      submittedOnce = true;
                      if (!userFound) {
                        passwordController.text = '';
                        if (err_code == ErrorCodes.LOGIN_FAIL_NO_USER) {
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
                              title: const Text('Login Successful'),
                              content: Text(
                                  'Welcome back, ${emailController.text}!'),
                              actions: <Widget>[
                                TextButton(onPressed: () =>
                                    Navigator.pop(context, 'Ok'),
                                    child: const Text('Ok')),
                              ],
                            ),
                        );
                        Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => HomePage(user: currentUser))
                        );
                      }
                    });
                  }, child: const Text('Login', textAlign: TextAlign.center)
                  )
              ),
              pleaseLogin()
            ]
          )
      )
    );
  }

  // Returns true if match user and password, else returns false.
  Future<(bool, String)> _submitLoginDetails(TextEditingController emailController, TextEditingController passwordController) async {
    String email = emailController.text;
    String password = passwordController.text;
    if (kDebugMode) {
      print('Email: $email');
      print('Password: $password');
    }
    String enc_pw = Encryptor().encryptPassword(password);
    var (thisUser, err_code) = await createUser(email, enc_pw);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to retrieve User data.");
      }
      return (false, err_code);
    }
    currentUser = thisUser;
    return (true, err_code);
  }

  Future<(User, String)> createUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/users/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
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
        return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0), (ErrorCodes.LOGIN_FAIL_NO_USER));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, ), (ErrorCodes.LOGIN_FAIL_API_CONNECTION));
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
