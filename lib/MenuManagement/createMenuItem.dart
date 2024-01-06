import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/Entity/ItemCategory.dart';

import 'package:keninacafe/Utils/error_codes.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/User.dart';
import '../Order/manageOrder.dart';
import 'menuList.dart';

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
      home: const CreateMenuItemPage(user: null, streamControllers: null),
    );
  }
}

class CreateMenuItemPage extends StatefulWidget {
  const CreateMenuItemPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<CreateMenuItemPage> createState() => _CreateMenuItemPageState();
}

class _CreateMenuItemPageState extends State<CreateMenuItemPage> {
  final nameController = TextEditingController();
  final priceStandardController = TextEditingController();
  final priceLargeController = TextEditingController();
  final descriptionController = TextEditingController();
  final variantController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isImageUploaded = false;
  bool? hasSize;
  bool? hasVariant;
  bool hasSizeSelected = true;
  bool hasVariantSelected = true;
  List? category;
  String? categorySelected;
  String? itemClassSelected;
  List<String> itemClass = ['Food', 'Drink'];
  bool menuItemCreated = false;
  bool isSwitched = false;
  ImagePicker picker = ImagePicker();
  String base64Image = "";
  Widget image = const Image(image: AssetImage('images/createMenuItem.png'));

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
    getItemCategoryList();

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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildAppBarDetails(context, 'Create Menu Item', currentUser!, widget.streamControllers),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 15),
                Stack(
                  children: [
                    SizedBox(
                      width: 135,
                      height: 135,
                      child: CircleAvatar(
                        backgroundColor: Colors.grey.shade400,
                        radius: 200,
                        child: Padding(
                          padding: const EdgeInsets.all(15), // Border radius
                          child: ClipOval(child: image),
                        ),
                      )
                      // child: ClipRRect(
                      //     borderRadius: BorderRadius.circular(100),
                      //     child: image
                      // ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade200),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10,),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Menu Item Name', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              hintText: 'e.g. Chicken Rice',
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
                              if (value == null || value.isEmpty) return 'Please fill in the menu item name !';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 13,),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Price (MYR)', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child:
                          TextFormField(
                            controller: priceStandardController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                            ],
                            decoration: InputDecoration(
                              hintText: 'e.g. 10.90',
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
                              if (value == null || value.isEmpty) return 'Please fill in the standard price of menu item !';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 13,),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                          child: Row(
                            children: [
                              Text("Class", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                              // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: DropdownButtonFormField(
                            decoration: InputDecoration(
                              hintText: 'e.g. Food / Drink',
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
                              if (value == null || value.toString().isEmpty) return 'Please choose the menu item class !';
                              return null;
                            },
                            // value: selectedValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                itemClassSelected = newValue;
                              });
                            },
                            items: itemClass.map((itemClass) {
                              return DropdownMenuItem<String>(
                                value: itemClass,
                                child: Text(
                                  itemClass,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 16.0,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 13.0,),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Description', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child:
                          TextFormField(
                            controller: descriptionController,
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'e.g Contains Onion, fish oil....',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20), // Set border radius here
                                borderSide: BorderSide(color: Colors.grey.shade500, width: 2.0,),
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
                              if (value == null || value.isEmpty) return 'Please fill in the menu item description !';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 13,),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                          child: Row(
                            children: [
                              Text("Size", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                              // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: hasSizeSelected == false ? Colors.red : Colors.grey.shade500,
                                width: 2.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Radio(
                                        visualDensity: const VisualDensity(horizontal: -2.0),
                                        value: true,
                                        groupValue: hasSize,
                                        activeColor: Colors.red,
                                        fillColor: MaterialStateProperty.resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.selected)) {
                                              return Colors.red; // Set border color when selected
                                            }
                                            return Colors.grey.shade700;
                                          },
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            hasSize = value;
                                            hasSizeSelected = true;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Yes',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Gabarito"
                                        ),
                                      ),
                                      const SizedBox(width: 10.0,),
                                      Radio(
                                        // contentPadding: EdgeInsets.zero,
                                        visualDensity: const VisualDensity(horizontal: -2.0),
                                        value: false,
                                        groupValue: hasSize,
                                        activeColor: Colors.red,
                                        fillColor: MaterialStateProperty.resolveWith<Color>(
                                              (Set<MaterialState> states) {
                                            if (states.contains(MaterialState.selected)) {
                                              return Colors.red; // Set border color when selected
                                            }
                                            return Colors.grey.shade700; // No border color when unselected
                                          },
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            hasSize = value;
                                            hasSizeSelected = true;
                                          });
                                        },
                                      ),
                                      Text(
                                        'No',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Gabarito"
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (hasSize == true)
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                      child: TextFormField(
                                        controller: priceLargeController,
                                        maxLines: null,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                        ],
                                        decoration: InputDecoration(
                                            hintText: 'Enter price (MYR) for large size',
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
                                        validator: (priceLargeController) {
                                          if (priceLargeController == null || priceLargeController.isEmpty) return 'Please fill in the price large of menu item !';
                                          return null;
                                        },
                                      ),
                                    ),
                                ],
                              )
                            ),
                          ),
                        ),
                        const SizedBox(height: 13,),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                          child: Row(
                            children: [
                              Text("Variant", style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                              // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: hasVariantSelected == false ? Colors.red : Colors.grey.shade500,
                                width: 2.0,
                              ),
                            ),
                            child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Radio(
                                          // contentPadding: EdgeInsets.zero,
                                          visualDensity: const VisualDensity(horizontal: -2.0),
                                          value: true,
                                          groupValue: hasVariant,
                                          activeColor: Colors.red,
                                          fillColor: MaterialStateProperty.resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                              if (states.contains(MaterialState.selected)) {
                                                return Colors.red; // Set border color when selected
                                              }
                                              return Colors.grey.shade700; // No border color when unselected
                                            },
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              hasVariant = value;
                                              hasVariantSelected = true;
                                            });
                                          },
                                        ),
                                        Text(
                                          'Yes',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Gabarito"
                                          ),
                                        ),
                                        const SizedBox(width: 10.0,),
                                        Radio(
                                          // contentPadding: EdgeInsets.zero,
                                          visualDensity: const VisualDensity(horizontal: -2.0),
                                          value: false,
                                          groupValue: hasVariant,
                                          activeColor: Colors.red,
                                          fillColor: MaterialStateProperty.resolveWith<Color>(
                                                (Set<MaterialState> states) {
                                              if (states.contains(MaterialState.selected)) {
                                                return Colors.red; // Set border color when selected
                                              }
                                              return Colors.grey.shade700; // No border color when unselected
                                            },
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              hasVariant = value;
                                              hasVariantSelected = true;
                                            });
                                          },
                                        ),
                                        Text(
                                          'No',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Gabarito"
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (hasVariant == true)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 0),
                                        child: TextFormField(
                                          controller: variantController,
                                          maxLines: null,
                                          decoration: InputDecoration(
                                            hintText: 'Enter variant',
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
                                          validator: (variantController) {
                                            if (variantController == null || variantController.isEmpty) return 'Please fill in the variant of menu item !';
                                            return null;
                                          },
                                        ),
                                      ),
                                  ],
                                )
                            ),
                          ),
                        ),
                        const SizedBox(height: 13,),
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Category', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),),
                                  // Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: FutureBuilder<List<String>>(
                                future: getItemCategoryList(),
                                builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [buildItemCategoryList(snapshot.data, currentUser)]
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
                          if (hasSize == null) {
                            hasSizeSelected = false;
                          }
                          if (hasVariant == null) {
                            hasVariantSelected = false;
                          }
                          if (base64Image == "") {
                            isImageUploaded = false;
                            showImageNotSelectedDialog();
                          }
                          if (_formKey.currentState!.validate() && isImageUploaded && hasSizeSelected && hasVariantSelected) {
                            showConfirmationCreateDialog(currentUser);
                          }
                        });
                      },
                      color: Colors.lightBlueAccent.shade400,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: const Text("Create",style: TextStyle(
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

  void showImageNotSelectedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Image Not Selected', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: const Text('Please select the menu item image !'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Widget buildItemCategoryList(List<String>? itemCategoryList, User? currentUser) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        // hintText: 'e.g. Restaurant Worker',
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
        if (value == null || value.toString().isEmpty) return 'Please choose the menu item category !';
        return null;
      },
      // value: selectedValue,
      onChanged: (String? newValue) {
        setState(() {
          categorySelected = newValue;
        });
      },
      items: itemCategoryList!.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(
            category,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 16.0,
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<(bool, String)> _submitCreateMenuItemDetails(User currentUser) async {
    String name = nameController.text;
    String priceStandard = priceStandardController.text;
    String priceLarge = priceLargeController.text;
    String description = descriptionController.text;
    String variants = variantController.text;
    String? itemClass;
    if (itemClassSelected == "Food") {
      itemClass = "F";
    } else if (itemClassSelected == "Drink") {
      itemClass = "D";
    }
    String? categoryName = categorySelected;
    bool? hasSize = this.hasSize;
    bool? hasVariant = this.hasVariant;

    if (kDebugMode) {
      print('name: $name');
      print('price_standard: $priceStandard');
      print('price_large: $priceLarge');
      print('description: $description');
      print('variants: $variants');
      print('itemClass: $itemClass');
      print('category_name: $categoryName');
      print('hasSize: $hasSize');
      print('hasVariant: $hasVariant');
    }
    var (success, err_code) = await createMenuItem(name, priceStandard, priceLarge, description, variants, itemClass!, categoryName!, hasSize!, hasVariant!, currentUser);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to create the menu item.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> createMenuItem(String name, String priceStandard, String priceLarge, String description, String variants, String itemClass, String categoryName, bool hasSize, bool hasVariant, User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/menu/create_menu_item'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'image': base64Image,
          'name': name,
          'price_standard': priceStandard,
          'price_large': priceLarge,
          'description': description,
          'isOutOfStock': false,
          'variants': variants,
          'itemClass': itemClass,
          'category_name': categoryName,
          'hasSize': hasSize,
          'hasVariant': hasVariant,
          'user_created_id': currentUser.uid,
        }),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Create Menu Item Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Failed to create menu item.');
        }
        if (responseData['message'] == "Menu Item is existing.") {
          return (false, (ErrorCodes.CREATE_SAME_MENU_ITEM));
        }
        return (false, (ErrorCodes.CREATE_MENU_ITEM_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.CREATE_MENU_ITEM_FAIL_API_CONNECTION));
    }
  }

  Future<List<String>> getItemCategoryList() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/menu/request_all_item_category'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // stock = Stock.getStockNameList(jsonDecode(response.body));
        return ItemCategory.getAllItemCategory(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the list contain all item category.');
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
          content: Text('Are you sure you want to create this menu item (${nameController.text})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var (menuItemCreatedAsync, err_code) = await _submitCreateMenuItemDetails(currentUser);
                  setState(() {
                    menuItemCreated = menuItemCreatedAsync;
                    if (!menuItemCreated) {
                      if (err_code == ErrorCodes.CREATE_MENU_ITEM_FAIL_BACKEND) {
                        showDialog(
                          context: context, builder: (BuildContext context) =>
                            AlertDialog(
                              title: const Text('Error'),
                              content: Text(
                                  'An Error occurred while trying to create this new menu item (${nameController
                                      .text}).\n\nError Code: $err_code'),
                              actions: <Widget>[
                                TextButton(onPressed: () =>
                                    Navigator.pop(context, 'Ok'),
                                    child: const Text('Ok')),
                              ],
                            ),
                        );
                      } else if (err_code == ErrorCodes.CREATE_SAME_MENU_ITEM) {
                        showDialog(
                          context: context, builder: (BuildContext context) =>
                            AlertDialog(
                              title: const Text('Menu Item Exists'),
                              content: Text('Please double check the menu item list.\n\nError Code: $err_code'),
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
                            title: const Text('Create New Menu Item Successful'),
                            content: Text('The Menu Item (${nameController.text}) can be viewed in the menu.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => MenuListPage(user: currentUser, streamControllers: widget.streamControllers)),
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