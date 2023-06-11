import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:flutter/gestures.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

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
      home: const EditPersonalProfilePage(),
    );
  }
}

class EditPersonalProfilePage extends StatefulWidget {
  const EditPersonalProfilePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

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
  final _formKey = GlobalKey<FormState>();
  bool securePasswordText = true;
  bool secureConfirmPasswordText = true;
  ImagePicker picker = ImagePicker();
  File? image;

  void showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure you want to update your profile?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Perform save logic here
                Navigator.of(context).pop();
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

  void reqPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.storage,
    ].request();
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
    reqPermission();
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context),
      appBar: AppsBarState().buildAppBar(context, 'Update Profile'),
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
                              final image = await ImagePicker().pickImage(source: ImageSource.gallery);
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
                          obscureText: securePasswordText,
                          controller: passwordController,
                          decoration: InputDecoration(
                            label: const Text('Password'),
                            prefixIcon: const Icon(Icons.fingerprint),
                            suffix: InkWell(
                              onTap: _togglePasswordView,
                              child: const Icon( Icons.visibility),
                            ),
                            // suffixIcon: IconButton(icon: const Icon(LineAwesomeIcons.eye), onPressed: () {
                            //   _togglePasswordView;
                            // }),
                          ),
                          validator: (passwordController) {
                            if (passwordController == null || passwordController.isEmpty) return 'Please fill in your password !';
                            return null;
                          },
                        ),
                        const SizedBox(height: 13),
                        TextFormField(
                          obscureText: secureConfirmPasswordText,
                          controller: confirmPasswordController,
                          decoration: InputDecoration(
                            label: const Text('Confirm Password'),
                            prefixIcon: const Icon(Icons.fingerprint),
                            suffix: InkWell(
                              onTap: _toggleConfirmPasswordView,
                              child: const Icon( Icons.visibility),
                            ),
                            // suffixIcon: IconButton(icon: const Icon(LineAwesomeIcons.eye_slash), onPressed: () {}),
                          ),
                          validator: (confirmPasswordController) {
                            if (confirmPasswordController == null || confirmPasswordController.isEmpty) return 'Please fill in your password again !';
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
                                  showConfirmationDialog();
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
    );
  }
}