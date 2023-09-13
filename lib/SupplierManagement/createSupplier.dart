import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/StaffManagement/staffDashboard.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import 'package:keninacafe/Security/Encryptor.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../Entity/User.dart';
import '../Entity/Supplier.dart';
import '../Entity/LeaveType.dart';
import '../Entity/LeaveFormData.dart';
import '../Entity/StaffType.dart';

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
      home: const CreateSupplierPage(user: null,),
    );
  }
}

class CreateSupplierPage extends StatefulWidget {
  const CreateSupplierPage({super.key, this.user});

  final User? user;

  @override
  State<CreateSupplierPage> createState() => _CreateSupplierPageState();
}

class _CreateSupplierPageState extends State<CreateSupplierPage> {
  final supplierNameController = TextEditingController();
  final PICController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool supplierCreated = false;
  ImagePicker picker = ImagePicker();
  String base64Image = "";
  Widget image = Image(image: AssetImage('images/profile.png'));

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();
    // stream: dropdownItems.stream;

    User? currentUser = getUser();
    print(currentUser?.name);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context),
      appBar: AppsBarState().buildAppBar(context, 'Create Supplier', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
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
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 0, 0, 0)),
                          // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          onPressed: () async {
                            XFile? imageRaw = await ImagePicker().pickImage(source: ImageSource.gallery);
                            final File imageFile = File(imageRaw!.path);
                            final Image imageImage = Image.file(imageFile);
                            final imageBytes = await imageFile.readAsBytes();
                            base64Image = base64Encode(imageBytes);
                            setState(() {
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
                  // child: Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Supplier Name', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                          child:
                          TextFormField(
                            controller: supplierNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Please fill in the supplier name',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please fill in the supplier name !';
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                                children: [
                                  Text('PIC', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                          child:
                          TextFormField(
                            controller: PICController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Please fill in the PIC',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please fill in the PIC !';
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Contact', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                          child:
                          TextFormField(
                            controller: contactController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Please fill in the contact number',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please fill in the contact number !';
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Email', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                          child:
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Please fill in the email',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please fill in the email !';
                              return null;
                            },
                          ),
                        ),

                        // Padding(
                        //     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                        //     // child: Form(
                        //
                        //     child: FutureBuilder<List<StaffType>>(
                        //         future: getStaffType(),
                        //         builder: (BuildContext context, AsyncSnapshot<List<StaffType>> snapshot) {
                        //           if (snapshot.hasData) {
                        //
                        //             return Column(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 children: [buildDropDownButtonFormField(snapshot.data)]
                        //             );
                        //           } else {
                        //             if (snapshot.hasError) {
                        //               return Center(child: Text('Error: ${snapshot.error}'));
                        //             } else {
                        //               return const Center(child: Text('Error: invalid state'));
                        //             }
                        //           }
                        //         }
                        //     )
                        // ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Address', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                          child:
                          TextFormField(
                            controller: addressController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Please fill in the address',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please fill in the address !';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 13,),
                      ],

                    ),
                  ),
                ),

                // const SizedBox(height: 13,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  child: Container(
                    padding: const EdgeInsets.only(top: 3,left: 3),
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(40),
                    //     border: const Border(
                    //         bottom: BorderSide(color: Colors.black),
                    //         top: BorderSide(color: Colors.black),
                    //         right: BorderSide(color: Colors.black),
                    //         left: BorderSide(color: Colors.black)
                    //     )
                    // ),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height:40,
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          showConfirmationCreateDialog(currentUser);
                        }
                      },
                      color: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: const Text("Create",style: TextStyle(
                        fontWeight: FontWeight.w600,fontSize: 16,
                      ),),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }

  Future<(bool, String)> _submitRegisterDetails(User currentUser) async {
    String name = supplierNameController.text;
    String pic = PICController.text;
    String email = emailController.text;
    String contact = contactController.text;
    String address = addressController.text;

    if (kDebugMode) {
      print('name: $name');
      print('pic: $pic');
      print('email: $email');
      print('contact: $contact');
      print('address: $address');
    }
    var (thisSupplier, err_code) = await createSupplier(name, pic, email, contact, address);
    if (thisSupplier.name == '') {
      if (kDebugMode) {
        print("Failed to retrieve User data.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(Supplier, String)> createSupplier(String name, String pic, String email, String contact, String address) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/users/register'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'image': base64Image,
          'is_active': true,
          'name': name,
          'pic': pic,
          'contact': contact,
          'email': email,
          'address': address,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (Supplier.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Supplier exist in system.');
        }
        return (const Supplier(image: '', is_active: false, name: '', pic: '', contact: '', address: '', email: ''), (ErrorCodes.REGISTER_FAIL_SUPPLIER_EXISTS));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (const Supplier(image: '', is_active: false, name: '', pic: '', contact: '', address: '', email: ''), (ErrorCodes.REGISTER_FAIL_SUPPLIER_API_CONNECTION));
    }
  }

  void showConfirmationCreateDialog(User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Are you sure you want to create this supplier?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                // Perform save logic here
                // Navigator.of(context).pop();
                // Navigator.of(context).pop();
                if (_formKey.currentState!.validate()) {
                  var (supplierCreatedAsync, err_code) = await _submitRegisterDetails(currentUser);
                  setState(() {
                    supplierCreated = supplierCreatedAsync;
                    if (!supplierCreated) {
                      if (err_code == ErrorCodes.SUPPLIER_CREATE_FAIL_BACKEND) {
                        showDialog(context: context, builder: (
                            BuildContext context) =>
                            AlertDialog(
                              title: const Text('Error'),
                              content: Text('An Error occurred while trying to create a new supplier.\n\nError Code: $err_code'),
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
                      // If Leave Form Data success created

                      Navigator.of(context).pop();
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Create New Supplier Successful'),
                            content: const Text('The Supplier can be viewed in the Supplier List page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CreateSupplierPage(user: currentUser)),
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
}