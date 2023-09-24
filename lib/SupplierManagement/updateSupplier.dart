import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keninacafe/SupplierManagement/supplierListWithDelete.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import '../Entity/Stock.dart';
import '../Entity/Supplier.dart';
import '../Entity/User.dart';
import '../StaffManagement/staffList.dart';
import '../Utils/error_codes.dart';

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
      home: const UpdateSupplierPage(supplier_data: null, user: null,),
    );
  }
}

class UpdateSupplierPage extends StatefulWidget {
  const UpdateSupplierPage({super.key, this.supplier_data, this.user});

  final User? user;
  final Supplier? supplier_data;

  @override
  State<UpdateSupplierPage> createState() => _UpdateSupplierPageState();
}

class _UpdateSupplierPageState extends State<UpdateSupplierPage> {
  final nameController = TextEditingController();
  final PICController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String PIC = "";
  String contact = "";
  String email = "";
  String address = "";
  List stockSelected = [];
  List stockBefore = [];
  List stockUpdated = [];
  ImagePicker picker = ImagePicker();
  Widget? image;
  String base64Image = "";

  User? getUser() {
    return widget.user;
  }

  Supplier? getSupplier(){
    return widget.supplier_data;
  }

  @override
  void initState() {
    super.initState();
    nameController.text = getSupplier()!.name;
    PICController.text = getSupplier()!.PIC;
    contactController.text = getSupplier()!.contact;
    emailController.text = getSupplier()!.email;
    addressController.text = getSupplier()!.address;
  }

  void showConfirmationDialog(Supplier supplierData, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to update the supplier (${supplierData.name})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var (err_code, currentSupplierUpdated) = await _submitUpdateSupplierProfile(supplierData, currentUser);
                  setState(() {
                    name = nameController.text;
                    PIC = PICController.text;
                    contact = contactController.text;
                    email = emailController.text;
                    address = addressController.text;
                    if (err_code == ErrorCodes.UPDATE_SUPPLIER_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error'),
                            content: Text('An Error occurred while trying to update the supplier (${supplierData.name}).\n\nError Code: $err_code'),
                            actions: <Widget>[
                              TextButton(onPressed: () =>
                                  Navigator.pop(context, 'Ok'),
                                  child: const Text('Ok')),
                            ],
                          ),
                      );
                    } else if (err_code == ErrorCodes.UPDATE_SUPPLIER_FAIL_API_CONNECTION){
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
                      Navigator.of(context).pop();
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: Text('Update Supplier (${supplierData.name}) Successful'),
                            // content: const Text('The Leave Form Data can be viewed in the LA status page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
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
                        // name = nameController.text;
                        // PIC = PICController.text;
                        // contact = contactController.text;
                        // email = emailController.text;
                        // address = addressController.text;
                        nameController.text = name;
                        PICController.text = PIC;
                        contactController.text = contact;
                        emailController.text = email;
                        addressController.text = address;
                      });
                    }});
                  // });
                }
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
    Supplier? currentSupplier = getSupplier();

    // nameController.text = currentSupplier!.name;
    // PICController.text = currentSupplier.PIC;
    // contactController.text = currentSupplier.contact;
    // emailController.text = currentSupplier.email;
    // addressController.text = currentSupplier.address;

    if (base64Image == "") {
      base64Image = widget.supplier_data!.image;
      if (base64Image == "") {
        image = Image.asset('images/supplierLogo.jpg');
        print("nothing in base64");
      } else {
        image = Image.memory(base64Decode(base64Image));
      }
    } else {
      image = Image.memory(base64Decode(base64Image));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context),
      appBar: AppsBarState().buildAppBar(context, 'Update Supplier', currentUser!),

      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: image,
                          )
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: SizedBox(
                            width: 35,
                            height: 35,
                            // decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 0, 0, 0)),
                              // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                              onPressed: () async {
                                XFile? imageRaw = await ImagePicker().pickImage(source: ImageSource.gallery);
                                final File imageFile = File(imageRaw!.path);
                                final Image imageImage = Image.file(imageFile);
                                final imageBytes = await imageFile.readAsBytes();
                                setState(() {
                                  base64Image = base64Encode(imageBytes);
                                  if(kDebugMode) {
                                    print(base64Image);
                                  }
                                  image = imageImage;
                                });
                              },
                              child: const Icon(LineAwesomeIcons.camera, color: Colors.black),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Form(
                    key: _formKey,
                    // autovalidateMode: AutovalidateMode.always,
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
                                        if (nameController == null || nameController.isEmpty) {
                                          return 'Please fill in the supplier name !';
                                        }
                                        else {
                                          return null;
                                        }
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
                                        if (addressController == null || addressController.isEmpty) {
                                          return 'Please fill in the company address !';
                                        }
                                        else {
                                          return null;
                                        }
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
                              child: FutureBuilder<Tuple2<List<String>, List<String>>>(
                                  future: getSupplierStockList(currentSupplier!),
                                  builder: (BuildContext context, AsyncSnapshot<Tuple2<List<String>, List<String>>> snapshot) {
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(120.0, 20.0, 120.0, 20.0),
                          child: Container(
                            padding: const EdgeInsets.only(top: 3, left: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xffc9880b),
                                  Color(0xfff77f00),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(40), // Apply border radius here
                            ),
                            child: MaterialButton(
                              minWidth: double.infinity,
                              height: 40,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  showConfirmationDialog(currentSupplier!, currentUser);
                                }
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40), // Apply border radius here
                              ),
                              child: const Text(
                                "Confirm",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
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

  List<Widget> buildStockList(Tuple2<List<String>, List<String>>? listStock, User? currentUser) {

    if (stockUpdated.isNotEmpty) {
      stockSelected = stockUpdated;
    }

    if (name != "" && PIC != "" && contact != "" && email != "" && address != "") {
      nameController.text = name;
      PICController.text = PIC;
      contactController.text = contact;
      emailController.text = email;
      addressController.text = address;
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
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.2)), // Add your decoration here
                  ),
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
                        dataSource: [for (String i in listStock!.item1) {'value': i}],
                        // dataSource: [],
                        textField: 'value',
                        valueField: 'value',
                        okButtonLabel: 'OK',
                        cancelButtonLabel: 'CANCEL',
                        hintWidget: const Text('Please choose one or more stock', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black26)),
                        initialValue: stockSelected,
                        onSaved: (value) {
                          if (value == null) return;
                          setState(() {
                            stockUpdated = value;
                            stockSelected = value;
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

  Future<(String, Supplier)> _submitUpdateSupplierProfile(Supplier currentSupplier, User currentUser) async {
    var (success, err_code) = await updateSupplierProfile(currentSupplier, currentUser);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to delete this supplier.");
      }
      return (err_code, currentSupplier);
    }
    return (err_code, currentSupplier);
  }

  Future<(bool, String)> updateSupplierProfile(Supplier currentSupplier, User currentUser) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/update_supplier_profile/${currentSupplier.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'image': base64Image,
          'name': nameController.text,
          'PIC': PICController.text,
          'contact': contactController.text,
          'email': emailController.text,
          'address': addressController.text,
          'user_updated_name': currentUser.name,
          'stock_updated': stockUpdated,
          'stock_before': stockBefore,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No User found.');
        }
        return (false, (ErrorCodes.UPDATE_SUPPLIER_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_SUPPLIER_FAIL_API_CONNECTION));
    }
  }

  Future<Tuple2<List<String>, List<String>>> getSupplierStockList(Supplier supplierData) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/request_supplier_stock_list/${supplierData.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        stockSelected = Stock.getStockDataListWithSupplier(jsonDecode(response.body)).item2;
        stockBefore = Stock.getStockDataListWithSupplier(jsonDecode(response.body)).item2;
        return Stock.getStockDataListWithSupplier(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the stock list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}