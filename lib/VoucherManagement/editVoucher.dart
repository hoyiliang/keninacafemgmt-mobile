import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;

import 'package:keninacafe/Utils/error_codes.dart';
import 'package:keninacafe/VoucherManagement/voucherAvailableList.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/MenuItem.dart';
import '../Entity/User.dart';
import '../Entity/Voucher.dart';
import '../Entity/VoucherType.dart';
import '../Order/manageOrder.dart';

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
      home: const EditVoucherPage(user: null, voucher: null, streamControllers: null),
    );
  }
}

class EditVoucherPage extends StatefulWidget {
  const EditVoucherPage({super.key, this.user, this.voucher, this.streamControllers});

  final User? user;
  final Voucher? voucher;
  final Map<String,StreamController>? streamControllers;

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
  bool discountControllerEmpty = false;
  bool freeMenuItemFulfill = false;
  bool freeMenuItemControllerEmpty = false;
  bool applicableMenuItemFulfill = false;
  bool applicableMenuItemControllerEmpty = false;
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

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();
    Voucher? currentVoucher = getVoucher();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildDetailsAppBar(context, 'Edit Voucher', currentUser!, widget.streamControllers),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                        children: [
                          const SizedBox(height: 10.0,),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Code', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                    // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: TextFormField(
                              controller: voucherCodeController,
                              decoration: InputDecoration(
                                hintText: 'e.g. Code',
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
                                if (value == null || value.isEmpty) return 'Please fill in the voucher code !';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 13,),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Redeem Point', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                    // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child:
                            TextFormField(
                              controller: redeemPointController,
                              decoration: InputDecoration(
                                hintText: 'e.g. 100',
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
                                if (value == null || value.isEmpty) return 'Please fill in the redeem point needed !';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 13,),
                          const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                              child: Row(
                                  children: [
                                    Text('Voucher Type', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                    // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                  ]
                              )
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: FutureBuilder<List<String>>(
                                future: getVoucherTypeList(),
                                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                      children: [buildVoucherTypeList(snapshot.data)],
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
                          ),
                          const SizedBox(height: 13,),
                          if (voucherTypeSelected != null)
                            const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                                child: Row(
                                    children: [
                                      Text('Details', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                      // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                    ]
                                )
                            ),
                          if (voucherTypeSelected == "Discount")
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: discountControllerEmpty == true ? Colors.red : Colors.grey.shade500,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                    child: Column(
                                      children: [
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
                                                errorBorder: const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.red, // You can change this color
                                                    width: 2, // You can change this thickness
                                                  ),
                                                ),
                                                hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Gabarito")
                                            ),
                                            style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Gabarito"
                                            ),
                                            onChanged: (String value) {
                                              setState(() {
                                                costOffController.text = value;
                                              });
                                            },
                                            // validator: (costOffController) {
                                            //   if (costOffController == null || costOffController.isEmpty) return null;
                                            //   return null;
                                            // },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0),
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
                                                errorBorder: const UnderlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: Colors.red, // You can change this color
                                                    width: 2, // You can change this thickness
                                                  ),
                                                ),
                                                hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Gabarito")
                                            ),
                                            style: TextStyle(
                                                color: Colors.grey.shade700,
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Gabarito"
                                            ),
                                            onChanged: (String value) {
                                              setState(() {
                                                minSpendingController.text = value;
                                              });
                                            },
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
                        ]
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
                          if (voucherTypeSelected == "Discount") {
                            if (minSpendingController.text != "" && costOffController.text != "") {
                              discountControllerEmpty = false;
                            } else {
                              discountControllerEmpty = true;
                            }
                          }
                          if (voucherTypeSelected == "FreeItem") {
                            if (temp_freeMenuItemController.text != "" && freeMenuItemFulfill == true) {
                              freeMenuItemControllerEmpty = false;
                            } else {
                              freeMenuItemControllerEmpty = true;
                            }
                          }
                          if (voucherTypeSelected == "BuyOneFreeOne") {
                            if (temp_applicableMenuItemController.text != "" && applicableMenuItemFulfill == true) {
                              applicableMenuItemControllerEmpty = false;
                            } else {
                              applicableMenuItemControllerEmpty = true;
                            }
                          }
                          if (_formKey.currentState!.validate() && discountControllerEmpty == false && freeMenuItemControllerEmpty == false && applicableMenuItemControllerEmpty == false) {
                            showConfirmationUpdateDialog(currentVoucher!, currentUser);
                          }
                        });
                      },
                      color: Colors.greenAccent.shade400,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: const Text("Update",style: TextStyle(
                          fontWeight: FontWeight.bold,fontSize: 16, color: Colors.white
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

  List<Widget> buildFreeItemDetailsField(List<String>? menuItemList) {
    List<Widget> freeItemDetailsField = [];
    freeItemDetailsField.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: freeMenuItemControllerEmpty == true ? Colors.red : Colors.grey.shade700,
              width: 2.0,
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Column(
                children: [
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
                        child: TextFormField(
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
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red, // You can change this color
                                  width: 2, // You can change this thickness
                                ),
                              ),
                              hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Gabarito")
                          ),
                          controller: temp_freeMenuItemController,
                          focusNode: focusNode,
                          onChanged: (String value) {
                            setState(() {
                              freeMenuItemController.text = value;
                              temp_freeMenuItemController.text = value;
                              if (menuItemList!.contains(value)) {
                                freeMenuItemFulfill = true;
                              } else {
                                freeMenuItemFulfill = false;
                              }
                            });
                          },
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito"
                          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: applicableMenuItemControllerEmpty== true ? Colors.red : Colors.grey.shade700,
              width: 2.0,
            ),
          ),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Column(
                children: [
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
                        child: TextFormField(
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
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.red, // You can change this color
                                  width: 2, // You can change this thickness
                                ),
                              ),
                              hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Gabarito")
                          ),
                          controller: temp_applicableMenuItemController,
                          focusNode: focusNode,
                          onChanged: (String value) {
                            setState(() {
                              applicableMenuItemController.text = value;
                              temp_applicableMenuItemController.text = value;
                              if (menuItemList!.contains(value)) {
                                applicableMenuItemFulfill = true;
                              } else {
                                applicableMenuItemFulfill = false;
                              }
                            });
                          },
                          style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Gabarito"
                          ),
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

  Widget buildVoucherTypeList(List<String>? voucherTypeList) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        // hintText: 'e.g. Discount',
        hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Gabarito"),
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
        if (value == null || value.toString().isEmpty) return 'Please choose the voucher type !';
        return null;
      },
      value: voucherTypeSelected,
      onChanged: (String? newValue) {
        setState(() {
          voucherTypeSelected = newValue!;
          discountControllerEmpty = false;
          freeMenuItemControllerEmpty = false;
          applicableMenuItemControllerEmpty = false;
        });
      },
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
    );
  }


  Future<(bool, String)> _submitUpdateVoucherDetails(Voucher currentVoucher, User currentUser) async {
    String voucherCode = voucherCodeController.text;
    String redeemPoint = redeemPointController.text;
    String costOff;
    String minSpending;
    String freeMenuItemName;
    String applicableMenuItemName;

    if (voucherTypeSelected == "Discount") {
      freeMenuItemName = "";
      applicableMenuItemName = "";
      costOff = costOffController.text;
      minSpending = minSpendingController.text;
    } else if (voucherTypeSelected == "FreeItem") {
      freeMenuItemName = temp_freeMenuItemController.text;
      applicableMenuItemName = "";
      costOff = "";
      minSpending = "";
    } else if (voucherTypeSelected == "BuyOneFreeOne") {
      freeMenuItemName = "";
      applicableMenuItemName = temp_applicableMenuItemController.text;
      costOff = "";
      minSpending = "";
    } else {
      freeMenuItemName = "";
      applicableMenuItemName = "";
      costOff = "";
      minSpending = "";
    }

    if (kDebugMode) {
      print('voucher_code: $voucherCode');
      print('redeem_point: $redeemPoint');
      print('voucher_type_name: $voucherTypeSelected');
      print('cost_off: $costOff');
      print('min_spending: $minSpending');
      print('free_menu_item_name: $freeMenuItemName');
      print('applicable_menu_item_name: $applicableMenuItemName');
    }
    var (success, err_code) = await updateVoucher(voucherCode, redeemPoint, voucherTypeSelected!, costOff, minSpending, freeMenuItemName, applicableMenuItemName, currentVoucher, currentUser);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to update the voucher.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> updateVoucher(String voucherCode, String redeemPoint, String voucherTypeName, String costOff, String minSpending, String freeMenuItemName, String applicableMenuItemName, Voucher currentVoucher, User currentUser) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/order/update_voucher'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'previous_voucher_voucher_code': currentVoucher.voucher_code,
          'voucher_code': voucherCode,
          'redeem_point': redeemPoint,
          'voucher_type_name': voucherTypeName,
          'cost_off': costOff,
          'min_spending': minSpending,
          'free_menu_item_name': freeMenuItemName,
          'applicable_menu_item_name': applicableMenuItemName,
          'user_updated_id': currentUser.uid,
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
        Uri.parse('http://10.0.2.2:8000/menu/request_menu_item_list_with_no_image'),
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
                                    MaterialPageRoute(builder: (context) => VoucherAvailableListPage(user: currentUser, streamControllers: widget.streamControllers)),
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