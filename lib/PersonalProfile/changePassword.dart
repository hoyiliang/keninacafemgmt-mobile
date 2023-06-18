import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/AppsBar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:keninacafe/PersonalProfile/viewPersonalProfile.dart';
import '../Entity/User.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import '../Entity/User.dart';
import '../Security/Encryptor.dart';

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
      home: const ChangePasswordPage(user: null,),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key, this.user});

  final User? user;

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
  bool securePasswordText = true;
  bool secureConfirmPasswordText = true;

  User? getUser() {
    return widget.user;
  }

  void _toggleOldPasswordView() {
    setState(() {
      secureOldPasswordText = !secureOldPasswordText;
    });
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
                    // profileUpdated = profileUpdatedAsync;
                    // if (!profileUpdated) {
                    if (err_code == ErrorCodes.PASSWORD_UPDATE_FAIL_BACKEND) {
                      showDialog(
                        context: context, builder: (BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error'),
                            content: Text(
                                'An Error occurred while trying to update the personal profile.\n\nError Code: $err_code'),
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
                    } else if (err_code == ErrorCodes.OLD_PASSWORD_DOES_NOT_MATCH_DIALOG) {
                      showDialog(
                        context: context, builder: (BuildContext context) =>
                          AlertDialog(
                            title: const Text('Old password does not match dialog.'),
                            actions: <Widget>[
                              TextButton(onPressed: () =>
                                  Navigator.pop(context, 'Ok'),
                                  child: const Text('Ok')),
                            ],
                          ),
                      );
                    } else {
                      // If Leave Form Data success created

                      Navigator.of(context).pop();
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Update Password Successful'),
                            // content: const Text('The Leave Form Data can be viewed in the LA status page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUserUpdated)),
                                  );
                                },
                              ),
                            ],
                          ),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
                        oldPasswordController.text = '';
                        newPasswordController.text = '';
                        confirmNewPasswordController.text = '';
                      });
                    }
                  });
                }
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

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    print(currentUser?.name);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildAppBar(context, 'Change Password', currentUser!),
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
                            TextFormField(
                              obscureText: secureOldPasswordText,
                              controller: oldPasswordController,
                              decoration: InputDecoration(
                                  label: const Text('Old Password'), prefixIcon: const Icon(LineAwesomeIcons.user),
                                  suffix: InkWell(
                                    onTap: _toggleOldPasswordView,
                                    child: const Icon( Icons.visibility),
                                  ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please fill in your full name !';
                                return null;
                              },
                            ),
                            const SizedBox(height: 13),
                            TextFormField(
                              obscureText: securePasswordText,
                              controller: newPasswordController,
                              decoration: InputDecoration(
                                  label: const Text('New Password'), prefixIcon: const Icon(LineAwesomeIcons.envelope_1),
                                  suffix: InkWell(
                                    onTap: _togglePasswordView,
                                    child: const Icon( Icons.visibility),
                                  ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please fill in your email !';

                                return null;
                              },
                            ),
                            const SizedBox(height: 13),
                            TextFormField(
                              obscureText: secureConfirmPasswordText,
                              controller: confirmNewPasswordController,
                              decoration: InputDecoration(
                                  label: const Text('Confirm New Password'), prefixIcon: const Icon(LineAwesomeIcons.phone),
                                  suffix: InkWell(
                                    onTap: _toggleConfirmPasswordView,
                                    child: const Icon( Icons.visibility),
                                  ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please fill in your phone number !';
                                } else if (newPasswordController.text != value) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 13),
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
                                  color: Colors.lightBlueAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40)
                                  ),
                                  child: const Text("Update",style:
                                  TextStyle(
                                    fontWeight: FontWeight.w600,fontSize: 16,
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
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),

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
        Uri.parse('http://10.0.2.2:8000/editProfile/update_user_password/${currentUser.uid}/'),
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
      } else if (response.statusCode == 403){
        if (kDebugMode) {
          print('Old password does not match dialog.');
        }
        return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0), (ErrorCodes.OLD_PASSWORD_DOES_NOT_MATCH_DIALOG));
      } else {
        if (kDebugMode) {
          print('Password update failed backend.');
        }
        return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0), (ErrorCodes.PASSWORD_UPDATE_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, ), (ErrorCodes.PASSWORD_UPDATE_FAIL_API_CONNECTION));
    }
  }
}