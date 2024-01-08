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
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../Entity/User.dart';
import '../Entity/StaffType.dart';
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
      home: const UpdateStaffPage(user: null, staff: null, streamControllers: null),
    );
  }
}

class UpdateStaffPage extends StatefulWidget {
  const UpdateStaffPage({super.key, this.user, this.staff, this.streamControllers});

  final User? user;
  final User? staff;
  final Map<String,StreamController>? streamControllers;

  @override
  State<UpdateStaffPage> createState() => _UpdateStaffPageState();
}

class _UpdateStaffPageState extends State<UpdateStaffPage> {
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
  String gender = "";
  String? selectedValue;
  ImagePicker picker = ImagePicker();
  String base64Image = "";
  Widget image = const Image(image: AssetImage('images/profile.png'));
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  User? getStaff() {
    return widget.staff;
  }

  @override
  void initState() {
    super.initState();
    gender = getStaff()!.gender;
    staffNameController.text = getStaff()!.name;
    icController.text = getStaff()!.ic;
    emailController.text = getStaff()!.email;
    phoneController.text = getStaff()!.phone;
    addressController.text = getStaff()!.address;
    dobController.text = getStaff()!.dob.toString().substring(0,10);
    selectedValue = getStaff()!.staff_type;
    // gender = currentStaff.gender;
    if (base64Image == "") {
      base64Image = getStaff()!.image;
      if (base64Image == "") {
        image = Image.asset("images/profile.png");
        print("nothing in base64");
      } else {
        image = Image.memory(base64Decode(base64Image));
      }
    } else {
      image = Image.memory(base64Decode(base64Image));
    }
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
    User? currentStaff = getStaff();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildAppBarDetails(context, 'Update Staff', currentUser!, widget.streamControllers),
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
                      width: 135,
                      height: 135,
                      // child: ClipRRect(
                      //     borderRadius: BorderRadius.circular(100),
                      //     child: image
                      // ),
                      child: Container(
                        width: 150, // Set the desired width
                        height: 150, // Set the desired height
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(30), // Adjust the borderRadius as needed
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: image, // Assuming 'image' is an Image or Image.network widget
                        ),
                      )
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
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade400),
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
                                        children: [buildDropDownButtonFormField(snapshot.data)]
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
                                color: Colors.grey.shade500,
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
                          if (_formKey.currentState!.validate()) {
                            showConfirmationUpdateDialog(currentStaff!, currentUser);
                          }
                        });
                      },
                      color: Colors.greenAccent.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)
                      ),
                      child: const Text("Update",style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white,
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

  Widget buildDropDownButtonFormField(List<StaffType>? staffTypes) {
    List<DropdownMenuItem<String>> staffTypeNames = [];
    staffTypeNames = getDropDownMenuItem(staffTypes!);
    return DropdownButtonFormField(
      decoration: InputDecoration(
        hintText: 'e.g. Restaurant Worker',
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

  List<DropdownMenuItem<String>> getDropDownMenuItem(List<StaffType> listStaffType) {
    List<DropdownMenuItem<String>> staffTypes = [];
    for (StaffType a in listStaffType) {
      staffTypes.add(DropdownMenuItem(value: a.name, child: Text(a.name)));
    }
    return staffTypes;
  }

  Future<List<StaffType>> getStaffType() async {
    try {
      final response = await http.get(
        Uri.parse('${IpAddress.ip_addr}/staffManagement/request_type_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print(response.body.toString());

        return StaffType.getStaffTypeList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load leave type');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }
  }

  Future<(String, User)> _submitUpdateStaffDetails(User currentStaff) async {
    var (thisUser, err_code) = await updateStaff(currentStaff);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to update Staff data.");
      }
      return (err_code, currentStaff);
    }
    currentStaff = thisUser;
    return (err_code, currentStaff);
  }

  Future<(User, String)> updateStaff(User currentStaff) async {
    try {
      final response = await http.put(
        Uri.parse('${IpAddress.ip_addr}/staffManagement/update_staff_details'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'image': base64Image,
          'current_staff_update_id': currentStaff.uid,
          'name': staffNameController.text,
          'ic': icController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'address': addressController.text,
          'staff_type': selectedValue,
          'gender': gender,
          'dob': DateTime.parse(dobController.text).toString(),
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No Staff found.');
        }
        return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.UPDATE_STAFF_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, name: '', email: '', address: '', gender: '', dob: DateTime.now(), image: '', is_staff: false, is_active: false, staff_type: '', phone: '', ic: '', points: 0, date_created: DateTime.now(), date_deactivated: DateTime.now()), (ErrorCodes.UPDATE_STAFF_FAIL_API_CONNECTION));
    }
  }

  void showConfirmationUpdateDialog(User currentStaff, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to update this staff (${currentStaff.name}) ?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var (err_code, currentStaffUpdated) = await _submitUpdateStaffDetails(currentStaff);
                  setState(() {
                    Navigator.of(context).pop();
                    if (err_code == ErrorCodes.UPDATE_STAFF_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: Text('An Error occurred while trying to update this staff (${currentStaff.name}).\n\nError Code: $err_code'),
                            actions: <Widget>[
                              TextButton(onPressed: () =>
                                  Navigator.pop(context, 'Ok'),
                                  child: const Text('Ok')),
                            ],
                          ),
                      );
                    } else if (err_code == ErrorCodes.UPDATE_STAFF_FAIL_API_CONNECTION) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
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
                    } else {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Updated Staff Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                            content: Text('The Updated Staff (${staffNameController.text}) details can be viewed in the Staff List page.'),
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
}