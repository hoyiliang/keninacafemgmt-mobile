import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;

import 'package:keninacafe/Utils/error_codes.dart';
import 'package:keninacafe/SupplierManagement/supplierListWithDelete.dart';
import 'package:keninacafe/Security/Encryptor.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

import '../Entity/Stock.dart';
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
  final nameController = TextEditingController();
  final PICController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isImageUploaded = false;
  List? stockUpdate;
  List? stockSelected;
  List? stock;
  // List<String> stock = [];
  bool supplierCreated = false;
  double containerHeight = 120;
  ImagePicker picker = ImagePicker();
  String base64Image = "";
  Widget image = Image(image: AssetImage('images/supplierLogo.jpg'));

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
    getStockList();
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

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
                              isImageUploaded = true;
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2) )
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex:1,
                                    child: Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              right: BorderSide(color: Colors.grey.withOpacity(0.2))
                                          )
                                      ),
                                      child: Center(child: Icon(Icons.business, size: 35,color:Colors.grey.withOpacity(0.4))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: nameController,
                                      decoration: const InputDecoration(
                                          hintText: "Name",
                                          contentPadding: EdgeInsets.only(left:20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.black26, fontSize: 18, fontWeight: FontWeight.w500 )
                                      ),
                                      validator: (nameController) {
                                        if (nameController == null || nameController.isEmpty) return 'Please fill in the supplier name !';
                                        return null;
                                      },
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2) )
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex:1,
                                    child: Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              right: BorderSide(color: Colors.grey.withOpacity(0.2))
                                          )
                                      ),
                                      child: Center(child: Icon(Icons.person, size: 35,color:Colors.grey.withOpacity(0.4))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: PICController,
                                      decoration: const InputDecoration(
                                          hintText: "PIC",
                                          contentPadding: EdgeInsets.only(left:20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.black26, fontSize: 18, fontWeight: FontWeight.w500 )
                                      ),
                                      validator: (PICController) {
                                        if (PICController == null || PICController.isEmpty) return 'Please fill in the PIC !';
                                        return null;
                                      },
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2) )
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex:1,
                                    child: Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              right: BorderSide(color: Colors.grey.withOpacity(0.2))
                                          )
                                      ),
                                      child: Center(child: Icon(Icons.phone_android, size: 35,color:Colors.grey.withOpacity(0.4))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: contactController,
                                      decoration: const InputDecoration(
                                          hintText: "Contact",
                                          contentPadding: EdgeInsets.only(left:20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.black26, fontSize: 18, fontWeight: FontWeight.w500 )
                                      ),
                                      validator: (contactController) {
                                        if (contactController == null || contactController.isEmpty) return 'Please fill in the contact of PIC !';
                                        return null;
                                      },
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2) )
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex:1,
                                    child: Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              right: BorderSide(color: Colors.grey.withOpacity(0.2))
                                          )
                                      ),
                                      child: Center(child: Icon(Icons.email_outlined, size: 35,color:Colors.grey.withOpacity(0.4))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                          hintText: "Email",
                                          contentPadding: EdgeInsets.only(left:20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.black26, fontSize: 18, fontWeight: FontWeight.w500 )
                                      ),
                                      validator: (emailController) {
                                        if (emailController == null || emailController.isEmpty) return 'Please fill in the email of PIC !';
                                        return null;
                                      },
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2) )
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex:1,
                                    child: Container(
                                      width: 20,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              right: BorderSide(color: Colors.grey.withOpacity(0.2))
                                          )
                                      ),
                                      child: Center(child: Icon(Icons.location_city, size: 35,color:Colors.grey.withOpacity(0.4))),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: addressController,
                                      decoration: const InputDecoration(
                                          hintText: "Address",
                                          contentPadding: EdgeInsets.only(left:20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.black26, fontSize: 18, fontWeight: FontWeight.w500 )
                                      ),
                                      validator: (addressController) {
                                        if (addressController == null || addressController.isEmpty) return 'Please fill in the company address !';
                                        return null;
                                      },
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2) )
                              ),
                              child: FutureBuilder<List<String>>(
                                  future: getStockList(),
                                  builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                    if (snapshot.hasData) {
                                      return Column(
                                        children: buildStockList(snapshot.data, currentUser),
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
                        ),
                      ]
                    ),
                  ),
                ),

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

  List<Widget> buildStockList(List<String>? listStock, User? currentUser) {
    if (stockSelected != []) {
      stockSelected = [];
    }


    List<Widget> field = [];
    // if (listStock != []) {
    field.add(
      Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: 20,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.withOpacity(0.2)),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.inventory,
                      size: 35,
                      color: Colors.grey.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: ListView(
                    shrinkWrap: true, // Allow ListView to take up only as much height as needed
                    children: [
                      MultiSelectFormField(
                        autovalidate: AutovalidateMode.disabled,
                        chipBackGroundColor: Colors.grey,
                        chipLabelStyle: const TextStyle(fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 12),
                        dialogTextStyle: const TextStyle(fontWeight: FontWeight.bold),
                        checkBoxActiveColor: Colors.blue,
                        checkBoxCheckColor: Colors.white,
                        dialogShapeBorder: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0))),
                        title: const Text(
                          "Stock",
                          style: TextStyle(fontSize: 17, color:Colors.black26, fontWeight: FontWeight.w500),
                        ),
                        // validator: (value) {
                        //   if (value == null || value.length == 0) {
                        //     return 'Please select one or more options';
                        //   }
                        //   return null;
                        // },
                        dataSource: [for (String i in listStock!) {'value': i}],

                        textField: 'value',
                        valueField: 'value',
                        okButtonLabel: 'OK',
                        cancelButtonLabel: 'CANCEL',
                        hintWidget: const Text('Please choose one or more stock', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black26)),
                        initialValue: stockSelected,
                        onSaved: (value) {
                          if (value == null) return;
                          setState(() {
                            stockSelected = value;
                            stockUpdate = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
        ),
      );
    // }
    return field;
  }

  Future<(bool, String)> _submitRegisterDetails(User currentUser) async {
    String name = nameController.text;
    String PIC = PICController.text;
    String contact = contactController.text;
    String email = emailController.text;
    String address = addressController.text;

    if (kDebugMode) {
      print('name: $name');
      print('PIC: $PIC');
      print('contact: $contact');
      print('email: $email');
      print('address: $address');
    }
    var (success, err_code) = await createSupplier(name, PIC, email, contact, address, currentUser);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to retrieve User data.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> createSupplier(String name, String PIC, String email, String contact, String address, User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/create_supplier'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'image': base64Image,
          'is_active': true,
          'name': name,
          'PIC': PIC,
          'contact': contact,
          'email': email,
          'address': address,
          'stock': stockUpdate,
          'user_created_name': currentUser.name,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Create Supplier Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Failed to create supplier.');
        }
        return (false, (ErrorCodes.REGISTER_FAIL_SUPPLIER_EXISTS));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.REGISTER_FAIL_SUPPLIER_API_CONNECTION));
    }
  }

  Future<List<String>> getStockList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/request_stock_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // stock = Stock.getStockNameList(jsonDecode(response.body));
        return Stock.getStockNameList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the stock list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
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
                      Navigator.of(context).pop();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => SupplierListWithDeletePage(user: currentUser)),
                      // );
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Create New Supplier Successful'),
                            content: const Text('The Supplier can be viewed in the Supplier List page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SupplierListWithDeletePage(user: currentUser)),
                                  );

                                },
                              ),
                            ],
                          ),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
                        nameController.text = '';
                        PICController.text = '';
                        emailController.text = '';
                        contactController.text = '';
                        addressController.text = '';
                        stockSelected = [];
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