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
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:tuple/tuple.dart';
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
      home: const ViewSupplierDetailsPage(user: null, supplier: null),
    );
  }
}

class ViewSupplierDetailsPage extends StatefulWidget {
  const ViewSupplierDetailsPage({super.key, this.user, this.supplier});

  final User? user;
  final Supplier? supplier;

  @override
  State<ViewSupplierDetailsPage> createState() => _ViewSupplierDetailsPageState();
}

class _ViewSupplierDetailsPageState extends State<ViewSupplierDetailsPage> {
  final nameController = TextEditingController();
  final PICController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String>? stockSelected;
  ImagePicker picker = ImagePicker();
  Widget? image;
  String base64Image = "";

  User? getUser() {
    return widget.user;
  }

  Supplier? getSupplier() {
    return widget.supplier;
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Supplier? currentSupplier = getSupplier();

    nameController.text = currentSupplier!.name;
    PICController.text = currentSupplier.PIC;
    contactController.text = currentSupplier.contact;
    emailController.text = currentSupplier.email;
    addressController.text = currentSupplier.address;

    if (base64Image == "") {
      base64Image = currentSupplier.image;
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
      appBar: AppsBarState().buildViewSupplierDetailsAppBar(context, '${currentSupplier?.name} Supplier'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              children: [
                // Container(
                //   height: 80,
                //   width: MediaQuery.of(context).size.width,
                //   decoration: BoxDecoration(
                //     color: Colors.yellow.withOpacity(0.2),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Padding(
                //         padding: const EdgeInsets.only(left: 16.0),
                //         child: SizedBox(
                //           width: 298,
                //           child: Text (
                //             '${currentSupplier?.name} Supplier',
                //             softWrap: true,
                //             maxLines: 1,
                //             style: const TextStyle(
                //               fontSize: 25,
                //               fontWeight: FontWeight.w700,
                //               overflow: TextOverflow.ellipsis,
                //               color: Colors.black54,
                //               fontStyle: FontStyle.italic,
                //               fontFamily: "Helvetica",
                //             ),
                //           ),
                //         ),
                //       ),
                //       IconButton(
                //         icon: const Icon(Icons.close), // Add your close button icon
                //         onPressed: () {
                //           Navigator.of(context).pop();
                //           setState(() {
                //             base64Image = "";
                //             if(kDebugMode) {
                //               print(base64Image);
                //             }
                //             // image = imageImage;
                //           });
                //         },
                //       ),
                //     ],
                //   ),
                // ),
                Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                      // Container(
                      //   height: 80,
                      //   width: MediaQuery.of(context).size.width,
                      //   decoration: BoxDecoration(
                      //     color: Colors.yellow.withOpacity(0.2),
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.only(left: 16.0),
                      //         child: SizedBox(
                      //           width: 298,
                      //           child: Text (
                      //             '${currentSupplier?.name} Supplier',
                      //             softWrap: true,
                      //             maxLines: 1,
                      //             style: const TextStyle(
                      //               fontSize: 25,
                      //               fontWeight: FontWeight.w700,
                      //               overflow: TextOverflow.ellipsis,
                      //               color: Colors.black54,
                      //               fontStyle: FontStyle.italic,
                      //               fontFamily: "Helvetica",
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       IconButton(
                      //         icon: const Icon(Icons.close), // Add your close button icon
                      //         onPressed: () {
                      //           Navigator.of(context).pop();
                      //           setState(() {
                      //             base64Image = "";
                      //             if(kDebugMode) {
                      //               print(base64Image);
                      //             }
                      //             // image = imageImage;
                      //           });
                      //         },
                      //       ),
                      //     ],
                      //   ),
                      // ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                          child: Stack(
                            children: [
                              SizedBox(
                                width: 120,
                                height: 120,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: image
                                ),
                              ),
                            ],
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
                                    child: Center(child: Icon(Icons.business, size: 35,color:Colors.grey.withOpacity(0.4))),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    controller: nameController,
                                    enabled: false,
                                    decoration: const InputDecoration(
                                        hintText: "Name",
                                        contentPadding: EdgeInsets.only(left:20),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        hintStyle: TextStyle(color:Colors.black26, fontSize: 18, fontWeight: FontWeight.w500 )
                                    ),
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
                                      enabled: false,
                                      decoration: const InputDecoration(
                                          hintText: "PIC",
                                          contentPadding: EdgeInsets.only(left:20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.black26, fontSize: 18, fontWeight: FontWeight.w500 )
                                      ),
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
                                      enabled: false,
                                      decoration: const InputDecoration(
                                          hintText: "Contact",
                                          contentPadding: EdgeInsets.only(left:20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.black26, fontSize: 18, fontWeight: FontWeight.w500 )
                                      ),
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
                                      enabled: false,
                                      decoration: const InputDecoration(
                                          hintText: "Email",
                                          contentPadding: EdgeInsets.only(left:20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.black26, fontSize: 18, fontWeight: FontWeight.w500 )
                                      ),
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
                                      enabled: false,
                                      decoration: const InputDecoration(
                                          hintText: "Address",
                                          contentPadding: EdgeInsets.only(left:20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.black26, fontSize: 18, fontWeight: FontWeight.w500 )
                                      ),
                                    ),
                                  )
                                ],
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.withOpacity(0.2) )
                              ),
                              child: FutureBuilder<Tuple2<List<String>, List<String>>>(
                                  future: getSupplierCurrentStockList(currentSupplier!),
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
                        )
                      ],
                    ),
                  ),
                ),
                // ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser!, context),
    );
  }

  List<Widget> buildStockList(Tuple2<List<String>, List<String>>? listStock, User? currentUser) {
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
                        enabled: false,
                        chipBackGroundColor: Colors.grey,
                        chipLabelStyle: const TextStyle(fontWeight: FontWeight.w500,
                            color: Colors.black26,
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
                        textField: 'value',
                        valueField: 'value',
                        okButtonLabel: 'OK',
                        cancelButtonLabel: 'CANCEL',
                        hintWidget: const Text('Do not supply any stock', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black26)),
                        initialValue: stockSelected,
                        onSaved: (value) {
                          if (value == null) return;
                          setState(() {
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

  Future<Tuple2<List<String>, List<String>>> getSupplierCurrentStockList(Supplier supplierData) async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/request_supplier_stock_list/${supplierData.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        stockSelected = Stock.getStockDataListWithSupplier(jsonDecode(response.body)).item2;
        return Stock.getStockDataListWithSupplier(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the stock list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}