import 'dart:async';
import 'dart:convert';

import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Announcement/createAnnouncement.dart';
import '../AppsBar.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/User.dart';
import '../Entity/Voucher.dart';
import '../Order/manageOrder.dart';
import '../Utils/error_codes.dart';
import '../Utils/ip_address.dart';
import 'createVoucher.dart';
import 'editVoucher.dart';

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
      home: VoucherAvailableListPage(user: null, streamControllers: null),
    );
  }
}

class VoucherAvailableListPage extends StatefulWidget {
  VoucherAvailableListPage({super.key, this.user, this.streamControllers});

  User? user;
  Map<String,StreamController>? streamControllers;

  @override
  State<VoucherAvailableListPage> createState() => _VoucherAvailableListPageState();
}

class _VoucherAvailableListPageState extends State<VoucherAvailableListPage> {
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
              content: const Text('Are you sure to exit the apps?'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    SystemNavigator.pop();
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
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers!),
        appBar: AppsBarState().buildAppBar(context, 'Voucher List', currentUser, widget.streamControllers!),
        body: SafeArea(
          child: SingleChildScrollView (
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 20.0),
              child: FutureBuilder<List<Voucher>>(
                  future: getAvailableVoucherList(currentUser),
                  builder: (BuildContext context, AsyncSnapshot<List<Voucher>> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: buildAvailableVoucherList(snapshot.data, currentUser),
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
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CreateVoucherPage(user: currentUser, streamControllers: widget.streamControllers))
            );
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
      ),
    );
  }

  List<Widget> buildAvailableVoucherList(List<Voucher>? availableVoucherList, User? currentUser) {
    List<Widget> voucher = [];
    List<Voucher> discountVoucherList = [];
    List<Voucher> freeMenuItemVoucherList = [];
    List<Voucher> buyOneFreeOneVoucherList = [];

    for (int i = 0; i < availableVoucherList!.length; i++) {
      if (availableVoucherList[i].voucher_type_name == "Discount") {
        discountVoucherList.add(availableVoucherList[i]);
      } else if (availableVoucherList[i].voucher_type_name == "FreeItem") {
        freeMenuItemVoucherList.add(availableVoucherList[i]);
      } else if (availableVoucherList[i].voucher_type_name == "BuyOneFreeOne") {
        buyOneFreeOneVoucherList.add(availableVoucherList[i]);
      }
    }

    if (discountVoucherList.isNotEmpty) {
      voucher.add(
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Discount',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25.0,
              fontFamily: 'AsapCondensed',
            ),
          ),
        ),
      );
      voucher.add(const SizedBox(height: 15.0),);
      for (int i = 0; i < discountVoucherList.length; i++) {
        voucher.add(
          CouponCard(
            height: 165,
            backgroundColor: Colors.transparent,
            clockwise: true,
            curvePosition: 65,
            curveRadius: 30,
            curveAxis: Axis.horizontal,
            borderRadius: 10,
            border: const BorderSide(
              color: Colors.grey, // Border color
              width: 3.0, // Border width
            ),
            firstChild: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAB9).withOpacity(0.7),
              ),
              constraints: const BoxConstraints(
                maxHeight: double.infinity,
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Icon(
                      Icons.discount_rounded,
                      size: 35.0,
                      color: Colors.grey.shade800,
                    ),
                    // child: Image.asset(
                    //   "images/voucherLogo.png",
                    //   width: 50,
                    //   height: 60,
                    //   // fit: BoxFit.cover,
                    //   // height: 500,
                    // ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Code : ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              discountVoucherList[i].voucher_code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                '${discountVoucherList[i].redeem_point} points',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3.0,),
                        Row(
                          children: [
                            Text(
                              'MYR ${discountVoucherList[i].cost_off.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5.0,),
                            const Text(
                              'OFF',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            secondChild: Container(
              width: double.maxFinite,
              // padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAB9).withOpacity(0.4),
              ),
              constraints: const BoxConstraints(
                maxHeight: double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Min. Spend : ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'MYR ${discountVoucherList[i].min_spending.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7.0,),
                    Row(
                      children: [
                        Text(
                          'Redemption Left : ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          discountVoucherList[i].num_redeemed.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: discountVoucherList[i].is_available ? Colors.green : Colors.red,),
                              // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                              onPressed: () async {
                                showUpdateIsAvailableConfirmationDialog(discountVoucherList[i]);
                              },
                              child: discountVoucherList[i].is_available
                                  ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18.0,
                              ) : const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18.0,
                              )
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300,),
                            // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                            onPressed: () async {
                              if (discountVoucherList[i].num_redeemed >= 1) {
                                showRedemptionLeftDialog(discountVoucherList[i], "Edit");
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditVoucherPage(user: currentUser, voucher: discountVoucherList[i], streamControllers: widget.streamControllers)),
                                );
                              }
                            },
                            child: Icon(Icons.edit, color: Colors.grey.shade800),
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                            // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                            onPressed: () async {
                              if (discountVoucherList[i].num_redeemed >= 1) {
                                showRedemptionLeftDialog(discountVoucherList[i], "Delete");
                              } else {
                                showDeleteConfirmationDialog(discountVoucherList[i]);
                              }
                            },
                            child: Icon(Icons.delete, color: Colors.grey.shade800),
                          ),
                        ),
                        const SizedBox(width: 5.0,),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        voucher.add(const SizedBox(height: 30.0));
      }
    }

    if (freeMenuItemVoucherList.isNotEmpty) {
      voucher.add(
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Free Menu Item',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25.0,
              fontFamily: 'AsapCondensed',
            ),
          ),
        ),
      );
      voucher.add(const SizedBox(height: 15.0),);
      for (int i = 0; i < freeMenuItemVoucherList.length; i++) {
        voucher.add(
          CouponCard(
            height: 165,
            backgroundColor: Colors.transparent,
            clockwise: true,
            curvePosition: 65,
            curveRadius: 30,
            curveAxis: Axis.horizontal,
            borderRadius: 10,
            border: const BorderSide(
              color: Colors.grey, // Border color
              width: 3.0, // Border width
            ),
            firstChild: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAB9).withOpacity(0.7),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Icon(
                      Icons.discount_rounded,
                      size: 35.0,
                      color: Colors.grey.shade800,
                    ),
                    // child: Image.asset(
                    //   "images/voucherLogo.png",
                    //   width: 50,
                    //   height: 60,
                    //   // fit: BoxFit.cover,
                    //   // height: 500,
                    // ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Code : ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              freeMenuItemVoucherList[i].voucher_code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                '${freeMenuItemVoucherList[i].redeem_point} points',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3.0,),
                        Row(
                          children: [
                            const Text(
                              'Free ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              freeMenuItemVoucherList[i].free_menu_item_name,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            secondChild: Container(
              width: double.maxFinite,
              // padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAB9).withOpacity(0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Min. Spend : ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'MYR ${freeMenuItemVoucherList[i].min_spending.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7.0,),
                    Row(
                      children: [
                        Text(
                          'Redemption Left : ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          freeMenuItemVoucherList[i].num_redeemed.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: freeMenuItemVoucherList[i].is_available ? Colors.green : Colors.red,),
                              // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                              onPressed: () async {
                                showUpdateIsAvailableConfirmationDialog(freeMenuItemVoucherList[i]);
                              },
                              child: freeMenuItemVoucherList[i].is_available
                                  ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18.0,
                              ) : const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18.0,
                              )
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300,),
                            // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                            onPressed: () async {
                              if (freeMenuItemVoucherList[i].num_redeemed >= 1) {
                                showRedemptionLeftDialog(freeMenuItemVoucherList[i], "Edit");
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditVoucherPage(user: currentUser, voucher: freeMenuItemVoucherList[i], streamControllers: widget.streamControllers)),
                                );
                              }
                            },
                            child: Icon(Icons.edit, color: Colors.grey.shade800),
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                            // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                            onPressed: () async {
                              if (freeMenuItemVoucherList[i].num_redeemed >= 1) {
                                showRedemptionLeftDialog(freeMenuItemVoucherList[i], "Delete");
                              } else {
                                showDeleteConfirmationDialog(freeMenuItemVoucherList[i]);
                              }
                            },
                            child: Icon(Icons.delete, color: Colors.grey.shade800),
                          ),
                        ),
                        const SizedBox(width: 5.0,),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        voucher.add(const SizedBox(height: 30.0));
      }
    }

    if (buyOneFreeOneVoucherList.isNotEmpty) {
      voucher.add(
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Buy 1 Free 1',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 25.0,
              fontFamily: 'AsapCondensed',
            ),
          ),
        ),
      );
      voucher.add(const SizedBox(height: 15.0),);
      for (int i = 0; i < buyOneFreeOneVoucherList.length; i++) {
        voucher.add(
          CouponCard(
            height: 165,
            backgroundColor: Colors.transparent,
            clockwise: true,
            curvePosition: 65,
            curveRadius: 30,
            curveAxis: Axis.horizontal,
            borderRadius: 10,
            border: const BorderSide(
              color: Colors.grey, // Border color
              width: 3.0, // Border width
            ),
            firstChild: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAB9).withOpacity(0.7),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                    child: Icon(
                      Icons.discount_rounded,
                      size: 35.0,
                      color: Colors.grey.shade800,
                    ),
                    // child: Image.asset(
                    //   "images/voucherLogo.png",
                    //   width: 50,
                    //   height: 60,
                    //   // fit: BoxFit.cover,
                    //   // height: 500,
                    // ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Code : ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              buyOneFreeOneVoucherList[i].voucher_code,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Text(
                                '${buyOneFreeOneVoucherList[i].redeem_point} points',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3.0,),
                        const Row(
                          children: [
                            Text(
                              'Buy 1 Free 1',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            secondChild: Container(
              width: double.maxFinite,
              // padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAB9).withOpacity(0.4),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 15, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Applicable For ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${buyOneFreeOneVoucherList[i].applicable_menu_item_name} ',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          'Only',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7.0,),
                    Row(
                      children: [
                        Text(
                          'Redemption Left : ',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                       Text(
                          buyOneFreeOneVoucherList[i].num_redeemed.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: buyOneFreeOneVoucherList[i].is_available ? Colors.green : Colors.red,),
                              // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                              onPressed: () async {
                                showUpdateIsAvailableConfirmationDialog(buyOneFreeOneVoucherList[i]);
                              },
                              child: buyOneFreeOneVoucherList[i].is_available
                                  ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18.0,
                              ) : const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18.0,
                              )
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300,),
                            // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                            onPressed: () async {
                              if (buyOneFreeOneVoucherList[i].num_redeemed >= 1) {
                                showRedemptionLeftDialog(buyOneFreeOneVoucherList[i], "Edit");
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditVoucherPage(user: currentUser, voucher: buyOneFreeOneVoucherList[i], streamControllers: widget.streamControllers)),
                                );
                              }
                            },
                            child: Icon(Icons.edit, color: Colors.grey.shade800),
                          ),
                        ),
                        const SizedBox(width: 15.0),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                            // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                            onPressed: () async {
                              if (buyOneFreeOneVoucherList[i].num_redeemed >= 1) {
                                showRedemptionLeftDialog(buyOneFreeOneVoucherList[i], "Delete");
                              } else {
                                showDeleteConfirmationDialog(buyOneFreeOneVoucherList[i]);
                              }
                            },
                            child: Icon(Icons.delete, color: Colors.grey.shade800),
                          ),
                        ),
                        const SizedBox(width: 5.0,),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        voucher.add(const SizedBox(height: 20.0));
      }
    }
    return voucher;
  }

  void showDeleteConfirmationDialog(Voucher currentVoucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to delete this voucher (${currentVoucher.voucher_code})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (err_code, deleteVoucher) = await _submitDeleteVoucher(currentVoucher);
                setState(() {
                  Navigator.of(context).pop();
                  if (err_code == ErrorCodes.DELETE_VOUCHER_FAIL_BACKEND) {
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: Text('An Error occurred while trying to delete the voucher (${currentVoucher.voucher_code}).\n\nError Code: $err_code'),
                          actions: <Widget>[
                            TextButton(onPressed: () =>
                                Navigator.pop(context, 'Ok'),
                                child: const Text('Ok')),
                          ],
                        ),
                    );
                  } else if (err_code == ErrorCodes.DELETE_VOUCHER_FAIL_API_CONNECTION){
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
                          title: const Text('Deleted Voucher Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: Text('This Voucher (${currentVoucher.voucher_code}) has been deleted from the voucher list.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                setState(() {});
                                Navigator.of(context).pop();
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => SupplierListWithDeletePage(user: currentUser)),
                                // );
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

  void showUpdateIsAvailableConfirmationDialog(Voucher currentVoucher) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: currentVoucher.is_available ? Text('Are you sure you want to disable this voucher (${currentVoucher.voucher_code})?') : Text('Are you sure you want to enable this menu item (${currentVoucher.voucher_code})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (err_code, updateIsAvailableStatusAsync) = await _submitIsAvailableStatusVoucher(currentVoucher);
                setState(() {
                  Navigator.of(context).pop();
                  if (err_code == ErrorCodes.UPDATE_IS_AVAILABLE_VOUCHER_STATUS_FAIL_BACKEND) {
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: Text('An Error occurred while trying to update the IsAvailable status of the voucher (${currentVoucher.voucher_code}).\n\nError Code: $err_code'),
                          actions: <Widget>[
                            TextButton(onPressed: () =>
                                Navigator.pop(context, 'Ok'),
                                child: const Text('Ok')),
                          ],
                        ),
                    );
                  } else if (err_code == ErrorCodes.UPDATE_IS_AVAILABLE_VOUCHER_STATUS_FAIL_API_CONNECTION){
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
                          title: currentVoucher.is_available ? const Text('Disabled Voucher Successfully', style: TextStyle(fontWeight: FontWeight.bold,)) : const Text('Enabled Voucher Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: currentVoucher.is_available ? Text('The voucher (${currentVoucher.voucher_code}) has been disabled.') : Text('The voucher (${currentVoucher.voucher_code}) has been enabled.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                setState(() {});
                                Navigator.of(context).pop();
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(builder: (context) => SupplierListWithDeletePage(user: currentUser)),
                                // );
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

  void showRedemptionLeftDialog(Voucher currentVoucher, String action) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: action == "Delete" ? const Text("Voucher can't be deleted", style: TextStyle(fontWeight: FontWeight.bold,)) : const Text("Voucher can't be edited", style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Voucher redeemed by Customer(s) has not been used all.'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<(String, bool)> _submitDeleteVoucher(Voucher currentVoucher) async {
    var (success, err_code) = await deleteVoucher(currentVoucher);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to delete the voucher (${currentVoucher.voucher_code}).");
      }
      return (err_code, success);
    }
    return (err_code, success);
  }


  Future<(bool, String)> deleteVoucher(Voucher currentVoucher) async {
    try {
      final response = await http.put(
        Uri.parse('${IpAddress.ip_addr}/order/delete_voucher'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'id': currentVoucher.id,
        }),

      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No Voucher (${currentVoucher.voucher_code}) found.');
        }
        return (false, (ErrorCodes.DELETE_VOUCHER_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.DELETE_VOUCHER_FAIL_API_CONNECTION));
    }
  }

  Future<(String, bool)> _submitIsAvailableStatusVoucher(Voucher currentVoucher) async {
    bool availableStatusUpdate = !currentVoucher.is_available;
    var (success, err_code) = await updateIsOutOfStockStatusMenuItem(currentVoucher, availableStatusUpdate);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to update Is Available status of the voucher (${currentVoucher.voucher_code}) data.");
      }
      return (err_code, success);
    }
    return (err_code, success);
  }


  Future<(bool, String)> updateIsOutOfStockStatusMenuItem(Voucher currentVoucher, bool availableStatusUpdate) async {
    try {
      final response = await http.put(
        Uri.parse('${IpAddress.ip_addr}/order/update_voucher_status'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'id': currentVoucher.id,
          'is_available': availableStatusUpdate,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No Voucher (${currentVoucher.voucher_code}) found.');
        }
        return (false, (ErrorCodes.UPDATE_IS_AVAILABLE_VOUCHER_STATUS_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_IS_AVAILABLE_VOUCHER_STATUS_FAIL_API_CONNECTION));
    }
  }

  Future<List<Voucher>> getAvailableVoucherList(User currentUser) async {
    try {
      final response = await http.put(
        Uri.parse('${IpAddress.ip_addr}/order/request_all_voucher'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Voucher.getAvailableVoucherList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the available voucher list of the restaurant for the customer(s) to redeem.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }
}