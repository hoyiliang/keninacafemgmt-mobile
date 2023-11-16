import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/Entity/ItemCategory.dart';

import 'package:keninacafe/Utils/error_codes.dart';
import 'package:keninacafe/SupplierManagement/supplierListWithDelete.dart';
import 'package:keninacafe/Security/Encryptor.dart';
import 'package:keninacafe/VoucherManagement/voucherAvailableList.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

import '../Entity/MenuItem.dart';
import '../Entity/Stock.dart';
import '../Entity/User.dart';
import '../Entity/Voucher.dart';
import '../Entity/VoucherType.dart';

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
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        unselectedWidgetColor:Colors.white,
        useMaterial3: true,
      ),
      home: const EditVoucherPage(user: null, voucher: null,),
    );
  }
}

class EditVoucherPage extends StatefulWidget {
  const EditVoucherPage({super.key, this.user, this.voucher});

  final User? user;
  final Voucher? voucher;

  @override
  State<EditVoucherPage> createState() => _EditVoucherPageState();
}

class _EditVoucherPageState extends State<EditVoucherPage> {
  final voucherCodeController = TextEditingController();
  final redeemPointController = TextEditingController();
  final costOffController = TextEditingController();
  final minSpendingController = TextEditingController();
  final applicableMenuItemController = TextEditingController();
  final temp_applicableMenuItemController = TextEditingController();
  final freeMenuItemController = TextEditingController();
  final temp_freeMenuItemController = TextEditingController();
  final freecon = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? voucherTypeSelected;
  String? voucherType;
  bool discountControllerEmpty = true;
  bool freeMenuItemFulfill = false;
  bool freeMenuItemControllerEmpty = true;
  bool applicableMenuItemFulfill = false;
  bool applicableMenuItemControllerEmpty = true;
  bool voucherUpdated = false;


  User? getUser() {
    return widget.user;
  }

  Voucher? getVoucher() {
    return widget.voucher;
  }

  @override
  void initState() {
    super.initState();
    voucherCodeController.text = getVoucher()!.voucher_code;
    redeemPointController.text = getVoucher()!.redeem_point.toStringAsFixed(0);
    voucherTypeSelected = getVoucher()!.voucher_type_name;
    // costOffController.text = getVoucher()!.cost_off.toStringAsFixed(0);
    // minSpendingController.text = getVoucher()!.min_spending.toStringAsFixed(0);
    freeMenuItemController.text = getVoucher()!.free_menu_item_name;
    temp_freeMenuItemController.text = getVoucher()!.free_menu_item_name;
    applicableMenuItemController.text = getVoucher()!.applicable_menu_item_name;
    temp_applicableMenuItemController.text = getVoucher()!.applicable_menu_item_name;
    if (voucherTypeSelected == "Discount") {
      costOffController.text = getVoucher()!.cost_off.toStringAsFixed(0);
      minSpendingController.text = getVoucher()!.min_spending.toStringAsFixed(0);
    } else {
      costOffController.text = "";
      minSpendingController.text = "";
    }
    if (voucherTypeSelected == "Discount") {
      discountControllerEmpty = false;
    } else if (voucherTypeSelected == "FreeItem") {
      freeMenuItemFulfill = true;
      freeMenuItemControllerEmpty = false;
    } else if (voucherTypeSelected == "BuyOneFreeOne") {
      applicableMenuItemFulfill = true;
      applicableMenuItemControllerEmpty = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Voucher? currentVoucher = getVoucher();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildDetailsAppBar(context, 'Edit Voucher', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10,),
                  child: Form(
                    key: _formKey,
                    child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                            child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade700,
                                      width: 2.0,
                                    )
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex:1,
                                      child: Container(
                                        width: 20,
                                        decoration: BoxDecoration(
                                          // color: Colors.white,
                                            border: Border(
                                              right: BorderSide(
                                                color: Colors.grey.shade700,
                                                width: 2.0,
                                              ),
                                            )
                                        ),
                                        child: Center(child: Icon(Icons.discount_outlined, size: 28, color:Colors.grey.shade600)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: TextFormField(
                                        controller: voucherCodeController,
                                        decoration: InputDecoration(
                                          hintText: "Code",
                                          contentPadding: const EdgeInsets.only(left:20),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 16.0, fontWeight: FontWeight.w500),
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
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
                                    border: Border.all(
                                      color: Colors.grey.shade700,
                                      width: 2.0,
                                    )
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
                                                right: BorderSide(
                                                  color: Colors.grey.shade700,
                                                  width: 2.0,
                                                )
                                            )
                                        ),
                                        child: Center(child: Icon(Icons.point_of_sale_sharp, size: 30, color:Colors.grey.shade600)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: TextFormField(
                                        controller: redeemPointController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d*')),
                                        ],
                                        decoration: InputDecoration(
                                            hintText: "Redeem Point",
                                            contentPadding: const EdgeInsets.only(left:20),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 16.0, fontWeight: FontWeight.w500 )
                                        ),
                                        style: TextStyle(
                                          color: Colors.grey.shade700,

                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        validator: (redeemPointController) {
                                          if (redeemPointController == null || redeemPointController.isEmpty) return 'Please fill in the PIC !';
                                          return null;
                                        },
                                      ),
                                    )
                                  ],
                                )
                            ),
                          ),
                          FutureBuilder<List<String>>(
                              future: getVoucherTypeList(),
                              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                if (snapshot.hasData) {
                                  return Column(
                                    children: buildVoucherTypeList(snapshot.data),
                                  );
                                } else {
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else {
                                    return const Center(child: Text('Error: invalid state'));
                                  }
                                }
                              }
                          ),
                          if (voucherTypeSelected == "Discount")
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey.shade700,
                                    width: 2.0,
                                  ),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                                          child: Row(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'Details',
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey.shade700,
                                                    // fontFamily: 'Rajdhani',
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              if (discountControllerEmpty == false)
                                                SizedBox(
                                                  height: 18,
                                                  width: 65,
                                                  child: Material(
                                                    // elevation: 3.0, // Add elevation to simulate a border
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          color: Colors.grey.shade600, // Border color
                                                          width: 2.0, // Border width
                                                        ),
                                                        borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                                      ),
                                                      child: Align(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          "Completed",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 8.0,
                                                            color: Colors.grey.shade700,
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                )
                                              else if (discountControllerEmpty == true)
                                                SizedBox(
                                                  height: 18,
                                                  width: 65,
                                                  child: Material(
                                                      elevation: 3.0, // Add elevation to simulate a border
                                                      shape: RoundedRectangleBorder(
                                                        side: BorderSide(
                                                          color: Colors.red.shade200, // Border color
                                                          width: 2.0, // Border width
                                                        ),
                                                        borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                                      ),
                                                      child: Align(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          "Required",
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 8.0,
                                                            color: Colors.red.shade300,
                                                          ),
                                                        ),
                                                      )
                                                  ),
                                                )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                          child: TextFormField(
                                            controller: costOffController,
                                            maxLines: null,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d*')),
                                            ],
                                            decoration: InputDecoration(
                                                hintText: 'Enter cost off (MYR)',
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.only(bottom: 3),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.shade500,
                                                    width: 2,
                                                  ),
                                                ),
                                                focusedBorder: const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.blue, // You can change this color
                                                    width: 2, // You can change this thickness
                                                  ),
                                                ),
                                                hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 13.5, fontWeight: FontWeight.w500)
                                            ),
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            onChanged: (String value) {
                                              setState(() {
                                                costOffController.text = value;
                                                if (minSpendingController.text != "" && costOffController.text != "") {
                                                  discountControllerEmpty = false;
                                                } else {
                                                  discountControllerEmpty = true;
                                                }
                                              });
                                            },
                                            // validator: (costOffController) {
                                            //   if (costOffController == null || costOffController.isEmpty) return null;
                                            //   return null;
                                            // },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                          child: TextFormField(
                                            controller: minSpendingController,
                                            maxLines: null,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d*')),
                                            ],
                                            decoration: InputDecoration(
                                                hintText: 'Enter min spending (MYR)',
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.only(bottom: 3),
                                                enabledBorder: UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.grey.shade500,
                                                    width: 2,
                                                  ),
                                                ),
                                                focusedBorder: const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.blue, // You can change this color
                                                    width: 2, // You can change this thickness
                                                  ),
                                                ),
                                                hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 13.5, fontWeight: FontWeight.w500)
                                            ),
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            onChanged: (String value) {
                                              setState(() {
                                                minSpendingController.text = value;
                                                if (minSpendingController.text != "" && costOffController.text != "") {
                                                  discountControllerEmpty = false;
                                                } else {
                                                  discountControllerEmpty = true;
                                                }
                                              });
                                            },
                                            // validator: (minSpendingController) {
                                            //   if (minSpendingController == null || minSpendingController.isEmpty) return null;
                                            //   return null;
                                            // },
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                              ),
                            ),
                          if (voucherTypeSelected == "FreeItem")
                            FutureBuilder<List<String>>(
                                future: getMenuItemList(),
                                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: buildFreeItemDetailsField(snapshot.data),
                                    );
                                  } else {
                                    if (snapshot.hasError) {
                                      return Center(child: Text('Error: ${snapshot.error}'));
                                    } else {
                                      return const Center(child: Text('Error: invalid state'));
                                    }
                                  }
                                }
                            ),
                          if (voucherTypeSelected == "BuyOneFreeOne")
                            FutureBuilder<List<String>>(
                                future: getMenuItemList(),
                                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: buildBuyOneFreeOneDetailsField(snapshot.data),
                                    );
                                  } else {
                                    if (snapshot.hasError) {
                                      return Center(child: Text('Error: ${snapshot.error}'));
                                    } else {
                                      return const Center(child: Text('Error: invalid state'));
                                    }
                                  }
                                }
                            ),
                        ]
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 10.0,),
                  child: Container(
                    padding: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.lightBlueAccent,
                      borderRadius: BorderRadius.circular(40.0), // Adjust the radius as needed
                    ),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height:40,
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                          if (voucherTypeSelected == "Discount" && discountControllerEmpty == false || voucherTypeSelected == "FreeItem" && freeMenuItemFulfill == true || voucherTypeSelected == "BuyOneFreeOne" && applicableMenuItemFulfill == true) {
                            showConfirmationUpdateDialog(currentVoucher!, currentUser);
                          }
                        }
                      },
                      // color: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: const Text("Create",style: TextStyle(
                        fontWeight: FontWeight.w600,fontSize: 16,
                      ),),
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }

  List<Widget> buildFreeItemDetailsField(List<String>? menuItemList) {
    List<Widget> freeItemDetailsField = [];
    freeItemDetailsField.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade700,
              width: 2.0,
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              // fontFamily: 'Rajdhani',
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (freeMenuItemControllerEmpty == false && freeMenuItemFulfill == true)
                          SizedBox(
                            height: 18,
                            width: 65,
                            child: Material(
                              // elevation: 3.0, // Add elevation to simulate a border
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.grey.shade600, // Border color
                                    width: 2.0, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Completed",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8.0,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                )
                            ),
                          ),
                        if (freeMenuItemControllerEmpty == true && freeMenuItemFulfill == false)
                          SizedBox(
                            height: 18,
                            width: 65,
                            child: Material(
                                elevation: 3.0, // Add elevation to simulate a border
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.red.shade200, // Border color
                                    width: 2.0, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Required",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8.0,
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                )
                            ),
                          ),
                        if (freeMenuItemControllerEmpty == false && freeMenuItemFulfill == false)
                          SizedBox(
                            height: 18,
                            width: 65,
                            child: Material(
                                elevation: 3.0, // Add elevation to simulate a border
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.red.shade200, // Border color
                                    width: 2.0, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Not Match",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8.0,
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                )
                            ),
                          )
                      ],
                    ),
                  ),
                  RawAutocomplete(
                    optionsBuilder: (freeMenuItemController) {
                      if (freeMenuItemController.text == '') {
                        return const Iterable<String>.empty();
                      } else {
                        List<String> matches = <String>[];
                        matches.addAll(menuItemList!);
                        matches.retainWhere((s){
                          return s.toLowerCase().contains(freeMenuItemController.text.toLowerCase());
                        });
                        return matches;
                      }
                    },

                    onSelected: (String selection) {
                      setState(() {
                        freeMenuItemFulfill = true;
                        temp_freeMenuItemController.text = selection;
                        freeMenuItemController.text = selection;
                      });
                    },

                    fieldViewBuilder: (BuildContext context, freeMenuItemController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Menu Item Free',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(bottom: 3),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade500,
                                width: 2,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          controller: temp_freeMenuItemController,
                          focusNode: focusNode,
                          onChanged: (String value) {
                            setState(() {
                              freeMenuItemController.text = value;
                              if (freeMenuItemController.text != "") {
                                freeMenuItemControllerEmpty = false;
                              } else {
                                freeMenuItemControllerEmpty = true;
                              }
                              if (menuItemList!.contains(value)) {
                                freeMenuItemFulfill = true;
                              } else {
                                freeMenuItemFulfill = false;
                              }
                              print(freeMenuItemController.text);
                              print(applicableMenuItemController.text);
                            });
                          },
                        ),
                      );
                    },

                    optionsViewBuilder: (BuildContext context, void Function(String) onSelected, Iterable<String> options) {
                      return Material(
                          child:SizedBox(
                              height: 200,
                              child:SingleChildScrollView(
                                  child: Column(
                                    children: options.map((opt){
                                      return InkWell(
                                          onTap: (){
                                            onSelected(opt);
                                          },
                                          child:Container(
                                              padding: const EdgeInsets.only(right:60),
                                              child:Card(
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.all(10),
                                                    child:Text(opt),
                                                  )
                                              )
                                          )
                                      );
                                    }).toList(),
                                  )
                              )
                          )
                      );
                    },
                  )
                ],
              )
          ),
        ),
      ),
    );
    return freeItemDetailsField;
  }

  List<Widget> buildBuyOneFreeOneDetailsField(List<String>? menuItemList) {
    List<Widget> buyOneFreeOneDetailsField = [];
    buyOneFreeOneDetailsField.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey.shade700,
              width: 2.0,
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                              // fontFamily: 'Rajdhani',
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (applicableMenuItemControllerEmpty == false && applicableMenuItemFulfill == true)
                          SizedBox(
                            height: 18,
                            width: 65,
                            child: Material(
                              // elevation: 3.0, // Add elevation to simulate a border
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.grey.shade600, // Border color
                                    width: 2.0, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Completed",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8.0,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                )
                            ),
                          ),
                        if (applicableMenuItemControllerEmpty == true && applicableMenuItemFulfill == false)
                          SizedBox(
                            height: 18,
                            width: 65,
                            child: Material(
                                elevation: 3.0, // Add elevation to simulate a border
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.red.shade200, // Border color
                                    width: 2.0, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Required",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8.0,
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                )
                            ),
                          ),
                        if (applicableMenuItemControllerEmpty == false && applicableMenuItemFulfill == false)
                          SizedBox(
                            height: 18,
                            width: 65,
                            child: Material(
                                elevation: 3.0, // Add elevation to simulate a border
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    color: Colors.red.shade200, // Border color
                                    width: 2.0, // Border width
                                  ),
                                  borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                ),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Not Match",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8.0,
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                )
                            ),
                          )
                      ],
                    ),
                  ),
                  RawAutocomplete(
                    optionsBuilder: (applicableMenuItemController) {
                      if (applicableMenuItemController.text == '') {
                        return const Iterable<String>.empty();
                      } else {
                        List<String> matches = <String>[];
                        matches.addAll(menuItemList!);
                        matches.retainWhere((s){
                          return s.toLowerCase().contains(applicableMenuItemController.text.toLowerCase());
                        });
                        return matches;
                      }
                    },

                    onSelected: (String selection) {
                      setState(() {
                        applicableMenuItemFulfill = true;
                        temp_applicableMenuItemController.text = selection;
                        applicableMenuItemController.text = selection;
                      });
                    },

                    fieldViewBuilder: (BuildContext context, applicableMenuItemController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Menu Item Offered',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(bottom: 3),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey.shade500,
                                width: 2,
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blue,
                                width: 2,
                              ),
                            ),
                            hintStyle: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          controller: temp_applicableMenuItemController,
                          focusNode: focusNode,
                          onChanged: (String value) {
                            setState(() {
                              applicableMenuItemController.text = value;
                              if (applicableMenuItemController.text != "") {
                                applicableMenuItemControllerEmpty = false;
                              } else {
                                applicableMenuItemControllerEmpty = true;
                              }
                              if (menuItemList!.contains(value)) {
                                applicableMenuItemFulfill = true;
                              } else {
                                applicableMenuItemFulfill = false;
                              }
                              print(freeMenuItemController.text);
                              print(applicableMenuItemController.text);
                            });
                          },
                        ),
                      );
                    },

                    optionsViewBuilder: (BuildContext context, void Function(String) onSelected, Iterable<String> options) {
                      return Material(
                          child:SizedBox(
                              height: 200,
                              child:SingleChildScrollView(
                                  child: Column(
                                    children: options.map((opt){
                                      return InkWell(
                                          onTap: (){
                                            onSelected(opt);
                                          },
                                          child:Container(
                                              padding: const EdgeInsets.only(right:60),
                                              child:Card(
                                                  child: Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.all(10),
                                                    child:Text(opt),
                                                  )
                                              )
                                          )
                                      );
                                    }).toList(),
                                  )
                              )
                          )
                      );
                    },
                  )
                ],
              )
          ),
        ),
      ),
    );
    return buyOneFreeOneDetailsField;
  }

  List<Widget> buildVoucherTypeList(List<String>? voucherTypeList) {
    List<Widget> field = [];
    // if (listStock != []) {
    field.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
        child: Container(
          height: 50.0,
          decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade700,
                width: 2.0,
              )
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: 20,
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(
                            color: Colors.grey.shade700,
                            width: 2.0,
                          )
                      )
                  ),
                  child: Center(child: Icon(Icons.pie_chart_outline, size: 30,color:Colors.grey.shade600)),
                ),
              ),
              Expanded(
                flex: 4,
                // child: Container(
                //   constraints: const BoxConstraints(maxHeight: 120),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left:20),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: InputBorder.none,
                    hintText: "Voucher Type",
                    hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  value: voucherTypeSelected,
                  items: voucherTypeList!.map((voucherType) {
                    return DropdownMenuItem<String>(
                      value: voucherType,
                      child: Text(
                        voucherType,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 16.0,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      voucherTypeSelected = value;
                      // costOffController.text = "";
                      // minSpendingController.text = "";
                      // freeMenuItemController.text = "";
                      // applicableMenuItemController.text = "";
                      // freecon.text = "";
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please fill in the contact of PIC !';
                    return null;
                  },
                ),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
    // }
    return field;
  }


  Future<(bool, String)> _submitUpdateVoucherDetails(Voucher currentVoucher, User currentUser) async {
    String voucher_code = voucherCodeController.text;
    String redeem_point = redeemPointController.text;
    String cost_off;
    String min_spending;
    String free_menu_item_name;
    String applicable_menu_item_name;

    if (voucherTypeSelected == "Discount") {
      free_menu_item_name = "";
      applicable_menu_item_name = "";
      cost_off = costOffController.text;
      min_spending = minSpendingController.text;
    } else if (voucherTypeSelected == "FreeItem") {
      free_menu_item_name = freeMenuItemController.text;
      applicable_menu_item_name = "";
      cost_off = "";
      min_spending = "";
    } else if (voucherTypeSelected == "BuyOneFreeOne") {
      free_menu_item_name = "";
      applicable_menu_item_name = applicableMenuItemController.text;
      cost_off = "";
      min_spending = "";
    } else {
      free_menu_item_name = "";
      applicable_menu_item_name = "";
      cost_off = "";
      min_spending = "";
    }

    if (kDebugMode) {
      print('voucher_code: $voucher_code');
      print('redeem_point: $redeem_point');
      print('voucher_type_name: $voucherTypeSelected');
      print('cost_off: $cost_off');
      print('min_spending: $min_spending');
      print('free_menu_item_name: $free_menu_item_name');
      print('applicable_menu_item_name: $applicable_menu_item_name');
    }
    var (success, err_code) = await updateVoucher(voucher_code, redeem_point, voucherTypeSelected!, cost_off, min_spending, free_menu_item_name, applicable_menu_item_name, currentVoucher, currentUser);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to update the voucher.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> updateVoucher(String voucher_code, String redeem_point, String voucher_type_name, String cost_off, String min_spending, String free_menu_item_name, String applicable_menu_item_name, Voucher currentVoucher, User currentUser) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/order/update_voucher'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'previous_voucher_voucher_code': currentVoucher.voucher_code,
          'voucher_code': voucher_code,
          'redeem_point': redeem_point,
          'voucher_type_name': voucher_type_name,
          'cost_off': cost_off,
          'min_spending': min_spending,
          'free_menu_item_name': free_menu_item_name,
          'applicable_menu_item_name': applicable_menu_item_name,
          'user_updated_name': currentUser.name,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Update Voucher Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Failed to update voucher.');
        }
        return (false, (ErrorCodes.UPDATE_VOUCHER_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_VOUCHER_FAIL_API_CONNECTION));
    }
  }

  Future<List<String>> getVoucherTypeList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/order/request_voucher_type_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return VoucherType.getVoucherTypeList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the voucher type list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<List<String>> getMenuItemList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/menu/request_menu_item_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return MenuItem.getMenuItemList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the menu item list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  void showConfirmationUpdateDialog(Voucher currentVoucher, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to update this voucher (${currentVoucher.voucher_code})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var (voucherUpdatedAsync, err_code) = await _submitUpdateVoucherDetails(currentVoucher, currentUser);
                  setState(() {
                    voucherUpdated = voucherUpdatedAsync;
                    if (!voucherUpdated) {
                      if (err_code == ErrorCodes.UPDATE_VOUCHER_FAIL_BACKEND) {
                        showDialog(context: context, builder: (
                            BuildContext context) =>
                            AlertDialog(
                              title: const Text('Error'),
                              content: Text('An Error occurred while trying to update this voucher (${currentVoucher.voucher_code}).\n\nError Code: $err_code'),
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
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Update Voucher Successful'),
                            content: Text('The Updated Voucher (${voucherCodeController.text}) can be viewed in the voucher list page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => VoucherAvailableListPage(user: currentUser)),
                                  );
                                },
                              ),
                            ],
                          ),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
                        // nameController.text = '';
                        // priceController.text = '';
                        // descriptionController.text = '';
                        // variantController.text = '';
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