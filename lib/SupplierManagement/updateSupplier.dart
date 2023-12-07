import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keninacafe/SupplierManagement/supplierListWithDelete.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/Stock.dart';
import '../Entity/Supplier.dart';
import '../Entity/User.dart';
import '../Order/manageOrder.dart';
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
      home: const UpdateSupplierPage(supplier_data: null, user: null, streamControllers: null),
    );
  }
}

class UpdateSupplierPage extends StatefulWidget {
  const UpdateSupplierPage({super.key, this.supplier_data, this.user, this.streamControllers});

  final User? user;
  final Supplier? supplier_data;
  final Map<String,StreamController>? streamControllers;

  @override
  State<UpdateSupplierPage> createState() => _UpdateSupplierPageState();
}

class _UpdateSupplierPageState extends State<UpdateSupplierPage> {
  final nameController = TextEditingController();
  final PICController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final stockController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String name = "";
  String PIC = "";
  String contact = "";
  String email = "";
  String address = "";
  bool isNameFill = true;
  bool isPICFill = true;
  bool isContactFill = true;
  bool isEmailFill = true;
  bool isAddressFill = true;
  List stockSelected = [];
  List stockBefore = [];
  List stockUpdated = [];
  ImagePicker picker = ImagePicker();
  Widget? image;
  String base64Image = "";
  bool isHomePage = false;

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
                                    MaterialPageRoute(builder: (context) => SupplierListWithDeletePage(user: currentUser, streamControllers: widget.streamControllers)),
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
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers!),
      appBar: AppsBarState().buildAppBarDetails(context, 'Update Supplier', currentUser, widget.streamControllers),

      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 0),
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
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade200),
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  border: isNameFill ? Border.all(color: Colors.grey.shade600, width: 2.0) : Border.all(color: Colors.red, width: 2.0)
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
                                              right: isNameFill ? BorderSide(color: Colors.grey.shade600, width: 2.0) : const BorderSide(color: Colors.red, width: 2.0)
                                          )
                                      ),
                                      child: Center(child: Icon(Icons.business, size: 35,color:Colors.grey.shade700)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: nameController,
                                      decoration: InputDecoration(
                                          hintText: "Name",
                                          contentPadding: const EdgeInsets.only(left:20, right: 20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 18, fontWeight: FontWeight.bold)
                                      ),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Gabarito",
                                      ),
                                      // validator: (nameController) {
                                      //   if (nameController == null || nameController.isEmpty) return 'Please fill in the supplier name !';
                                      //   return null;
                                      // },
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  border: isPICFill ? Border.all(color: Colors.grey.shade600, width: 2.0) : Border.all(color: Colors.red, width: 2.0)
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
                                              right: isPICFill ? BorderSide(color: Colors.grey.shade600, width: 2.0) : const BorderSide(color: Colors.red, width: 2.0)
                                          )
                                      ),
                                      child: Center(child: Icon(Icons.person, size: 35,color:Colors.grey.shade700)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: PICController,
                                      decoration: InputDecoration(
                                          hintText: "PIC",
                                          contentPadding: const EdgeInsets.only(left:20, right: 20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.bold)
                                      ),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Gabarito",
                                      ),
                                      // validator: (PICController) {
                                      //   if (PICController == null || PICController.isEmpty) return 'Please fill in the PIC !';
                                      //   return null;
                                      // },
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  border: isContactFill ? Border.all(color: Colors.grey.shade600, width: 2.0) : Border.all(color: Colors.red, width: 2.0)
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
                                              right: isContactFill ? BorderSide(color: Colors.grey.shade600, width: 2.0) : const BorderSide(color: Colors.red, width: 2.0)
                                          )
                                      ),
                                      child: Center(child: Icon(Icons.phone_android, size: 35,color:Colors.grey.shade700)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: contactController,
                                      decoration: InputDecoration(
                                          hintText: "Contact",
                                          contentPadding: const EdgeInsets.only(left:20, right: 20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 18, fontWeight: FontWeight.bold)
                                      ),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Gabarito",
                                      ),
                                      // validator: (contactController) {
                                      //   if (contactController == null || contactController.isEmpty) return 'Please fill in the contact of PIC !';
                                      //   return null;
                                      // },
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  border: isEmailFill ? Border.all(color: Colors.grey.shade600, width: 2.0) : Border.all(color: Colors.red, width: 2.0)
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
                                              right: isEmailFill ? BorderSide(color: Colors.grey.shade600, width: 2.0) : const BorderSide(color: Colors.red, width: 2.0)
                                          )
                                      ),
                                      child: Center(child: Icon(Icons.email_outlined, size: 35,color:Colors.grey.shade700)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: emailController,
                                      decoration: InputDecoration(
                                          hintText: "Email",
                                          contentPadding: const EdgeInsets.only(left:20, right: 20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 18, fontWeight: FontWeight.bold)
                                      ),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Gabarito",
                                      ),
                                      // validator: (emailController) {
                                      //   if (emailController == null || emailController.isEmpty) return 'Please fill in the email of PIC !';
                                      //   return null;
                                      // },
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                          child: Container(
                              height: 120,
                              decoration: BoxDecoration(
                                  border: isAddressFill ? Border.all(color: Colors.grey.shade600, width: 2.0) : Border.all(color: Colors.red, width: 2.0)
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
                                              right: isAddressFill ? BorderSide(color: Colors.grey.shade600, width: 2.0) : const BorderSide(color: Colors.red, width: 2.0)
                                          )
                                      ),
                                      child: Center(child: Icon(Icons.location_city, size: 35,color: Colors.grey.shade700)),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: addressController,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                          hintText: "Address",
                                          contentPadding: const EdgeInsets.only(left:20, right: 20, top: 10, bottom: 10),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 18, fontWeight: FontWeight.bold)
                                      ),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Gabarito",
                                      ),
                                      // validator: (addressController) {
                                      //   if (addressController == null || addressController.isEmpty) return 'Please fill in the company address !';
                                      //   return null;
                                      // },
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade600, width: 2.0)
                              ),
                              child: FutureBuilder<List<String>>(
                                  future: getStockUnderSupplierList(currentSupplier!),
                                  builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                    if (snapshot.hasData) {
                                      return Column(
                                        children: buildStockList(snapshot.data, currentUser),
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
                        ),
                        const SizedBox(height: 10,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 100),
                          child: Container(
                            padding: const EdgeInsets.only(top: 3,left: 3),
                            child: MaterialButton(
                              minWidth: double.infinity,
                              height:40,
                              onPressed: (){
                                setState(() {
                                  setState(() {
                                    if (nameController.text == "") {
                                      isNameFill = false;
                                    } else {
                                      isNameFill = true;
                                    }
                                    if (PICController.text == "") {
                                      isPICFill = false;
                                    } else {
                                      isPICFill = true;
                                    }
                                    if (contactController.text == "") {
                                      isContactFill = false;
                                    } else {
                                      isContactFill = true;
                                    }
                                    if (emailController.text == "") {
                                      isEmailFill = false;
                                    } else {
                                      isEmailFill = true;
                                    }
                                    if (addressController.text == "") {
                                      isAddressFill = false;
                                    } else {
                                      isAddressFill = true;
                                    }
                                    if (_formKey.currentState!.validate() && isNameFill && isContactFill && isPICFill && isEmailFill && isAddressFill) {
                                      showConfirmationDialog(currentSupplier, currentUser);
                                    }
                                  });
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
                      ]
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildStockList(List<String>? listStock, User? currentUser) {
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
    if (listStock!.isEmpty) {
      stockController.text = "No stock supplied";
      field.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex:1,
              child: Container(
                height: 50,
                width: 20,
                decoration: BoxDecoration(
                    border: Border(
                        right: BorderSide(color: Colors.grey.shade600, width: 2.0)
                    )
                ),
                child: Center(child: Icon(Icons.inventory, size: 35,color: Colors.grey.shade700)),
              ),
            ),
            Expanded(
              flex: 4,
              child: TextFormField(
                controller: stockController,
                enabled: false,
                maxLines: null,
                decoration: InputDecoration(
                    hintText: "Stock",
                    contentPadding: const EdgeInsets.only(left:20, right: 20, top: 10, bottom: 10),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 18, fontWeight: FontWeight.bold)
                ),
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Gabarito",
                ),
              ),
            )
          ],
        )
      );
    } else {
      field.add(
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 50,
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
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade600, width: 2.0),
                        )
                    ),
                    child: ListView(
                      shrinkWrap: true,
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
                          title: Text(
                            "Stock",
                            style: TextStyle(fontSize: 17, color:Colors.grey.shade700, fontWeight: FontWeight.bold),
                          ),
                          dataSource: [for (String i in listStock) {'value': i}],
                          textField: 'value',
                          valueField: 'value',
                          okButtonLabel: 'OK',
                          cancelButtonLabel: 'CANCEL',
                          hintWidget: Text('Please choose one or more stock', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
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
    }
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

  // Future<Tuple2<List<String>, List<String>>> getSupplierStockList(Supplier supplierData) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('http://10.0.2.2:8000/supplierManagement/request_supplier_stock_list/${supplierData.id}/'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //     );
  //
  //     if (response.statusCode == 201 || response.statusCode == 200) {
  //       stockSelected = Stock.getStockDataListWithSupplier(jsonDecode(response.body)).item2;
  //       stockBefore = Stock.getStockDataListWithSupplier(jsonDecode(response.body)).item2;
  //       return Stock.getStockDataListWithSupplier(jsonDecode(response.body));
  //     } else {
  //       throw Exception('Failed to load the stock list.');
  //     }
  //   } on Exception catch (e) {
  //     throw Exception('API Connection Error. $e');
  //   }
  // }

  Future<List<String>> getStockUnderSupplierList(Supplier currentSupplier) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/request_stock_under_current_supplier_list/${currentSupplier.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        stockSelected = Stock.getStockUnderSupplierList(jsonDecode(response.body));
        stockBefore = Stock.getStockUnderSupplierList(jsonDecode(response.body));
        return Stock.getStockUnderSupplierList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the stock list under current supplier.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}