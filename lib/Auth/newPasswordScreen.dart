import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/Auth/passwordResetScreen.dart';
import 'package:keninacafe/Auth/login.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Security/Encryptor.dart';
import '../Utils/error_codes.dart';
import '../main.dart';
import 'otpEnterScreen.dart';

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
      home: const NewPasswordScreenPage(uid: null, remainingTime: null),
    );
  }
}

class NewPasswordScreenPage extends StatefulWidget {
  const NewPasswordScreenPage({super.key, this.uid, this.remainingTime});

  final String? uid;
  final int? remainingTime;

  @override
  State<NewPasswordScreenPage> createState() => _NewPasswordScreenPageState();
}

class _NewPasswordScreenPageState extends State<NewPasswordScreenPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool securePasswordText = true;
  bool secureConfirmPasswordText = true;
  bool updateForgotPassword = false;

  late Timer _timer;
  int _timeoutInSeconds = 0;
  int _remainingTime = 0;

  String? getUidEncode() {
    return widget.uid;
  }

  int? getRemainingTime() {
    return widget.remainingTime;
  }

  @override
  void initState() {
    super.initState();
    _timeoutInSeconds = getRemainingTime()!;
    _remainingTime = getRemainingTime()!;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime != null) {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer.cancel(); // Stop the timer when it reaches 0
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PasswordResetScreenPage()),
            );
          }
        }
      });
    });
  }

  void _resetTimer() {
    _timer.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  void _togglePasswordView() {
    setState(() {
      securePasswordText = !securePasswordText;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      secureConfirmPasswordText = !secureConfirmPasswordText;
    });
  }

  @override
  Widget build(BuildContext context) {

    String? uidEncode = getUidEncode();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Set New Password',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => {
            Navigator.of(context).pop(),
          },
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
        ),
        backgroundColor: Colors.deepPurple.shade200,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Time remaining: ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15.0,),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    child: Row(
                        children: [
                          Text('Password', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                          // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                        ]
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child:
                  TextFormField(
                    obscureText: securePasswordText,
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      final passwordRegex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#&*~]).{8,}$');
                      if (!passwordRegex.hasMatch(value)) {
                        return 'Please enter a valid password with at least:\nOne capital letter\nOne small letter\nOne number\nOne symbol from !, @, #, &, * or ~';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      suffix: InkWell(
                        onTap: _togglePasswordView,
                        child: Icon(
                          securePasswordText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: BorderSide(
                          color: Colors.grey.shade500,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: BorderSide(
                          color: Colors.grey.shade500,
                          width: 2.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      // hintText: 'Please enter your password',
                    ),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gabarito",
                    ),
                  ),
                ),
                const SizedBox(height: 13,),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    child: Row(
                        children: [
                          Text('Confirm Password', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                          // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                        ]
                    )
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: TextFormField(
                    obscureText: secureConfirmPasswordText,
                    controller: confirmPasswordController,
                    validator: (value) {
                      if (value != passwordController.text) {
                        return 'Passwords do not match with the new password!';
                      } else if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      return null;
                    },
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gabarito",
                    ),
                    decoration: InputDecoration(
                      suffix: InkWell(
                        onTap: _toggleConfirmPasswordView,
                        child: Icon(
                          secureConfirmPasswordText ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: BorderSide(
                          color: Colors.grey.shade500,
                          width: 2.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: BorderSide(
                          color: Colors.grey.shade500,
                          width: 2.0,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20), // Set border radius here
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      // hintText: 'Please enter the password again',
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  child: Container(
                    padding: const EdgeInsets.only(top: 3,left: 3),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height:50,
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          showConfirmationCreateDialog(uidEncode!);
                        }
                      },
                      color: Colors.lightBlueAccent.shade400,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: const Text("Update",style:
                      TextStyle(
                        fontWeight: FontWeight.bold,fontSize: 16, color: Colors.white,
                      ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  void showConfirmationCreateDialog(String uidEncode) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure to update your password?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (updateForgotPasswordAsync, err_code) = await _submitForgotPassword(uidEncode);
                setState(() {
                  updateForgotPassword = updateForgotPasswordAsync;
                  if (!updateForgotPassword) {
                    if (err_code == ErrorCodes.FORGOT_PASSWORD_INVALID_USER_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error'),
                            content: Text('An Error occurred while trying to update the password.\n\nError Code: $err_code'),
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
                    _timer.cancel();
                    Navigator.of(context).pop();
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Password Updated Successful'),
                          content: const Text('Try to login now !'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LoginPage()),
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

  Future<(bool, String)> _submitForgotPassword(String uidEncode) async {
    String newPassword = passwordController.text;
    if (kDebugMode) {
      print('Password: $newPassword');
    }
    String encNpw = Encryptor().encryptPassword(newPassword);
    var (success, err_code) = await changeForgotPassword(uidEncode, encNpw);
    if (!success) {
      if (kDebugMode) {
        print("Failed to change password.");
      }
      return (success, err_code);
    }
    return (success, err_code);
  }

  Future<(bool, String)> changeForgotPassword(String uidEncode, String encNpw) async {
    try {
      final response = await http.post(
        // Uri.parse('http://10.0.2.2:8000/editProfile/update_user_password/${currentUser.uid}/'),
        Uri.parse('http://10.0.2.2:8000/users/password_reset_confirm'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'uidEncode': uidEncode,
          'encNpw': encNpw,
        }),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Invalid User.');
        }
        return (false, (ErrorCodes.FORGOT_PASSWORD_INVALID_USER_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.FORGOT_PASSWORD_FAIL_API_CONNECTION));
    }
  }
}
