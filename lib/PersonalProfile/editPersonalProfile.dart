import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
      home: const EditPersonalProfilePage(user: null,),
    );
  }
}

class EditPersonalProfilePage extends StatefulWidget {
  const EditPersonalProfilePage({super.key, this.user});

  final User? user;

  @override
  State<EditPersonalProfilePage> createState() => _EditPersonalProfilePageState();
}

class _EditPersonalProfilePageState extends State<EditPersonalProfilePage> {
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
  Widget? image;
  String base64Image = "";
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  // void showConfirmationDialog(User currentUser) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
  //         content: const Text('Are you sure you want to update the personal profile?'),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () async {
  //               if (_formKey.currentState!.validate()) {
  //                 var (err_code, currentUserUpdated) = await _submitUpdateDetails(currentUser);
  //                 setState(() {
  //                   if (err_code == ErrorCodes.PERSONAL_PROFILE_UPDATE_FAIL_BACKEND) {
  //                     showDialog(context: context, builder: (
  //                         BuildContext context) =>
  //                         AlertDialog(
  //                           title: const Text('Error'),
  //                           content: Text('An Error occurred while trying to update the personal profile.\n\nError Code: $err_code'),
  //                           actions: <Widget>[
  //                             TextButton(onPressed: () =>
  //                                 Navigator.pop(context, 'Ok'),
  //                                 child: const Text('Ok')),
  //                           ],
  //                         ),
  //                     );
  //                   } else if (err_code == ErrorCodes.PERSONAL_PROFILE_UPDATE_FAIL_API_CONNECTION){
  //                       showDialog(context: context, builder: (
  //                           BuildContext context) =>
  //                           AlertDialog(
  //                             title: const Text('Connection Error'),
  //                             content: Text(
  //                                 'Unable to establish connection to our services. Please make sure you have an internet connection.\n\nError Code: $err_code'),
  //                             actions: <Widget>[
  //                               TextButton(onPressed: () =>
  //                                   Navigator.pop(context, 'Ok'),
  //                                   child: const Text('Ok')),
  //                             ],
  //                           ),
  //                       );
  //                     } else {
  //                     Navigator.of(context).pop();
  //                     showDialog(context: context, builder: (
  //                         BuildContext context) =>
  //                         AlertDialog(
  //                           title: const Text('Update Personal Profile Successful'),
  //                           // content: const Text('The Leave Form Data can be viewed in the LA status page.'),
  //                           actions: <Widget>[
  //                             TextButton(
  //                               child: const Text('Ok'),
  //                               onPressed: () {
  //                                 Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUserUpdated)),
  //                                 );
  //                               },
  //                             ),
  //                           ],
  //                         ),
  //                     );
  //                     _formKey.currentState?.reset();
  //                     setState(() {
  //
  //                     });
  //                   }
  //                 });
  //               }
  //               // saveAnnouncement(title, text);
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.green,
  //             ),
  //             child: const Text('Yes'),
  //
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.red,
  //             ),
  //             child: const Text('No'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    nameController.text = currentUser!.name;
    icController.text = currentUser.ic;
    emailController.text = currentUser.email;
    phoneNumberController.text = currentUser.phone;
    addressController.text = currentUser.address;
    staffTypeController.text = currentUser.staff_type;
    dobController.text = currentUser.dob.toString().substring(0,10);
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

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage),
      appBar: AppsBarState().buildAppBarDetails(context, 'Update Profile', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      SizedBox(
                        width: 130,
                        height: 130,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: image,
                        ),
                      ),
                      // Positioned(
                      //   bottom: 0,
                      //   right: 0,
                      //   child: SizedBox(
                      //     width: 35,
                      //     height: 35,
                      //     child: ElevatedButton(
                      //       style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade200),
                      //       onPressed: () async {
                      //         XFile? imageRaw = await ImagePicker().pickImage(source: ImageSource.gallery);
                      //         final File imageFile = File(imageRaw!.path);
                      //         final Image imageImage = Image.file(imageFile);
                      //         final imageBytes = await imageFile.readAsBytes();
                      //         setState(() {
                      //           base64Image = base64Encode(imageBytes);
                      //           if(kDebugMode) {
                      //             print(base64Image);
                      //           }
                      //           image = imageImage;
                      //         });
                      //       },
                      //       child: const Icon(LineAwesomeIcons.camera, color: Colors.black),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                  const SizedBox(height: 13),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          enabled: false,
                          decoration: InputDecoration(
                            label: Text('Name', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(LineAwesomeIcons.user, color: Colors.grey.shade700,),
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gabarito",
                          ),
                          // validator: (nameController) {
                          //    if (nameController == null || nameController.isEmpty) return 'Please fill in your full name !';
                          //    return null;
                          // },
                        ),
                        const SizedBox(height: 13),
                        TextFormField(
                          enabled: false,
                          controller: icController,
                          decoration: InputDecoration(
                            label: Text('IC', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(LineAwesomeIcons.address_card, color: Colors.grey.shade700,),
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gabarito",
                          ),
                        ),
                        const SizedBox(height: 13),
                        TextFormField(
                          enabled: false,
                          controller: emailController,
                          decoration: InputDecoration(
                              label: Text('Email', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(LineAwesomeIcons.envelope_1, color: Colors.grey.shade700,)
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gabarito",
                          ),
                          // validator: (emailController) {
                          //   if (emailController == null || emailController.isEmpty) return 'Please fill in your email !';
                          //   final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                          //   if (!emailRegex.hasMatch(emailController)) {
                          //     return 'Please enter a valid email address';
                          //   }
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 13),
                        TextFormField(
                          enabled: false,
                          controller: phoneNumberController,
                          decoration: InputDecoration(
                              label: Text('Phone Number', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(LineAwesomeIcons.phone, color: Colors.grey.shade700,)
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gabarito",
                          ),
                          // validator: (phoneNumberController) {
                          //   if (phoneNumberController == null || phoneNumberController.isEmpty) return 'Please fill in your phone number !';
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 13),
                        TextFormField(
                          enabled: false,
                          maxLines: null,
                          controller: addressController,
                          decoration: InputDecoration(
                              label: Text('Address', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(Icons.location_on_outlined, color: Colors.grey.shade700,)
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gabarito",
                          ),
                          // validator: (phoneNumberController) {
                          //   if (phoneNumberController == null || phoneNumberController.isEmpty) return 'Please fill in your phone number !';
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 13),
                        TextFormField(
                          enabled: false,
                          controller: staffTypeController,
                          decoration: InputDecoration(
                              label: Text('Position', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(Icons.work_outline, color: Colors.grey.shade700,)
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gabarito",
                          ),
                          // validator: (phoneNumberController) {
                          //   if (phoneNumberController == null || phoneNumberController.isEmpty) return 'Please fill in your phone number !';
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 13),
                        TextFormField(
                          enabled: false,
                          controller: dobController,
                          decoration: InputDecoration(
                              label: Text('Date Of Birth', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.grey.shade500),), prefixIcon: Icon(Icons.cake_outlined, color: Colors.grey.shade700,)
                          ),
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Gabarito",
                          ),
                          // validator: (phoneNumberController) {
                          //   if (phoneNumberController == null || phoneNumberController.isEmpty) return 'Please fill in your phone number !';
                          //   return null;
                          // },
                        ),
                        const SizedBox(height: 13),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                        //   child: Container(
                        //     padding: const EdgeInsets.only(top: 3,left: 3),
                        //     child: MaterialButton(
                        //       minWidth: double.infinity,
                        //       height:50,
                        //       onPressed: (){
                        //         if (_formKey.currentState!.validate()) {
                        //           showConfirmationDialog(currentUser);
                        //           // if (image != null) {
                        //           //   showConfirmationDialog();
                        //           // } else {
                        //           //   // showUploadImageDialog();
                        //           // }
                        //         }
                        //       },
                        //       color: Colors.lightBlueAccent,
                        //       shape: RoundedRectangleBorder(
                        //           borderRadius: BorderRadius.circular(40)
                        //       ),
                        //       child: const Text("Update",style:
                        //       TextStyle(
                        //         fontWeight: FontWeight.w600,fontSize: 16,
                        //       ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ]
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }

  // Future<(String, User)> _submitUpdateDetails(User currentUser) async {
  //   var (thisUser, err_code) = await updatePersonalProfile(currentUser);
  //   if (thisUser.uid == -1) {
  //     if (kDebugMode) {
  //       print("Failed to update User data.");
  //     }
  //     return (err_code, currentUser);
  //   }
  //   currentUser = thisUser;
  //   return (err_code, currentUser);
  // }
  //
  // Future<(User, String)> updatePersonalProfile(User currentUser) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('http://10.0.2.2:8000/editProfile/update_user_profile/${currentUser.uid}/'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(<String, dynamic> {
  //         // 'id': leaveFormData.id,
  //         'image': base64Image,
  //         'name': nameController.text,
  //         'email': emailController.text,
  //         'address': addressController.text,
  //         'phone': phoneNumberController.text,
  //         'dob': DateTime.parse(dobController.text).toString(),
  //       }),
  //     );
  //
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       var jsonResp = jsonDecode(response.body);
  //       var jwtToken = jsonResp['token'];
  //       return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
  //     } else {
  //       if (kDebugMode) {
  //         print('No User found.');
  //       }
  //       return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0), (ErrorCodes.LOGIN_FAIL_NO_USER));
  //     }
  //   } on Exception catch (e) {
  //     if (kDebugMode) {
  //       print('API Connection Error. $e');
  //     }
  //     return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, ), (ErrorCodes.LOGIN_FAIL_API_CONNECTION));
  //   }
  // }
}