import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/StaffManagement/staffList.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import 'package:keninacafe/Security/Encryptor.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/User.dart';
import '../Entity/StaffType.dart';
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
      home: const CreateStaffPage(user: null, streamControllers: null),
    );
  }
}

class CreateStaffPage extends StatefulWidget {
  const CreateStaffPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<CreateStaffPage> createState() => _CreateStaffPageState();
}

class _CreateStaffPageState extends State<CreateStaffPage> {
  final staffNameController = TextEditingController();
  final icController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final dobController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool securePasswordText = true;
  bool secureConfirmPasswordText = true;
  bool staffCreated = false;
  bool imageSelected = false;
  String gender = "";
  bool genderSelected = true;
  String? selectedValue;
  ImagePicker picker = ImagePicker();
  String base64Image = "";
  Widget image = const Image(image: AssetImage('images/profile.png'));
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
    enterFullScreen();

    User? currentUser = getUser();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildAppBarDetails(context, 'Create Staff', currentUser!, widget.streamControllers),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 20),
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: image
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child:
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade200),
                            // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                            onPressed: () async {
                              XFile? imageRaw = await ImagePicker().pickImage(source: ImageSource.gallery);
                              final File imageFile = File(imageRaw!.path);
                              final Image imageImage = Image.file(imageFile);
                              final imageBytes = await imageFile.readAsBytes();
                              base64Image = base64Encode(imageBytes);
                              setState(() {
                                imageSelected = true;
                                image = Image.memory(imageBytes);
                              });
                            },
                            child: const Icon(LineAwesomeIcons.camera, color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Staff Name', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: TextFormField(
                            controller: staffNameController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Ali',
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
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please fill in the staff name !';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 13,),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('IC', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child:
                          TextFormField(
                            controller: icController,
                            decoration: InputDecoration(
                              hintText: 'e.g. 010726-08-XXXX',
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
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please fill in the staff IC !';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 13,),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Email', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child:
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              hintText: 'e.g. clgoh0726@gmail.com',
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
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please fill in the email !';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 13,),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Phone Number', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child:
                          TextFormField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              hintText: 'e.g. 0165429748',
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
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please fill in the phone number !';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 13,),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Address', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child:
                          TextFormField(
                            controller: addressController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'e.g. 12, Taman Anggerik....',
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
                            ),
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please fill in the address !';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 13,),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Staff Type', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: FutureBuilder<List<StaffType>>(
                                future: getStaffType(),
                                builder: (BuildContext context, AsyncSnapshot<List<StaffType>> snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [buildDropDownButtonFormField(snapshot.data, currentUser)]
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
                        const SizedBox(height: 13,),
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
                        const SizedBox(height: 13,),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                          child: Row(
                            children: [
                              Text("Gender", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                              // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: genderSelected == false ? Colors.red : Colors.grey.shade500,
                                width: 2.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Radio(
                                        visualDensity: const VisualDensity(horizontal: -2.0),
                                        value: "Male",
                                        groupValue: gender,
                                        activeColor: Colors.red,
                                        fillColor: MaterialStateProperty.resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.selected)) {
                                              return Colors.red;
                                            }
                                            return Colors.grey.shade700;
                                          },
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            gender = value.toString();
                                          });
                                        },
                                      ),
                                      Text(
                                        'Male',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Gabarito",
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio(
                                        // contentPadding: EdgeInsets.zero,
                                        visualDensity: const VisualDensity(horizontal: -2.0),
                                        value: "Female",
                                        groupValue: gender,
                                        activeColor: Colors.red,
                                        fillColor: MaterialStateProperty.resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.selected)) {
                                              return Colors.red; // Set border color when selected
                                            }
                                            return Colors.grey.shade700; // No border color when unselected
                                          },
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            gender = value.toString();
                                          });
                                        },
                                      ),
                                      Text(
                                        'Female',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "Gabarito",
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              )
                            ),
                          ),
                        ),
                        const SizedBox(height: 13.0),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Date Of Birth', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 6),
                          child:TextFormField(
                            controller: dobController,
                            decoration: const InputDecoration(
                                icon: Icon(Icons.calendar_month),
                                // labelText: "Date Of Birth"
                            ),
                            validator: (dateToController) {
                              if (dateToController == null || dateToController.isEmpty) return 'Please choose the date to !';
                              return null;
                            },
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito",
                            ),
                            readOnly: true,
                            onTap: () async {
                              var pickedDate = await showDatePicker(
                                  context: context, initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101)
                              );
                              if(pickedDate != null ){
                                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                setState(() {
                                  dobController.text = formattedDate;
                                });
                              }else{

                              }
                            },
                          )
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  child: Container(
                    padding: const EdgeInsets.only(top: 3,left: 3),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height:40,
                      onPressed: (){
                        setState(() {
                          if (gender == "") {
                            genderSelected = false;
                          }
                          if (base64Image == "") {
                            imageSelected = false;
                            showImageNotSelectedDialog();
                          }
                          if (_formKey.currentState!.validate() && imageSelected && genderSelected) {
                            showConfirmationCreateDialog(currentUser);
                          }
                        });
                      },
                      color: Colors.lightBlueAccent.shade400,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: const Text("Create",style: TextStyle(
                        fontWeight: FontWeight.bold,fontSize: 16, color: Colors.white
                      ),),
                    ),
                  ),
                ),
                const SizedBox(height: 13.0,),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context, widget.streamControllers),
    );
  }

  Widget buildDropDownButtonFormField(List<StaffType>? staffTypes, User currentUser) {
    List<DropdownMenuItem<String>> staffTypeNames = [];
    staffTypeNames = getDropDownMenuItem(staffTypes!, currentUser);
    return DropdownButtonFormField(
      decoration: InputDecoration(
        hintText: 'e.g. Restaurant Worker',
        hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Gabarito"),
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
        filled: true,
        fillColor: Colors.white,
      ),
      style: TextStyle(
        fontSize: 18.0,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.bold,
        fontFamily: "Gabarito",
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please choose the staff type !';
        return null;
      },
      value: selectedValue,
      onChanged: (String? newValue) {
        setState(() {
          selectedValue = newValue!;
        });
      },
      items: staffTypeNames,
    );
  }

  List<DropdownMenuItem<String>> getDropDownMenuItem(List<StaffType> listStaffType, User currentUser) {
    List<DropdownMenuItem<String>> staffTypes = [];
    for (StaffType a in listStaffType) {
      if (currentUser.staff_type == "Restaurant Manager" && a.name != "Restaurant Owner") {
        staffTypes.add(DropdownMenuItem(value: a.name, child: Text(a.name)));
      } else if (currentUser.staff_type == "Restaurant Owner") {
        staffTypes.add(DropdownMenuItem(value: a.name, child: Text(a.name)));
      }

    }
    return staffTypes;
  }

  Future<(bool, String)> _submitCreateStaffDetails(User currentUser) async {
    String name = staffNameController.text;
    String ic = icController.text;
    String email = emailController.text;
    String? staffType = selectedValue;
    String phone = phoneController.text;
    String address = addressController.text;
    String password = passwordController.text;
    String confirmPw = confirmPasswordController.text;
    String gender = this.gender;
    DateTime dob = DateTime.parse(dobController.text);

    if (kDebugMode) {
      print('name: $name');
      print('ic: $ic');
      print('email: $email');
      print('staff_type: $staffType');
      print('phone: $phone');
      print('address: $address');
      print('password: $password');
      print('confirmPw: $confirmPw');
      print('gender: $gender');
      print('dob: $dob');
    }
    String encPw = Encryptor().encryptPassword(password);
    var (thisUser, err_code) = await createStaff(name, ic, email, staffType!, phone, address, encPw, gender, dob);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to create staff.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(User, String)> createStaff(String name, String ic, String email, String staffType, String phone, String address, String encPw, String gender, DateTime dob) async {
    int? staffTypeId;
    if (staffType == "Restaurant Owner") {
      staffTypeId = 1;
    } else if (staffType == "Restaurant Manager") {
      staffTypeId = 2;
    } else if (staffType == "Restaurant Worker") {
      staffTypeId = 3;
    } else {
      staffTypeId = null;
    }
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/users/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'image': base64Image,
          'is_staff': true,
          'is_active': true,
          'staff_type': staffTypeId,
          'name': name,
          'email': email,
          'password': encPw,
          'address': address,
          'phone': phone,
          'gender': gender,
          'dob': dob.toString(),
          'ic': ic,
          'points': 0,
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Staff exist in system.');
        }
        if (responseData['email'][0] == "user with this email already exists.") {
          return (User(uid: -1, image: '', is_staff: false, is_active: false, staff_type: '', name: '', ic: '', address: '', email: '', gender: '', dob: DateTime.now(), phone: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.REGISTER_SAME_STAFF));
        }
        return (User(uid: -1, image: '', is_staff: false, is_active: false, staff_type: '', name: '', ic: '', address: '', email: '', gender: '', dob: DateTime.now(), phone: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.REGISTER_STAFF_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, image: '', is_staff: false, is_active: false, staff_type: '', name: '', ic: '', address: '', email: '', gender: '', dob: DateTime.now(), phone: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.REGISTER_STAFF_FAIL_API_CONNECTION));
    }
  }

  Future<List<StaffType>> getStaffType() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/staffManagement/request_type_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return StaffType.getStaffTypeList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load leave type');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }
  }

  void showConfirmationCreateDialog(User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure you want to create the staff?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Perform save logic here
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                if (_formKey.currentState!.validate()) {
                  var (staffCreatedAsync, err_code) = await _submitCreateStaffDetails(currentUser);
                  setState(() {
                    staffCreated = staffCreatedAsync;
                    if (!staffCreated) {
                      if (err_code == ErrorCodes.REGISTER_STAFF_FAIL_BACKEND) {
                        showDialog(
                          context: context, builder: (BuildContext context) =>
                            AlertDialog(
                              title: const Text('Error'),
                              content: Text(
                                  'An Error occurred while trying to create a new staff.\n\nError Code: $err_code'),
                              actions: <Widget>[
                                TextButton(onPressed: () =>
                                    Navigator.pop(context, 'Ok'),
                                    child: const Text('Ok')),
                              ],
                            ),
                        );
                      } else if (err_code == ErrorCodes.REGISTER_SAME_STAFF) {
                        showDialog(
                          context: context, builder: (BuildContext context) =>
                            AlertDialog(
                              title: const Text('Email Registered'),
                              content: Text(
                                  'Please double check the staff list.\n\nError Code: $err_code'),
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
                      Navigator.of(context).pop();
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Create New Staff Successful'),
                            content: const Text('The Staff can be viewed in the Staff List page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => StaffListPage(user: currentUser, streamControllers: widget.streamControllers)),
                                  );
                                },
                              ),
                            ],
                          ),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
                        selectedValue = null;
                        staffNameController.text = '';
                        icController.text = '';
                        emailController.text = '';
                        addressController.text = '';
                        phoneController.text = '';
                        passwordController.text = '';
                        confirmPasswordController.text = '';
                        dobController.text = '';
                        gender = "";
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

  void showImageNotSelectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Image Not Selected', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Please select the staff profile image !'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              // style: ElevatedButton.styleFrom(
              //   backgroundColor: Colors.red,
              // ),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}