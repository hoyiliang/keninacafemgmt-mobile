import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:flutter/gestures.dart';
import 'package:keninacafe/PersonalProfile/viewPersonalProfile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import 'package:keninacafe/StaffManagement/staffList.dart';
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
      home: const DeleteStaffPage(staff_data: null, user: null,),
    );
  }
}

class DeleteStaffPage extends StatefulWidget {
  const DeleteStaffPage({super.key, this.user, this.staff_data});

  final User? user;
  final User? staff_data;

  @override
  State<DeleteStaffPage> createState() => _DeleteStaffPageState();
}

class _DeleteStaffPageState extends State<DeleteStaffPage> {
  final nameController = TextEditingController();
  final icController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final staffTypeController = TextEditingController();
  final dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool profileUpdated = false;
  bool securePasswordText = true;
  bool secureConfirmPasswordText = true;
  ImagePicker picker = ImagePicker();
  XFile? image;

  User? getUser() {
    return widget.user;
  }

  User? getStaffData() {
    return widget.staff_data;
  }

  void showConfirmationDialog(User staffData, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure you want to delete the staff?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Perform save logic here
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                if (_formKey.currentState!.validate()) {
                  var (err_code, currentUserUpdated) = await _submitDeleteStaffDetails(staffData);
                  setState(() {
                    // profileUpdated = profileUpdatedAsync;
                    // if (!profileUpdated) {
                    if (err_code == ErrorCodes.DELETE_STAFF_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error'),
                            content: Text('An Error occurred while trying to delete the staff.\n\nError Code: $err_code'),
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
                      // If Leave Form Data success created

                      Navigator.of(context).pop();
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Delete Staff Successful'),
                            // content: const Text('The Leave Form Data can be viewed in the LA status page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => StaffListPage(user: currentUser)),
                                  );
                                },
                              ),
                            ],
                          ),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
                        nameController.text = "";
                        emailController.text = "";
                        passwordController.text = '';
                        addressController.text = '';
                        staffTypeController.text = '';
                        dobController.text = '';
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

  // void reqPermission() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //       Permission.location,
  //       Permission.storage,
  //   ].request();
  // }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    User? staffData = getStaffData();
    // print(currentUser?.name);
    nameController.text = staffData!.name;
    icController.text = staffData.ic;
    emailController.text = staffData.email;
    phoneNumberController.text = staffData.phone;
    addressController.text = staffData.address;
    staffTypeController.text = staffData.staff_type;
    dobController.text = staffData.dob.toString().substring(0,10);


    // reqPermission();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildAppBar(context, 'Update Profile', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 13),
                  Stack(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: const Image(image: AssetImage('images/KE_Nina_Cafe_appsbar.jpg'))),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: SizedBox(
                          width: 40,
                          height: 35,
                          child: ElevatedButton(
                            // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                            onPressed: () async {
                              // image = await picker.pickImage(source: ImageSource.gallery);
                              // setState(() {
                              //   //update UI
                              // });
                              image = await ImagePicker().pickImage(source: ImageSource.gallery);
                            },
                            child: const Icon(LineAwesomeIcons.camera, color: Colors.black),

                            // child: const Text("Upload Image")
                          ),
                          // decoration:
                          // BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          // child: const Icon(LineAwesomeIcons.camera, color: Colors.black, size: 20),
                        ),
                        // child: SizedBox(
                        //   width: 35,
                        //   height: 35,
                        //   child: ElevatedButton(
                        //       // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                        //     onPressed: () async {
                        //       // image = await picker.pickImage(source: ImageSource.gallery);
                        //       // setState(() {
                        //       //   //update UI
                        //       // });
                        //       final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                        //     },
                        //     child: const Padding(
                        //       padding: EdgeInsets.fromLTRB(0,0,100,0),
                        //       child: Icon(LineAwesomeIcons.camera, color: Colors.black, size: 20),
                        //     ),
                        //       // child: const Text("Upload Image")
                        //   ),
                        //   // decoration:
                        //   // BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                        //   // child: const Icon(LineAwesomeIcons.camera, color: Colors.black, size: 20),
                        // ),
                        // ElevatedButton(
                        //   onPressed: () async {
                        //     // image = await picker.pickImage(source: ImageSource.gallery);
                        //     // setState(() {
                        //     //   //update UI
                        //     // });
                        //     final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                        //   },
                        //   child: const Text("Upload Image")
                        // ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Form(
                    key: _formKey,
                    child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                                label: Text('Name'), prefixIcon: Icon(LineAwesomeIcons.user)
                            ),
                            validator: (nameController) {
                              if (nameController == null || nameController.isEmpty) return 'Please fill in your full name !';
                              return null;
                            },
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            controller: icController,
                            decoration: const InputDecoration(
                                label: Text('IC'), prefixIcon: Icon(LineAwesomeIcons.identification_badge)
                            ),
                            validator: (icController) {
                              if (icController == null || icController.isEmpty) return 'Please fill in your IC !';
                              return null;
                            },
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                                label: Text('Email'), prefixIcon: Icon(LineAwesomeIcons.envelope_1)
                            ),
                            validator: (emailController) {
                              if (emailController == null || emailController.isEmpty) return 'Please fill in your email !';
                              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                              if (!emailRegex.hasMatch(emailController)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            controller: phoneNumberController,
                            decoration: const InputDecoration(
                                label: Text('Phone Number'), prefixIcon: Icon(LineAwesomeIcons.phone)
                            ),
                            validator: (phoneNumberController) {
                              if (phoneNumberController == null || phoneNumberController.isEmpty) return 'Please fill in your phone number !';
                              return null;
                            },
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            controller: addressController,
                            decoration: const InputDecoration(
                                label: Text('Address'), prefixIcon: Icon(LineAwesomeIcons.address_card)
                            ),
                            validator: (phoneNumberController) {
                              if (phoneNumberController == null || phoneNumberController.isEmpty) return 'Please fill in your phone number !';
                              return null;
                            },
                          ),
                          const SizedBox(height: 13),
                          TextFormField(
                            controller: staffTypeController,
                            decoration: const InputDecoration(
                                label: Text('Staff Type'), prefixIcon: Icon(LineAwesomeIcons.people_carry)
                            ),
                            validator: (phoneNumberController) {
                              if (phoneNumberController == null || phoneNumberController.isEmpty) return 'Please fill in your phone number !';
                              return null;
                            },
                            readOnly: true,
                          ),
                          const SizedBox(height: 13),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: TextFormField(
                              controller: dobController, //editing controller of this TextField
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.calendar_today), //icon of text field
                                  labelText: "Date Of Birth" //label text of field
                              ),
                              validator: (dobController) {
                                if (dobController == null || dobController.isEmpty) return 'Please choose the date to !';
                                return null;
                              },
                              readOnly: true,//set it true, so that user will not able to edit text
                              onTap: null,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                            child: Container(
                              padding: const EdgeInsets.only(top: 3,left: 3),
                              child: MaterialButton(
                                minWidth: double.infinity,
                                height:50,
                                onPressed: (){
                                  if (_formKey.currentState!.validate()) {
                                    showConfirmationDialog(staffData, currentUser);
                                    // if (image != null) {
                                    //   showConfirmationDialog();
                                    // } else {
                                    //   // showUploadImageDialog();
                                    // }
                                  }
                                },
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)
                                ),
                                child: const Text("Delete",style:
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

                  // child: Form(
                  //   key: _formKey,
                  //   child: Column(
                  //     children: [
                  //       const SizedBox(height: 15,),
                  //       const Padding(
                  //         padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                  //         child: Row(
                  //             children: [
                  //               Text('Image', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                  //               Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                  //             ]
                  //         )
                  //       ),
                  //
                  //       Padding(
                  //         padding: const EdgeInsets.symmetric(horizontal: 32,),
                  //         child: Row(
                  //             children: [
                  //               ElevatedButton(
                  //                   onPressed: () async {
                  //                     // image = await picker.pickImage(source: ImageSource.gallery);
                  //                     // setState(() {
                  //                     //   //update UI
                  //                     // });
                  //                     final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                  //                   },
                  //                   child: const Text("Upload Image")
                  //               ),
                  //               // image == null?Container():
                  //               // Image.file(File(image!.path))
                  //             ]
                  //         ),
                  //       ),
                  //
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
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
        return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0), (ErrorCodes.DELETE_STAFF_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, ), (ErrorCodes.DELETE_STAFF_FAIL_API_CONNECTION));
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