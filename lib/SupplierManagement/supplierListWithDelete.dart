import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/SupplierManagement/createSupplier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keninacafe/SupplierManagement/updateSupplier.dart';
import 'package:keninacafe/SupplierManagement/viewSupplierDetails.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import '../Entity/Stock.dart';
import '../Entity/User.dart';
import '../Entity/Supplier.dart';
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
      home: const SupplierListWithDeletePage(user: null,),
    );
  }
}

class SupplierListWithDeletePage extends StatefulWidget {
  const SupplierListWithDeletePage({super.key, this.user});

  final User? user;

  @override
  State<SupplierListWithDeletePage> createState() => _SupplierListWithDeletePageState();
}

class _SupplierListWithDeletePageState extends State<SupplierListWithDeletePage> {
  final nameController = TextEditingController();
  final PICController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ImagePicker picker = ImagePicker();
  Widget? image;
  String base64Image = "";

  User? getUser() {
    return widget.user;
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
                            // content: const Text(''),
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
                    }
                  });
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


  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context),
      appBar: AppsBarState().buildAppBar(context, 'Supplier List', currentUser!),

      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: FutureBuilder<List<Supplier>>(
                      future: getSupplierList(),
                      builder: (BuildContext context, AsyncSnapshot<List<Supplier>> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: buildSupplierList(snapshot.data, currentUser),
                          );
                        } else {
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            return const Center(child: Text('Loading....'));
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
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => CreateSupplierPage(user: currentUser))
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
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
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey, width: 4.0),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    // padding: const EdgeInsets.all(16.0),
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 16.0),
                      child: ClipRRect(
                        child: image
                      )
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            a.name,
                            style: const TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                    text: 'PIC: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.transparent,
                                      // shadows: [Shadow(color: Colors.black, offset: Offset(0, -4))],
                                    )
                                ),

                                TextSpan(
                                  text: a.PIC,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                    text: 'Contact: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.transparent,
                                      // shadows: [Shadow(color: Colors.black, offset: Offset(0, -4))],
                                    )
                                ),

                                TextSpan(
                                  text: a.contact,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                    text: 'Email: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.transparent,
                                      // shadows: [Shadow(color: Colors.black, offset: Offset(0, -4))],
                                    )
                                ),

                                TextSpan(
                                  text: a.email,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(
                                    text: 'Address: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.transparent,
                                      // shadows: [Shadow(color: Colors.black, offset: Offset(0, -4))],
                                    )
                                ),

                                TextSpan(
                                  text: a.address,
                                  style: const TextStyle(
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye),
                                onPressed: () {
                                  showPopupViewSupplierDetails(a, currentUser!);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => UpdateSupplierPage(supplier_data: a, user: currentUser))
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  showDeleteConfirmationDialog(a, currentUser!);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
    return cards;
  }

  Future<List<Supplier>> getSupplierList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/request_supplier_list'),
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
}