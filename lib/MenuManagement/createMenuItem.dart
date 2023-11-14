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
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';

import '../Entity/MenuItem.dart';
import '../Entity/Stock.dart';
import '../Entity/User.dart';
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
      home: const CreateMenuItemPage(user: null,),
    );
  }
}

class CreateMenuItemPage extends StatefulWidget {
  const CreateMenuItemPage({super.key, this.user});

  final User? user;

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
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppsBarState().buildDetailsAppBar(context, 'Create Item', currentUser!),
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
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(1, 1, 0, 0)),
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
                          child: Icon(LineAwesomeIcons.camera, color: Colors.grey.shade700),
                        ),
                      ),
                    )
                  ],
                ),
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
                                    child: Center(child: Icon(Icons.fastfood, size: 35,color:Colors.grey.shade600)),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      hintText: "Name",
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
                                    child: Center(child: Icon(Icons.attach_money, size: 35,color:Colors.grey.shade600)),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    controller: priceStandardController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                    ],
                                    decoration: InputDecoration(
                                        hintText: "Price",
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
                                    validator: (priceStandardController) {
                                      if (priceStandardController == null || priceStandardController.isEmpty) return 'Please fill in the PIC !';
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
                                    child: Center(child: Icon(Icons.local_pizza_outlined, size: 35,color:Colors.grey.shade600)),
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
                                      hintText: "Item Class",
                                      hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 16.0, fontWeight: FontWeight.w500),
                                    ),
                                    // value: typeSelected,
                                    items: itemClass!.map((itemClass) {
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
                                    onChanged: (value) {
                                      setState(() {
                                        itemClassSelected = value;
                                        // stockSelected = value;
                                        // stockUpdate = value;
                                      });
                                    },
                                  ),
                                  // ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        FutureBuilder<List<String>>(
                            future: getItemCategoryList(),
                            builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                              if (snapshot.hasData) {
                                return Column(
                                  children: buildItemCategoryList(snapshot.data, currentUser),
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
                                    child: Center(child: Icon(Icons.info_outline, size: 35,color:Colors.grey.shade600)),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    maxLines: null,
                                    controller: descriptionController,
                                    decoration: InputDecoration(
                                        hintText: "Description",
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
                                    validator: (descriptionController) {
                                      if (descriptionController == null || descriptionController.isEmpty) return 'Please fill in the contact of PIC !';
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
                                              'Size',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700,
                                                // fontFamily: 'Rajdhani',
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (hasSize == true || hasSize == false)
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
                                          else
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
                                            });
                                          },
                                        ),
                                        Text(
                                          'Yes',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
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
                                            });
                                          },
                                        ),
                                        Text(
                                          'No',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
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
                                              hintText: 'Enter price for large size',
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
                                          validator: (priceLargeController) {
                                            if (priceLargeController == null || priceLargeController.isEmpty) return 'Please fill in the contact of PIC !';
                                            return null;
                                          },
                                        ),
                                      ),
                                  ],
                                )
                            ),
                          ),
                        ),
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
                                              'Variant',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey.shade700,
                                                // fontFamily: 'Rajdhani',
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          if (hasVariant == true || hasVariant == false)
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
                                          else
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
                                            });
                                          },
                                        ),
                                        Text(
                                          'Yes',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
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
                                            });
                                          },
                                        ),
                                        Text(
                                          'No',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.bold,
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
                                            hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 13.5, fontWeight: FontWeight.w500)
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          validator: (variantController) {
                                            if (variantController == null || variantController.isEmpty) return 'Please fill in the contact of PIC !';
                                            return null;
                                          },
                                        ),
                                      ),
                                  ],
                                )
                            ),
                          ),
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
                        if (_formKey.currentState!.validate() && hasSize != null && hasVariant != null) {
                          showConfirmationCreateDialog(currentUser);
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

  List<Widget> buildItemCategoryList(List<String>? itemCategoryList, User? currentUser) {
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
                  child: Center(child: Icon(Icons.category_outlined, size: 35,color:Colors.grey.shade600)),
                ),
              ),
              Expanded(
                flex: 4,
                // child: Container(
                //   constraints: const BoxConstraints(maxHeight: 120),
                child: DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(20.0),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left:20),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    // focusedBorder: const OutlineInputBorder(
                    //   borderSide: BorderSide(color: Colors.blue),
                    // ),
                    errorBorder: InputBorder.none,
                    hintText: "Category",
                    hintStyle: TextStyle(color:Colors.grey.shade700, fontSize: 16.0, fontWeight: FontWeight.w500),
                  ),
                  // value: categorySelected,
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
                  onChanged: (value) {
                    setState(() {
                      categorySelected = value;
                    });
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

  Future<(bool, String)> _submitCreateMenuItemDetails(User currentUser) async {
    String name = nameController.text;
    String price_standard = priceStandardController.text;
    String price_large = priceLargeController.text;
    String description = descriptionController.text;
    String variants = variantController.text;
    String? itemClass;
    if (itemClassSelected == "Food") {
      itemClass = "F";
    } else if (itemClassSelected == "Drink") {
      itemClass = "D";
    }
    String? category_name = categorySelected;
    bool? hasSize = this.hasSize;
    bool? hasVariant = this.hasVariant;

    if (kDebugMode) {
      print('name: $name');
      print('price_standard: $price_standard');
      print('price_large: $price_large');
      print('description: $description');
      print('variants: $variants');
      print('itemClass: $itemClass');
      print('category_name: $category_name');
      print('hasSize: $hasSize');
      print('hasVariant: $hasVariant');
    }
    var (success, err_code) = await createMenuItem(name, price_standard, price_large, description, variants, itemClass!, category_name!, hasSize!, hasVariant!, currentUser);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to create the menu item.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> createMenuItem(String name, String price_standard, String price_large, String description, String variants, String itemClass, String category_name, bool hasSize, bool hasVariant, User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/menu/create_menu_item'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'image': base64Image,
          'name': name,
          'price_standard': price_standard,
          'price_large': price_large,
          'description': description,
          'isOutOfStock': false,
          'variants': variants,
          'itemClass': itemClass,
          'category_name': category_name,
          'hasSize': hasSize,
          'hasVariant': hasVariant,
          'user_created_name': currentUser.name,
        }),
      );

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
                        showDialog(context: context, builder: (
                            BuildContext context) =>
                            AlertDialog(
                              title: const Text('Error'),
                              content: Text('An Error occurred while trying to create this new menu item (${nameController.text}).\n\nError Code: $err_code'),
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
                                    MaterialPageRoute(builder: (context) => MenuListPage(user: currentUser)),
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