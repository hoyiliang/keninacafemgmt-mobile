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
      home: const CreateStaffPage(user: null,),
    );
  }
}

class CreateStaffPage extends StatefulWidget {
  const CreateStaffPage({super.key, this.user});

  final User? user;

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
  String gender = "";
  String? selectedValue;
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
    // stream: dropdownItems.stream;

    User? currentUser = getUser();
    print(currentUser?.name);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildAppBar(context, 'Create Staff', currentUser!),
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
                                    Text('Staff Name', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:
                            TextFormField(
                              controller: staffNameController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Please fill in the staff name',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please fill in the staff name !';
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 13,),

                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('IC', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:
                            TextFormField(
                              controller: icController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Please fill in the staff IC',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please fill in the staff IC !';
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
                                hintText: 'Please fill in the staff email',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please state your reason !';
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 13,),

                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Staff Type', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              // child: Form(

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
                                        return const Center(child: Text('Error: invalid state'));
                                      }
                                    }
                                  }
                              )
                          ),

                          const SizedBox(height: 13,),

                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Phone Number', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:
                            TextFormField(
                              controller: phoneController,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Please fill in the staff phone number',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) return 'Please state your reason !';
                                return null;
                              },
                            ),
                          ),

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

                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:
                            TextFormField(
                              obscureText: securePasswordText,
                              controller: passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                final passwordRegex =
                                RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#&*~]).{8,}$');

                                if (!passwordRegex.hasMatch(value)) {
                                  return 'Please enter a valid password with at least one capital letter, one small letter, one number, and one symbol from '
                                      '!, @, #, &, * or ~';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                suffix: InkWell(
                                  onTap: _togglePasswordView,
                                  child: const Icon( Icons.visibility),
                                ),
                                hintText: 'Please enter your password',
                              ),
                            ),
                          ),

                          const SizedBox(height: 13,),

                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Confirm Password', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:
                            TextFormField(
                              obscureText: secureConfirmPasswordText,
                              controller: confirmPasswordController,
                              validator: (value) {
                                if (value != passwordController.text) {
                                  return 'Passwords do not match!';
                                } else if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                suffix: InkWell(
                                  onTap: _toggleConfirmPasswordView,
                                  child: const Icon( Icons.visibility),
                                ),
                                hintText: 'Please enter the password again',
                              ),
                            ),
                          ),

                          const SizedBox(height: 13,),

                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                              children: [
                                Text("What is your gender?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Column(
                              children: [
                                RadioListTile(
                                  title: const Text("Male"),
                                  value: "male",
                                  groupValue: gender,
                                  onChanged: (value){
                                    setState(() {
                                      gender = value.toString();
                                    });
                                  },
                                ),
                                RadioListTile(
                                  title: const Text("Female"),
                                  value: "female",
                                  groupValue: gender,
                                  onChanged: (value){
                                    setState(() {
                                      gender = value.toString();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),

                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Date Of Birth', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                    Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),

                          Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                              child:TextFormField(
                                controller: dobController, //editing controller of this TextField
                                decoration: const InputDecoration(
                                    icon: Icon(Icons.calendar_today), //icon of text field
                                    labelText: "Date Of Birth" //label text of field
                                ),
                                validator: (dateToController) {
                                  if (dateToController == null || dateToController.isEmpty) return 'Please choose the date to !';
                                  return null;
                                },
                                readOnly: true,  //set it true, so that user will not able to edit text
                                onTap: () async {
                                  var pickedDate = await showDatePicker(
                                      context: context, initialDate: DateTime.now(),
                                      firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2101)
                                  );

                                  if(pickedDate != null ){
                                    // print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                    // print(formattedDate); //formatted date output using intl package =>  2021-03-16
                                    //you can implement different kind of Date Format here according to your requirement

                                    setState(() {
                                      dobController.text = formattedDate;
                                    });
                                  }else{
                                    // print("Date is not selected");
                                  }
                                },
                              )
                          ),
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

  Widget buildDropDownButtonFormField(List<StaffType>? staffTypes) {
    List<DropdownMenuItem<String>> staffTypeNames = [];
    staffTypeNames = getDropDownMenuItem(staffTypes!);
    return DropdownButtonFormField(
      decoration: const InputDecoration(
        hintText: 'Please select the staff type',
        border: OutlineInputBorder(
          // borderSide: const BorderSide(color: Colors.blue, width: 2),
          // borderRadius: BorderRadius.circular(20),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please select the staff type !';
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

  Future<(bool, String)> _submitRegisterDetails(User currentUser) async {
    String name = staffNameController.text;
    String ic = icController.text;
    String email = emailController.text;
    String? staff_type = selectedValue;
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
      print('staff_type: $staff_type');
      print('phone: $phone');
      print('address: $address');
      print('password: $password');
      print('confirmPw: $confirmPw');
      print('gender: $gender');
      print('dob: $dob');
    }
    String enc_pw = Encryptor().encryptPassword(password);
    var (thisUser, err_code) = await createStaff(name, ic, email, staff_type!, phone, address, enc_pw, gender, dob);
    if (thisUser.uid == -1) {
      if (kDebugMode) {
        print("Failed to retrieve User data.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(User, String)> createStaff(String name, String ic, String email, String staff_type, String phone, String address, String enc_pw, String gender, DateTime dob) async {
    int? staff_type_id;
    if (staff_type == "Restaurant Owner") {
      staff_type_id = 1;
    } else if (staff_type == "Restaurant Manager") {
      staff_type_id = 2;
    } else if (staff_type == "Restaurant Worker") {
      staff_type_id = 3;
    } else {
      staff_type_id = null;
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
          'staff_type': staff_type_id,
          'name': name,
          'email': email,
          'password': enc_pw,
          'address': address,
          'phone': phone,
          'gender': gender,
          'dob': dob.toString(),
          'ic': ic,
          'points': 0,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        var jsonResp = jsonDecode(response.body);
        var jwtToken = jsonResp['token'];
        return (User.fromJWT(jwtToken), (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print(response.body);
          print('User exist in system.');
        }
        return (User(uid: -1, image: '', is_staff: false, is_active: false, staff_type: '', name: '', ic: '', address: '', email: '', gender: '', dob: DateTime.now(), phone: '', points: 0), (ErrorCodes.REGISTER_FAIL_STAFF_EXISTS));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (User(uid: -1, image: '', is_staff: false, is_active: false, staff_type: '', name: '', ic: '', address: '', email: '', gender: '', dob: DateTime.now(), phone: '', points: 0), (ErrorCodes.REGISTER_FAIL_API_CONNECTION));
    }
  }

  // Widget buildReadOnlyDropDownButtonFormField(List<LeaveType>? leaveTypes) {
  //   List<DropdownMenuItem<String>> leaveTypeNames = [];
  //   leaveTypeNames = getDropDownMenuItem(leaveTypes!);
  //   return DropdownButtonFormField(
  //     decoration: const InputDecoration(
  //       hintText: 'Please select the leave',
  //       border: OutlineInputBorder(
  //         // borderSide: const BorderSide(color: Colors.blue, width: 2),
  //         // borderRadius: BorderRadius.circular(20),
  //       ),
  //       filled: true,
  //       fillColor: Colors.white,
  //     ),
  //     validator: (value) {
  //       if (value == null || value.isEmpty) return 'Please select the leave type !';
  //       return null;
  //     },
  //     value: selectedValue,
  //     onChanged: null,
  //     items: leaveTypeNames,
  //   );
  // }

  // Future<(bool, String)> _submitLeaveFormDataDetails(User currentUser) async {
  //   String? leaveType = selectedValue;
  //   DateTime dateFrom = DateTime.parse(dateFromController.text);
  //   DateTime dateTo = DateTime.parse(dateToController.text);
  //   double totalDay = double.parse(totalDayController.text);
  //   String comments = commentsController.text;
  //
  //   if (kDebugMode) {
  //     print('leaveType: $leaveType');
  //     print('dateFrom: $dateFrom');
  //     print('dateTo: $dateTo');
  //     print('totalDay: $totalDay');
  //     print('comments: $comments');
  //   }
  //
  //   var (success, err_code) = await createLeaveFormData(leaveType!, dateFrom, dateTo, totalDay, comments, currentUser);
  //   return (success, err_code);
  // }
  //
  // Future<(bool, String)> createLeaveFormData(String leaveType, DateTime dateFrom, DateTime dateTo, double totalDay, String comments, User currentUser) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://10.0.2.2:8000/leave/leave_form_data'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(<String, dynamic> {
  //         'leaveType': leaveType,
  //         'dateFrom': dateFrom.toString(),
  //         'dateTo': dateTo.toString(),
  //         'totalDay': totalDay,
  //         'comments': comments,
  //         'user_created_id': currentUser.uid,
  //       }),
  //     );
  //
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       if (kDebugMode) {
  //         print("Create Leave Form Data Successful.");
  //       }
  //       return (true, ErrorCodes.OPERATION_OK);
  //     } else {
  //       if (kDebugMode) {
  //         print('Failed to Create Leave Form Data Announcement.');
  //       }
  //       return (false, ErrorCodes.LEAVE_FORM_DATA_CREATE_FAIL_BACKEND);
  //     }
  //   } on Exception catch (e) {
  //     if (kDebugMode) {
  //       print('API Connection Error. $e');
  //     }
  //     return (false, ErrorCodes.LEAVE_FORM_DATA_CREATE_FAIL_API_CONNECTION);
  //   }
  // }
  //
  // Future<(bool, String)> approveLeaveForm(LeaveFormData leaveFormData, User currentUser) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('http://10.0.2.2:8000/leave/update_application/${leaveFormData.id}/'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(<String, dynamic> {
  //         // 'id': leaveFormData.id,
  //         'is_active': !leaveFormData.is_active,
  //         'is_approve': !leaveFormData.is_approve,
  //         'is_reject': leaveFormData.is_reject,
  //       }),
  //     );
  //
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       if (kDebugMode) {
  //         print("Approve Leave Application Successful.");
  //       }
  //       return (true, ErrorCodes.OPERATION_OK);
  //     } else {
  //       if (kDebugMode) {
  //         print('Failed to Approve Leave Application.');
  //       }
  //       return (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_BACKEND);
  //     }
  //   } on Exception catch (e) {
  //     if (kDebugMode) {
  //       print('API Connection Error. $e');
  //     }
  //     return (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_API_CONNECTION);
  //   }
  // }
  //
  // Future<(bool, String)> rejectLeaveForm(LeaveFormData leaveFormData, User currentUser) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('http://10.0.2.2:8000/leave/update_application/${leaveFormData.id}/'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(<String, dynamic> {
  //         // 'id': leaveFormData.id,
  //         'is_active': !leaveFormData.is_active,
  //         'is_approve': leaveFormData.is_approve,
  //         'is_reject': !leaveFormData.is_reject,
  //       }),
  //     );
  //
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       if (kDebugMode) {
  //         print("Reject Leave Application Successful.");
  //       }
  //       return (true, ErrorCodes.OPERATION_OK);
  //     } else {
  //       if (kDebugMode) {
  //         print('Failed to Reject Leave Application.');
  //       }
  //       return (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_BACKEND);
  //     }
  //   } on Exception catch (e) {
  //     if (kDebugMode) {
  //       print('API Connection Error. $e');
  //     }
  //     return (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_API_CONNECTION);
  //   }
  // }
  //
  Future<List<StaffType>> getStaffType() async {
    // String title = titleController.text;
    // String description = descriptionController.text;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/staffManagement/request_type_list'),
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

  // void showConfirmationUpdateDialog(String question, String error, String information, String informationContent, User currentUser, LeaveFormData leaveFormData, String action) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
  //         content: Text(question),
  //         // content: const Text('Are you sure you want to submit the leave form?'),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () async {
  //               // Perform save logic here
  //               // Navigator.of(context).pop();
  //               // Navigator.of(context).pop();
  //               if (_formKey.currentState!.validate()) {
  //                 var (leaveApplicationUpdatedAsync, err_code) = (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_BACKEND);
  //                 if (action == 'Approve') {
  //                   (leaveApplicationUpdatedAsync, err_code) = await approveLeaveForm(leaveFormData, currentUser);
  //                 } else {
  //                   (leaveApplicationUpdatedAsync, err_code) = await rejectLeaveForm(leaveFormData, currentUser);
  //                 }
  //
  //                 setState(() {
  //                   leaveApplicationUpdated = leaveApplicationUpdatedAsync;
  //                   if (!leaveApplicationUpdated) {
  //                     if (err_code == ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_BACKEND) {
  //                       showDialog(context: context, builder: (
  //                           BuildContext context) =>
  //                           AlertDialog(
  //                             title: const Text('Error'),
  //                             content: Text('$error\n\nError Code: $err_code'),
  //                             // content: Text('An Error occurred while trying to create a new leave form data.\n\nError Code: $err_code'),
  //                             actions: <Widget>[
  //                               TextButton(onPressed: () =>
  //                                   Navigator.pop(context, 'Ok'),
  //                                   child: const Text('Ok')),
  //                             ],
  //                           ),
  //                       );
  //                     } else {
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
  //                     }
  //                   } else {
  //                     // If Leave Form Data success created
  //
  //                     Navigator.of(context).pop();
  //                     showDialog(context: context, builder: (
  //                         BuildContext context) =>
  //                         AlertDialog(
  //                           title: Text(information),
  //                           content: Text(informationContent),
  //                           // title: const Text('Create New Leave Form Data Successful'),
  //                           // content: const Text('The Leave Form Data can be viewed in the LA status page.'),
  //                           actions: <Widget>[
  //                             TextButton(
  //                               child: const Text('Ok'),
  //                               onPressed: () {
  //                                 Navigator.push(
  //                                   context,
  //                                   MaterialPageRoute(builder: (context) => ManageLeaveApplicationRequestPage(user: currentUser)),
  //                                 );
  //                               },
  //                             ),
  //                           ],
  //                         ),
  //                     );
  //                     _formKey.currentState?.reset();
  //                     setState(() {
  //                       selectedValue = null;
  //                       dateFromController.text = "";
  //                       dateToController.text = "";
  //                       totalDayController.text = '';
  //                       commentsController.text = '';
  //                     });
  //                   }
  //                 });
  //               }
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
  //
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
                  var (staffCreatedAsync, err_code) = await _submitRegisterDetails(currentUser);
                  setState(() {
                    staffCreated = staffCreatedAsync;
                    if (!staffCreated) {
                      if (err_code == ErrorCodes.LEAVE_FORM_DATA_CREATE_FAIL_BACKEND) {
                        showDialog(context: context, builder: (
                            BuildContext context) =>
                            AlertDialog(
                              title: const Text('Error'),
                              content: Text('An Error occurred while trying to create a new staff.\n\nError Code: $err_code'),
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
                            title: const Text('Create New Staff Successful'),
                            content: const Text('The Staff can be viewed in the Staff List page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CreateStaffPage(user: currentUser)),
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