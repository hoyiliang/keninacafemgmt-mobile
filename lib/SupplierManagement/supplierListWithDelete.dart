import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/SupplierManagement/createSupplier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keninacafe/SupplierManagement/updateSupplier.dart';
import 'package:keninacafe/SupplierManagement/viewSupplierDetails.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/Stock.dart';
import '../Entity/User.dart';
import '../Entity/Supplier.dart';
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
      home: const SupplierListWithDeletePage(user: null, streamControllers: null),
    );
  }
}

class SupplierListWithDeletePage extends StatefulWidget {
  const SupplierListWithDeletePage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<SupplierListWithDeletePage> createState() => _SupplierListWithDeletePageState();
}

class _SupplierListWithDeletePageState extends State<SupplierListWithDeletePage> {
  final nameController = TextEditingController();
  final PICController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final stockNameController = TextEditingController();
  final supplierNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool stockCreated = false;
  ImagePicker picker = ImagePicker();
  Widget? image;
  String base64Image = "";
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

  void showPopupViewSupplierDetails(Supplier supplierData, User currentUser) {
    nameController.text = supplierData.name;
    PICController.text = supplierData.PIC;
    contactController.text = supplierData.contact;
    emailController.text = supplierData.email;
    addressController.text = supplierData.address;

    if (base64Image == "") {
      base64Image = supplierData.image;
      if (base64Image == "") {
        image = Image.asset('images/supplierLogo.jpg');
        print("nothing in base64");
      } else {
        image = Image.memory(base64Decode(base64Image));
      }
    } else {
      image = Image.memory(base64Decode(base64Image));
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints.loose(Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height * 0.75)),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (BuildContext builder) {
        return ViewSupplierDetailsPage(supplier: supplierData, user: currentUser);
        // return UpdateSupplierPage(supplier_data: supplierData, user: currentUser);
      },
    );
  }

  void showButtonCreateToChooseDialog(List<Supplier> supplierList, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              const Text('Create', style: TextStyle(fontSize: 23.5, fontFamily: "Itim", fontWeight: FontWeight.bold,),),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 2.0, vertical: 0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      Navigator.of(context).pop();
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.grey.shade300,
                      // border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    // padding: const EdgeInsets.all(1),
                    child: Icon(
                      Icons.close_outlined,
                      size: 25.0,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ]
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 122.0,
                height: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.deepPurple.shade400,
                  // border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                ),
                child: MaterialButton(
                  // minWidth: double.infinity,
                  height:40,
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CreateSupplierPage(user: currentUser, streamControllers: widget.streamControllers))
                    );
                  },
                  // color: Colors.red,
                  child: const Text(
                    "Supplier",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20.0),
              Container(
                width: 122.0,
                height: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.deepPurple.shade400,
                  borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
                ),
                child: MaterialButton(
                  // minWidth: double.infinity,
                  height:40,
                  onPressed: () {
                    showCreateStockForm(supplierList);
                  },
                  child: const Text(
                    "Stock",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showCreateStockForm(List<Supplier> supplierList) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
              children: [
                const Text('Create', style: TextStyle(fontSize: 23.5,
                  fontFamily: "Gabarito",
                  fontWeight: FontWeight.bold,),),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        stockNameController.text = '';
                        supplierNameController.text = '';
                        Navigator.of(context).pop();
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey.shade300,
                        // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      // padding: const EdgeInsets.all(1),
                      child: Icon(
                        Icons.close_outlined,
                        size: 25.0,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              ]
          ),
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: stockNameController,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                  ],
                  onChanged: (text) {
                    setState(() {
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Stock',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    errorBorder: OutlineInputBorder( // Border style for error state
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.red,
                        width: 2.0,),
                    ),
                    // hintText: 'Please enter your email',
                    // hintStyle: TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gabarito",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the stock name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Supplier',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    errorBorder: OutlineInputBorder( // Border style for error state
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.red,
                        width: 2.0,),
                    ),
                    // hintText: 'Please enter your email',
                    // hintStyle: TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Gabarito",
                  ),
                  validator: (value) {
                    if (value == null || value.toString().isEmpty) return 'Please choose the supplier !';
                    return null;
                  },
                  onChanged: (String? newValue) {
                    setState(() {
                      supplierNameController.text = newValue!;
                    });
                  },
                  items: supplierList.map((supplier) {
                    return DropdownMenuItem<String>(
                      value: supplier.name,
                      child: Text(
                        supplier.name,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  showConfirmationCreateDialog();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
              ),
              child: const Text(
                'Confirm',
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

  void showConfirmationCreateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to create this stock? (${stockNameController.text})'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var (stockCreatedAsync, err_code) = await _submitStockDetails();
                  setState(() {
                    stockCreated = stockCreatedAsync;
                    if (!stockCreated) {
                      if (err_code == ErrorCodes.CREATE_STOCK_ASSIGNED_OTHER_FAIL_BACKEND) {
                        showDialog(context: context, builder: (
                            BuildContext context) =>
                            AlertDialog(
                              title: const Text('Error'),
                              content: Text('This stock (${stockNameController.text}) has been assigned to other supplier, please check in the supplier list.\n\nError Code: $err_code'),
                              actions: <Widget>[
                                TextButton(onPressed: () =>
                                    Navigator.pop(context, 'Ok'),
                                    child: const Text('Ok')),
                              ],
                            ),
                        );
                      } else if (err_code == ErrorCodes.CREATE_STOCK_ASSIGNED_CURRENT_FAIL_BACKEND) {
                        showDialog(context: context, builder: (
                            BuildContext context) =>
                            AlertDialog(
                              title: const Text('Error'),
                              content: Text('This stock (${stockNameController.text}) has been assigned to this supplier, please check in the supplier list.\n\nError Code: $err_code'),
                              actions: <Widget>[
                                TextButton(onPressed: () =>
                                    Navigator.pop(context, 'Ok'),
                                    child: const Text('Ok')),
                              ],
                            ),
                        );
                      } else if (err_code == ErrorCodes.CREATE_STOCK_FAIL_BACKEND) {
                        showDialog(context: context, builder: (
                            BuildContext context) =>
                            AlertDialog(
                              title: const Text('Error'),
                              content: Text('An Error occurred while trying to create a new stock (${stockNameController.text}).\n\nError Code: $err_code'),
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
                            title: const Text('Create New Stock Successful'),
                            content: const Text('The Stock assigned can be viewed in the Supplier List page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  setState(() {

                                  });
                                },
                              ),
                            ],
                          ),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
                        stockNameController.text = '';
                        supplierNameController.text = '';
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

  void showDeleteConfirmationDialog(Supplier supplierData, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to delete this supplier (${supplierData.name})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                  var (err_code, currentUserUpdated) = await _submitDeleteSupplier(supplierData);
                  setState(() {
                    if (err_code == ErrorCodes.DELETE_SUPPLIER_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error'),
                            content: Text('An Error occurred while trying to delete the supplier (${supplierData.name}).\n\nError Code: $err_code'),
                            actions: <Widget>[
                              TextButton(onPressed: () =>
                                  Navigator.pop(context, 'Ok'),
                                  child: const Text('Ok')),
                            ],
                          ),
                      );
                    } else if (err_code == ErrorCodes.DELETE_SUPPLIER_FAIL_API_CONNECTION){
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
                            title: Text('Delete Supplier (${supplierData.name}) Successful'),
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
                    }
                  });
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

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers!),
      appBar: AppsBarState().buildSupplierManagementAppBarDetails(context, 'Supplier List', currentUser, widget.streamControllers),

      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: FutureBuilder<List<Supplier>>(
                      future: getActiveSupplierList(),
                      builder: (BuildContext context, AsyncSnapshot<List<Supplier>> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: buildSupplierList(snapshot.data, currentUser),
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
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigator.of(context).push(
          //     MaterialPageRoute(builder: (context) => CreateSupplierPage(user: currentUser))
          // );
          List<Supplier> supplierList = await getActiveSupplierList();
          showButtonCreateToChooseDialog(supplierList, currentUser);
        },
        child: const Icon(
          Icons.add,
          size: 27.0,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 20.0,
        color: Theme.of(context).colorScheme.inversePrimary,
        shape: const CircularNotchedRectangle(),
      ),
    );
  }

  List<Widget> buildSupplierList(List<Supplier>? listSupplier, User? currentUser) {
    List<Widget> cards = [];
    cards.add(
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      ),
    );
    for (Supplier a in listSupplier!) {
      if (a.is_active == true) {
        if (a.image == "") {
          image = Image.asset('images/supplierLogo.jpg', width: 100, height: 100,);
        } else {
          image = Image.memory(base64Decode(a.image), width: 100, height: 100,);
        }
        cards.add(
          Card(
            child: Container(
              height: 192,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey, width: 4.0),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  a.name,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.grey.shade900,
                                    fontFamily: "YoungSerif",
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15.0,),
                          Align(
                            alignment: Alignment.topLeft,
                            child: FutureBuilder<List<String>>(
                                future: getStockUnderSupplierList(a),
                                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: buildStockUnderSupplierList(snapshot.data),
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
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 5.0,),
                        Row(
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                              child:
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                                // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                onPressed: () async {
                                  showPopupViewSupplierDetails(a, currentUser!);
                                },
                                child: Icon(Icons.remove_red_eye, color: Colors.grey.shade800),
                              ),
                            ),
                            const SizedBox(width: 13.0),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                                // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                onPressed: () async {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => UpdateSupplierPage(supplier_data: a, user: currentUser, streamControllers: widget.streamControllers))
                                  );
                                },
                                child: Icon(Icons.edit, color: Colors.grey.shade800),
                              ),
                            ),
                            const SizedBox(width: 13.0),
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                                // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                onPressed: () async {
                                  showDeleteConfirmationDialog(a, currentUser!);
                                },
                                child: Icon(Icons.delete, color: Colors.grey.shade800),
                              ),
                            ),
                            const SizedBox(width: 5.0,),
                          ],
                        ),
                        const SizedBox(height: 18.0,),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: a.image == "" ? Image.asset('images/menuItem.png', width: 100, height: 100,) : Image.memory(base64Decode(a.image), width: 100, height: 100,)
                        ),
                      ],
                    )
                  ),
                ],
              ),
            ),
          ),
        );
        cards.add(const SizedBox(height: 10,));
      }
    }
    return cards;
  }

  List<Widget> buildStockUnderSupplierList (List<String>? stockNameList) {
    List<Widget> text = [];
    text.add(
      Text(
        'Stock Supplied List :',
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.grey.shade900,
          fontFamily: "BreeSerif",
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.clip,
      ),
    );
    if (stockNameList!.isEmpty) {
      text.add(
        const SizedBox(height: 5.0,),
      );
      text.add(
        Text(
          'No supplied stock !',
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey.shade900,
            fontFamily: "BreeSerif",
            // fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      for (int i = 0; i < stockNameList.length; i++) {
        text.add(
          Text(
            stockNameList[i],
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey.shade900,
              fontFamily: "BreeSerif",
              // fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.clip,
          ),
        );
      }
    }
    return text;
  }

  Future<List<Supplier>> getActiveSupplierList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/request_active_supplier_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Supplier.getSupplierDataList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the supplier list.');
      }
    } on Exception catch (e) {
        throw Exception('API Connection Error. $e');
    }
  }

  Future<List<String>> getStockUnderSupplierList(Supplier currentSupplier) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/request_stock_under_current_supplier_list/${currentSupplier.id}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Stock.getStockUnderSupplierList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the stock list under current supplier.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<(String, Supplier)> _submitDeleteSupplier(Supplier currentSupplier) async {
    var (bool, err_code) = await deleteStaffProfile(currentSupplier);
    if (bool == true) {
      if (kDebugMode) {
        print("Failed to delete Supplier (${currentSupplier.name}) data.");
      }
      return (err_code, currentSupplier);
    }
    return (err_code, currentSupplier);
  }

  Future<(bool, String)> deleteStaffProfile(Supplier supplierData) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/delete_supplier/${supplierData.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'is_active': false,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No Supplier (${supplierData.name}) found.');
        }
        return (false, (ErrorCodes.DELETE_SUPPLIER_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.DELETE_SUPPLIER_FAIL_API_CONNECTION));
    }
  }

  Future<(bool, String)> _submitStockDetails() async {
    String stockName = stockNameController.text;
    String supplierName = supplierNameController.text;

    if (kDebugMode) {
      print('stockName: $stockName');
      print('supplierName: $supplierName');
    }
    var (success, err_code) = await createStock(stockName, supplierName);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to create stock data.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> createStock(String stockName, String supplierName) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/create_stock'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'stock_name': stockName,
          'supplier_name': supplierName,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Create Stock Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        var jsonResp = jsonDecode(response.body);
        var error = jsonResp['error'];
        if (kDebugMode) {
          print(response.body);
          print('Failed to create stock.');
        }
        print(error);
        if (error == "stock is assigned to other supplier.") {
          return (false, (ErrorCodes.CREATE_STOCK_ASSIGNED_OTHER_FAIL_BACKEND));
        } else if (error == "stock is created before for this supplier.") {
          return (false, (ErrorCodes.CREATE_STOCK_ASSIGNED_CURRENT_FAIL_BACKEND));
        } else {
          return (false, (ErrorCodes.CREATE_STOCK_FAIL_BACKEND));
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.CREATE_STOCK_FAIL_API_CONNECTION));
    }
  }
}