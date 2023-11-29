import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/Entity/StockReceipt.dart';
import 'package:keninacafe/SupplierManagement/stockReceiptList.dart';
import 'package:keninacafe/SupplierManagement/supplierDashboard.dart';
import 'dart:typed_data';

import 'package:keninacafe/Utils/error_codes.dart';
import 'package:keninacafe/SupplierManagement/supplierListWithDelete.dart';
import 'package:keninacafe/Security/Encryptor.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:keninacafe/Utils/multiselect_formfield_fixed.dart';
import 'package:file_picker/file_picker.dart';

import '../Entity/Stock.dart';
import '../Entity/Supplier.dart';
import '../Entity/User.dart';

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
      home: const EditStockReceiptPage(user: null, stockReceipt: null, pdfFile: null,),
    );
  }
}

class EditStockReceiptPage extends StatefulWidget {
  const EditStockReceiptPage({super.key, this.user, this.stockReceipt, this.pdfFile,});

  final User? user;
  final StockReceipt? stockReceipt;
  final Uint8List? pdfFile;

  @override
  State<EditStockReceiptPage> createState() => _EditStockReceiptPageState();
}

class _EditStockReceiptPageState extends State<EditStockReceiptPage> {
  final receiptNumberController = TextEditingController();
  final totalPriceController = TextEditingController();
  final supplierNameController = TextEditingController();
  final supplierNameBeforeController = TextEditingController();
  final dateReceiptController = TextEditingController();
  final pdfFileNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isReceiptNumberFill = true;
  bool isTotalPriceFill = true;
  bool isSupplierNameFill = true;
  bool isStockSelected = true;
  bool isFileUploaded = false;
  bool isDateSelected = true;
  List? stockUpdate;
  List? stockSelected;
  String tempStockSupplier = "";
  String currentStockSupplier = "";
  String base64File = "";
  List? stock;
  bool receiptCreated = false;
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  StockReceipt? getStockReceipt() {
    return widget.stockReceipt;
  }

  Uint8List? getPdfFileBytes() {
    return widget.pdfFile;
  }

  @override
  void initState() {
    super.initState();
    receiptNumberController.text = getStockReceipt()!.receipt_number;
    totalPriceController.text = getStockReceipt()!.price.toStringAsFixed(2);
    supplierNameController.text = getStockReceipt()!.supplier_name;
    supplierNameBeforeController.text = getStockReceipt()!.supplier_name;
    pdfFileNameController.text = getStockReceipt()!.pdf_file_name;
    dateReceiptController.text = getStockReceipt()!.date_receipt.toString().substring(0,10);
    base64File = base64Encode(getPdfFileBytes()!);
    getStockWithSupplierList();
  }

  void showConfirmationDialog(StockReceipt currentStockReceipt, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to update the receipt (${receiptNumberController.text})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var (err_code, currentSupplierUpdated) = await _submitUpdateReceiptDetails(currentStockReceipt, currentUser);
                  setState(() {
                    if (err_code == ErrorCodes.UPDATE_RECEIPT_FAIL_BACKEND) {
                      showDialog(context: context, builder: (
                          BuildContext context) =>
                          AlertDialog(
                            title: const Text('Error'),
                            content: Text('An Error occurred while trying to update the receipt (${receiptNumberController.text}).\n\nError Code: $err_code'),
                            actions: <Widget>[
                              TextButton(onPressed: () =>
                                  Navigator.pop(context, 'Ok'),
                                  child: const Text('Ok')),
                            ],
                          ),
                      );
                    } else if (err_code == ErrorCodes.UPDATE_RECEIPT_FAIL_API_CONNECTION){
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
                            title: Text('Update Receipt (${receiptNumberController.text}) Successful'),
                            // content: const Text('The Leave Form Data can be viewed in the LA status page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => StockReceiptListPage(user: currentUser)),
                                  );
                                },
                              ),
                            ],
                          ),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
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
    StockReceipt? currentStockReceipt = getStockReceipt();
    Uint8List? currentPdfFileBytes = getPdfFileBytes();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage),
      appBar: AppsBarState().buildAppBarDetails(context, 'Stock Receipt', currentUser!),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 7.0, 0, 0),
                            child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    border: isReceiptNumberFill ? Border.all(color: Colors.grey.shade600, width: 2.0) : Border.all(color: Colors.red, width: 2.0)
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
                                                right: isReceiptNumberFill ? BorderSide(color: Colors.grey.shade600, width: 2.0) : const BorderSide(color: Colors.red, width: 2.0)
                                            )
                                        ),
                                        child: Center(child: Icon(Icons.receipt_long_outlined, size: 35, color:Colors.grey.shade700)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: TextFormField(
                                        controller: receiptNumberController,
                                        decoration: InputDecoration(
                                            hintText: "Receipt No.",
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
                                border: isDateSelected
                                    ? Border.all(color: Colors.grey.shade600, width: 2.0)
                                    : Border.all(color: Colors.red, width: 2.0),
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
                                          right: isDateSelected
                                              ? BorderSide(color: Colors.grey.shade600, width: 2.0)
                                              : const BorderSide(color: Colors.red, width: 2.0),
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.calendar_month,
                                            size: 35, color: Colors.grey.shade700),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: TextFormField(
                                      controller: dateReceiptController,
                                      decoration: InputDecoration(
                                        hintText: "Date Receipt",
                                        contentPadding: const EdgeInsets.only(left: 20, right: 20),
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Gabarito",
                                      ),
                                      readOnly: true,
                                      onTap: () async {
                                        var pickedDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime(2101),
                                        );
                                        if (pickedDate != null) {
                                          String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                          setState(() {
                                            dateReceiptController.text = formattedDate;
                                          });
                                        }
                                        // DateTime selectedDate = DateTime.now();
                                        // var pickedDate = await showDatePicker(
                                        //   context: context,
                                        //   initialDate: selectedDate,
                                        //   firstDate: DateTime(2000),
                                        //   lastDate: DateTime(2101),
                                        // );
                                        // if (pickedDate != null) {
                                        //   final TimeOfDay? pickedTime = await showTimePicker(
                                        //     context: context,
                                        //     initialTime: TimeOfDay.now(),
                                        //   );
                                        //
                                        //   if (pickedTime != null) {
                                        //     selectedDate = DateTime(
                                        //       pickedDate.year,
                                        //       pickedDate.month,
                                        //       pickedDate.day,
                                        //       pickedTime.hour,
                                        //       pickedTime.minute,
                                        //     );
                                        //
                                        //     String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(selectedDate);
                                        //     setState(() {
                                        //       if (dateReceiptController.text != "") {
                                        //         isStockSelected = false;
                                        //         isDateSelectedChange = false;
                                        //       }
                                        //       dateReceiptController.text = formattedDateTime;
                                        //       isDateSelected = true;
                                        //     });
                                        //   }
                                        // }
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          FutureBuilder<List<Supplier>>(
                              future: getSupplierList(),
                              builder: (BuildContext context, AsyncSnapshot<List<Supplier>> snapshot) {
                                if (snapshot.hasData) {
                                  return Column(
                                    children: [buildSupplierList(snapshot.data, currentStockReceipt, currentUser)],
                                  );
                                } else {
                                  if (snapshot.hasError) {
                                    return Center(child: Text('Error: ${snapshot.error}'));
                                  } else {
                                    return const Center(child: Text('Loading'));
                                  }
                                }
                              }
                          ),
                          if (supplierNameController.text != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: isStockSelected ? Border.all(color: Colors.grey.shade600, width: 2.0) : Border.all(color: Colors.red, width: 2.0)
                                  ),
                                  child: FutureBuilder<List<Stock>>(
                                      future: getStockWithSupplierList(),
                                      builder: (BuildContext context, AsyncSnapshot<List<Stock>> snapshot) {
                                        if (snapshot.hasData) {
                                          return Column(
                                            children: buildStockList(snapshot.data, currentStockReceipt, currentUser),
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

                          if (supplierNameController.text != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                              child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: isTotalPriceFill ? Border.all(color: Colors.grey.shade600, width: 2.0) : Border.all(color: Colors.red, width: 2.0)
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
                                                  right: isTotalPriceFill ? BorderSide(color: Colors.grey.shade600, width: 2.0) : const BorderSide(color: Colors.red, width: 2.0)
                                              )
                                          ),
                                          child: Center(child: Icon(Icons.attach_money, size: 35,color:Colors.grey.shade700)),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: TextFormField(
                                          controller: totalPriceController,
                                          decoration: InputDecoration(
                                              hintText: "Total Price (MYR)",
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
                                        ),
                                      )
                                    ],
                                  )
                              ),
                          ),

                          if (supplierNameController.text != null)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade600, width: 2.0)
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
                                            right: BorderSide(color: Colors.grey.shade600, width: 2.0)
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.description,
                                            size: 35,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: TextButton(
                                        onPressed: () async {
                                          FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                                          final File file = File(result!.files.single.path!);
                                          final fileBytes = await file.readAsBytes();
                                          if (result != null) {
                                            setState(() {
                                              base64File = base64Encode(fileBytes);
                                              pdfFileNameController.text = file!.path.split('/').last;
                                              isFileUploaded = true;
                                            });
                                            print('Selected file: ${file?.path}');
                                          }
                                        },
                                        child: Padding(
                                            padding: const EdgeInsets.fromLTRB(8.0, 5, 0, 0),
                                            child: Align(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                pdfFileNameController.text != "" ? pdfFileNameController.text : "Select PDF File",
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            )
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                          if (receiptNumberController.text == "") {
                            isReceiptNumberFill = false;
                          } else {
                            isReceiptNumberFill = true;
                          }
                          if (totalPriceController.text == "") {
                            isTotalPriceFill = false;
                          } else {
                            isTotalPriceFill = true;
                          }
                          if (supplierNameController.text == "" || supplierNameController.text == "Stocks Under Diff Supplier") {
                            isSupplierNameFill = false;
                          } else {
                            isSupplierNameFill = true;
                          }
                          if (stockSelected!.isEmpty) {
                            isStockSelected = false;
                          } else {
                            isStockSelected = true;
                          }
                          if (dateReceiptController.text == "") {
                            isDateSelected = false;
                          } else {
                            isDateSelected = true;
                          }
                          if (_formKey.currentState!.validate() && isReceiptNumberFill && isTotalPriceFill && isSupplierNameFill && isStockSelected) {
                            showConfirmationDialog(currentStockReceipt!, currentUser);
                          }
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSupplierList(List<Supplier>? supplierList, StockReceipt? currentStockReceipt, User? currentUser) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
      child: Container(
          height: 50,
          decoration: BoxDecoration(
              border: isSupplierNameFill ? Border.all(color: Colors.grey.shade600, width: 2.0) : Border.all(color: Colors.red, width: 2.0)
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
                          right: isSupplierNameFill ? BorderSide(color: Colors.grey.shade600, width: 2.0) : const BorderSide(color: Colors.red, width: 2.0)
                      )
                  ),
                  child: Center(child: Icon(Icons.business, size: 35,color:Colors.grey.shade700)),
                ),
              ),
              Expanded(
                flex: 4,
                child: DropdownButtonFormField<String>(
                  value: supplierNameController.text,
                  decoration: InputDecoration(
                      hintText: "Supplier",
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
                  validator: (value) {
                    if (value == null || value.toString().isEmpty) return 'Please choose the supplier !';
                    return null;
                  },
                  onChanged: (String? newValue) {
                    setState(() {
                      supplierNameController.text = newValue!;
                      stockSelected = [];
                      stockUpdate = [];
                      currentStockReceipt = getStockReceipt();
                    });
                  },
                  items: supplierList!.map((supplier) {
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
              )
            ],
          )
      ),
    );
  }

  List<Widget> buildStockList(List<Stock>? listStock, StockReceipt? currentStockReceipt, User? currentUser) {
    List<Widget> field = [];
    print(supplierNameController.text);
    print(supplierNameBeforeController.text);
    print(supplierNameController.text == supplierNameBeforeController.text);
    // if (supplierNameController.text == supplierNameBeforeController.text) {
    //   stockSelected = currentStockReceipt!.stock_name;
    // }
    stockSelected = currentStockReceipt!.stock_name;
    // print(stockSelected == []);
    // for (String s in stockSelected!) {
    //   print(s);
    // }
    // print(stockUpdate == []);
    // for (String s in stockUpdate!) {
    //   print(s);
    // }
    // stockSelected = currentStockReceipt!.stock_name;
    // stockUpdate = currentStockReceipt!.stock_name;
    if (stockUpdate != null) {
      stockSelected = stockUpdate;
    }
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
                          left: isStockSelected ? BorderSide(color: Colors.grey.shade600, width: 2.0) : const BorderSide(color: Colors.red, width: 2.0)
                      )
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      MultiSelectFormField(
                        key: UniqueKey(),
                        autovalidate: AutovalidateMode.disabled,
                        chipBackGroundColor: Colors.grey.shade400,
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
                          style: TextStyle(fontSize: 17, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                        ),
                        dataSource: [for (Stock i in listStock!) {'value': i.name}],
                        textField: 'value',
                        valueField: 'value',
                        okButtonLabel: 'OK',
                        cancelButtonLabel: 'CANCEL',
                        hintWidget: Text('Please choose one or more stock', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
                        initialValue: stockSelected,
                        onSaved: (value) {
                          setState(() {
                            stockSelected = value;
                            stockUpdate = value;
                            tempStockSupplier = "";
                            isStockSelected = true;
                            // if (stockSelected!.isEmpty) {
                            //   supplierNameController.text = "";
                            //   return;
                            // }
                            // for (int i = 0; i < stockSelected!.length; i++) {
                            //   String selectedStockName = stockSelected![i];
                            //   Stock? selectedStock;
                            //
                            //   try {
                            //     selectedStock = listStock!.firstWhere((stock) => stock.name == selectedStockName);
                            //   } catch (e) {
                            //     if (kDebugMode) {
                            //       print('Stock not found for name: $selectedStockName');
                            //     }
                            //   }
                            //
                            //   if (selectedStock != null) {
                            //     if (i == 0) {
                            //       tempStockSupplier = selectedStock.supplier_name;
                            //       currentStockSupplier = selectedStock.supplier_name;
                            //       supplierNameController.text = selectedStock.supplier_name;
                            //       if (i == stockSelected!.length - 1) {
                            //         isSupplierNameFill = true;
                            //       }
                            //       continue;
                            //     }
                            //     currentStockSupplier = selectedStock.supplier_name;
                            //     if (currentStockSupplier == tempStockSupplier) {
                            //       if (i == stockSelected!.length - 1) {
                            //         isSupplierNameFill = true;
                            //       }
                            //       continue;
                            //     } else {
                            //       supplierNameController.text = "Stocks Under Diff Supplier";
                            //       isSupplierNameFill = false;
                            //       break;
                            //     }
                            //   }
                            // }
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
    return field;
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

  Future<List<Stock>> getStockWithSupplierList() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/request_stock_with_supplier_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'supplier_name': supplierNameController.text,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Stock.getStockNameList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the stock list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }

  Future<(String, StockReceipt)> _submitUpdateReceiptDetails(StockReceipt currentStockReceipt, User currentUser) async {
    String receipt_number = receiptNumberController.text;
    String total_price = totalPriceController.text;
    List? stock_in_receipt;
    if (stockSelected == stockUpdate) {
      stock_in_receipt = stockUpdate;
    } else {
      stock_in_receipt = stockSelected;
    }
    print('hi');
    print(stockSelected);
    print(stockUpdate);
    print(stock_in_receipt);
    String supplier_name = supplierNameController.text;
    String supplier_name_before = supplierNameBeforeController.text;
    String pdf_file_name = pdfFileNameController.text;
    DateTime date_receipt = DateTime.parse(dateReceiptController.text);
    var (success, err_code) = await updateSupplierProfile(receipt_number, total_price, stock_in_receipt!, supplier_name, supplier_name_before, pdf_file_name, date_receipt, currentStockReceipt, currentUser);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to update the receipt.");
      }
      return (err_code, currentStockReceipt);
    }
    return (err_code, currentStockReceipt);
  }

  Future<(bool, String)> updateSupplierProfile(String receipt_number, String total_price, List stock_in_receipt, String supplier_name, String supplier_name_before, String pdf_file_name, DateTime date_receipt, StockReceipt currentStockReceipt, User currentUser) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/supplierManagement/update_receipt_details/${currentStockReceipt.id}/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'receipt_number': receipt_number,
          'total_price': total_price,
          'stock_in_receipt': stock_in_receipt,
          'pdf_file_name': pdf_file_name,
          'pdf_file': base64File,
          'supplier_name': supplier_name,
          'supplier_name_before': supplier_name_before,
          'is_file_uploaded': isFileUploaded,
          'user_updated_name': currentUser.name,
          'date_receipt': DateTime.parse(dateReceiptController.text).toString()
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('Update Receipt Failed.');
        }
        return (false, (ErrorCodes.UPDATE_RECEIPT_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_RECEIPT_FAIL_API_CONNECTION));
    }
  }
}