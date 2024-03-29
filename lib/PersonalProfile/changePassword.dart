import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/PersonalProfile/viewPersonalProfile.dart';
import '../Entity/User.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import '../Security/Encryptor.dart';
import '../Utils/ip_address.dart';

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
      home: const ChangePasswordPage(user: null, streamControllers: null),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool profileUpdated = false;
  bool secureOldPasswordText = true;
  bool secureNewPasswordText = true;
  bool secureConfirmPasswordText = true;
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  void _toggleOldPasswordView() {
    setState(() {
      secureOldPasswordText = !secureOldPasswordText;
    });
  }

  void _toggleNewPasswordView() {
    setState(() {
      secureNewPasswordText = !secureNewPasswordText;
    });
  }

  void _toggleConfirmPasswordView() {
    setState(() {
      secureConfirmPasswordText = !secureConfirmPasswordText;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void showConfirmationDialog(TextEditingController oldPasswordController, TextEditingController newPasswordController, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure you want to update the password?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Perform save logic here
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                if (_formKey.currentState!.validate()) {
                  var (err_code, currentUserUpdated) = await _submitUpdatePasswordDetails(oldPasswordController, newPasswordController, currentUser);
                  setState(() {
                    Navigator.of(context).pop();
                    if (err_code == ErrorCodes.PASSWORD_UPDATE_FAIL_BACKEND) {
                      showDialog(
                        context: context, builder: (BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: Text(
                                'An Error occurred while trying to update the password.\n\nError Code: $err_code'),
                            actions: <Widget>[
                              TextButton(onPressed: () =>
                                  Navigator.pop(context, 'Ok'),
                                  child: const Text('Ok')),
                            ],
                          ),
                      );
                    } else if (err_code ==
                        ErrorCodes.PASSWORD_UPDATE_FAIL_API_CONNECTION) {
                      showDialog(
                        context: context, builder: (BuildContext context) =>
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
                    } else if (err_code == ErrorCodes.OLD_PASSWORD_DOES_NOT_MATCH_DIALOG) {
                      showDialog(
                        context: context, builder: (BuildContext context) =>
                          AlertDialog(
                            title: const Text('Old Password Incorrect.', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: Text(
                                'The old password entered is not matched.\n\nError Code: $err_code'),
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
                            title: const Text('Update Password Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: const Text('You can try to login using the new password.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUserUpdated, streamControllers: widget.streamControllers)),
                                  );
                                },
                              ),
                            ],
                          ),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
                      });
                    }
                  });
                }
                // saveAnnouncement(title, text);
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

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    print(currentUser?.name);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers),
      appBar: AppsBarState().buildAppBarDetails(context, 'Change Password', currentUser, widget.streamControllers),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                          children: [
                            const SizedBox(height: 13,),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Old Password', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                    // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child:
                              TextFormField(
                                obscureText: secureOldPasswordText,
                                controller: oldPasswordController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your old password';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  suffix: InkWell(
                                    onTap: _toggleOldPasswordView,
                                    child: Icon(
                                      secureOldPasswordText ? Icons.visibility : Icons.visibility_off,
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
                                      Text('New Password', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                      // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                    ]
                                )
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child:
                              TextFormField(
                                obscureText: secureNewPasswordText,
                                controller: newPasswordController,
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
                                    onTap: _toggleNewPasswordView,
                                    child: Icon(
                                      secureNewPasswordText ? Icons.visibility : Icons.visibility_off,
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
                                controller: confirmNewPasswordController,
                                validator: (value) {
                                  if (value != newPasswordController.text) {
                                    return 'Passwords do not match with new passwords!';
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
                            const SizedBox(height: 13,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                              child: Container(
                                padding: const EdgeInsets.only(top: 3,left: 3),
                                child: MaterialButton(
                                  minWidth: double.infinity,
                                  height:50,
                                  onPressed: (){
                                    if (_formKey.currentState!.validate()) {
                                      showConfirmationDialog(oldPasswordController, newPasswordController, currentUser);
                                      // if (image != null) {
                                      //   showConfirmationDialog();
                                      // } else {
                                      //   // showUploadImageDialog();
                                      // }
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
                          ]
                      ),
                    ),
                  ),
                )
              )
            )
        ),
      // bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context, widget.streamControllers),

    );
  }

  Future<(String, User)> _submitUpdatePasswordDetails(TextEditingController oldPasswordController, TextEditingController newPasswordController, User currentUser) async {
    String oldPassword = oldPasswordController.text;
    String newPassword = newPasswordController.text;
    if (kDebugMode) {
      print('Email: $oldPassword');
      print('Password: $newPassword');
    }
    String encOpw = Encryptor().encryptPassword(oldPassword);
    String encNpw = Encryptor().encryptPassword(newPassword);
    var (thisUser, err_code) = await updateProfilePassword(encOpw, encNpw, currentUser);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to update password.");
      }
      return (err_code, currentUser);
    }
    currentUser = thisUser;
    return (err_code, currentUser);
  }

  Future<(User, String)> updateProfilePassword(String encOpw, String encNpw, User currentUser) async {
    try {
      final response = await http.put(
        Uri.parse('${IpAddress.ip_addr}/editProfile/update_user_password/${currentUser.uid}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'encOpw': encOpw,
          'encNpw': encNpw,
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        var jsonResp = jsonDecode(response.body);
        var error = jsonResp['error'];
        if (error == "Old Password do not match") {
          if (kDebugMode) {
            print(error);
          }
          return (User(uid: -1,
              image: '',
              name: '',
              ic: '',
              is_staff: false,
              is_active: false,
              email: '',
              address: '',
              gender: '',
              staff_type: '',
              dob: DateTime.now(),
              phone: '',
              points: 0,
              date_created: DateTime.now(),
              date_deactivated: DateTime.now(),
          ), (ErrorCodes.OLD_PASSWORD_DOES_NOT_MATCH_DIALOG));
        } else {
          if (kDebugMode) {
            print(error);
          }
          return (User(uid: -1,
              image: '',
              name: '',
              ic: '',
              is_staff: false,
              is_active: false,
              email: '',
              address: '',
              gender: '',
              staff_type: '',
              dob: DateTime.now(),
              phone: '',
              points: 0,
              date_created: DateTime.now(),
              date_deactivated: DateTime.now(),
          ), (ErrorCodes.PASSWORD_UPDATE_FAIL_BACKEND));
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.PASSWORD_UPDATE_FAIL_API_CONNECTION));
    }
  }
}