import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:keninacafe/SupplierManagement/supplierDashboard.dart';
import 'package:keninacafe/SupplierManagement/viewSupplierDetails.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/Receipt.dart';
import '../Entity/Stock.dart';
import '../Entity/StockReceipt.dart';
import '../Entity/User.dart';
import '../Entity/Supplier.dart';
import '../Order/manageOrder.dart';
import '../Utils/error_codes.dart';
import '../Utils/ip_address.dart';
import 'createStockReceipt.dart';
import 'editStockReceipt.dart';

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
      home: const StockReceiptListPage(user: null, streamControllers: null),
    );
  }
}

class StockReceiptListPage extends StatefulWidget {
  const StockReceiptListPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<StockReceiptListPage> createState() => _StockReceiptListPageState();
}

class _StockReceiptListPageState extends State<StockReceiptListPage> {
  final nameController = TextEditingController();
  final PICController = TextEditingController();
  final contactController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ImagePicker picker = ImagePicker();
  Widget? image;
  String base64Image = "";
  bool isHomePage = false;
  DateTime? selectedDate;

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
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

  void showDeleteConfirmationDialog(String receiptNumber) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to delete this receipt ($receiptNumber)?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (deleteReceipt, err_code) = await _submitDeleteReceipt(receiptNumber);
                setState(() {
                  Navigator.of(context).pop();
                  if (err_code == ErrorCodes.DELETE_RECEIPT_FAIL_BACKEND) {
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: Text('An Error occurred while trying to delete the receipt ($receiptNumber).\n\nError Code: $err_code'),
                          actions: <Widget>[
                            TextButton(onPressed: () =>
                                Navigator.pop(context, 'Ok'),
                                child: const Text('Ok')),
                          ],
                        ),
                    );
                  } else if (err_code == ErrorCodes.DELETE_RECEIPT_FAIL_API_CONNECTION){
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
                          title: const Text('Deleted Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
                          content: Text('This receipt ($receiptNumber) has been deleted.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Ok'),
                              onPressed: () {
                                Navigator.of(context).pop();
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

  void exportPdfFile(String receiptNumber) async {
    var (pdf_file, err_code) = await downloadPdfFile(receiptNumber);
    if (err_code == ErrorCodes.DOWNLOAD_PDF_FILE_FAIL_BACKEND) {
      showDialog(context: context, builder: (
          BuildContext context) =>
          AlertDialog(
            title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
            content: Text('An Error occurred while trying to download the pdf file.\n\nError Code: $err_code'),
            actions: <Widget>[
              TextButton(onPressed: () =>
                  Navigator.pop(context, 'Ok'),
                  child: const Text('Ok')),
            ],
          ),
      );
    } else if (err_code == ErrorCodes.DOWNLOAD_PDF_FILE_FAIL_API_CONNECTION){
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
      Uint8List bytes = base64Decode(pdf_file);
      String dir = "/sdcard/Documents";
      File file = File("$dir/receipt_$receiptNumber.pdf");
      int fileNumber = 1;
      while (await file.exists()) {
        String fileName = "receipt_${receiptNumber}_$fileNumber.pdf";
        file = File("$dir/$fileName");
        fileNumber++;
      }
      await file.writeAsBytes(bytes);
      showDialog(context: context, builder: (
          BuildContext context) =>
          AlertDialog(
            title: const Text('Exported Successfully', style: TextStyle(fontWeight: FontWeight.bold,)),
            content: Text(
                'The file is exported to the documents folder.'),
            actions: <Widget>[
              TextButton(onPressed: () =>
                  Navigator.pop(context, 'Ok'),
                  child: const Text('Ok')),
            ],
          ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return WillPopScope(
      onWillPop: () async {
        // Navigate to the desired page when the Android back button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SupplierDashboardPage(user: currentUser, streamControllers: widget.streamControllers)),
        );

        // Prevent the default back button behavior
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers!),
        appBar: AppsBarState().buildSupplierManagementAppBarDetails(context, 'Receipt List', currentUser, widget.streamControllers),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(13.0),
                        child: Text(
                          'Select Date: ',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 25.0,
                            fontFamily: 'Gabarito',
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        width: 200.0,
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 8.0),
                            Text(
                              '${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}',
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (selectedDate != null)
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 0),
                      child: Column(
                        children: [
                          FutureBuilder<List<StockReceipt>>(
                              future: getStockReceiptList(selectedDate!),
                              builder: (BuildContext context, AsyncSnapshot<List<StockReceipt>> snapshot) {
                                if (snapshot.hasData) {
                                  return Column(
                                    children: buildStockReceiptList(snapshot.data, currentUser),
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
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => CreateStockReceiptPage(user: currentUser, streamControllers: widget.streamControllers))
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

  List<Widget> buildStockReceiptList(List<StockReceipt>? stockReceiptList, User? currentUser) {
    List<Widget> cards = [];
    String stockListName = "";
    if (stockReceiptList!.isEmpty) {
      cards.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Image.asset(
                "images/broke_receipt.png",
                // fit: BoxFit.cover,
                // height: 500,
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
                child: Text(
                  "No Receipt On This Date",
                  style: TextStyle(
                    fontSize: 28.0,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      for (int i = 0; i < stockReceiptList.length; i++) {
        stockListName = stockReceiptList[i].stock_name.toString();
        cards.add(
          Card(
            child: Container(
              constraints: const BoxConstraints(
                maxHeight: double.infinity,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey, width: 4.0),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 0, 5),
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Receipt No.',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.grey.shade900,
                                  fontFamily: "YoungSerif",
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          ),
                          Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    stockReceiptList[i].receipt_number,
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.grey.shade700,
                                      fontFamily: "Oswald",
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ]
                          ),
                          const SizedBox(height: 10.0,),
                          Row(
                            children: [
                              Text(
                                'Price (MYR) : ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey.shade800,
                                  fontFamily: "Oswald",
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                              Text(
                                stockReceiptList[i].price.toStringAsFixed(2),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  // fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Supplier : ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey.shade800,
                                  fontFamily: "Oswald",
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                              Flexible(
                                child: Text(
                                  stockReceiptList[i].supplier_name,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey.shade700,
                                    fontFamily: "Oswald",
                                    // fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stock : ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey.shade800,
                                  fontFamily: "Oswald",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  stockListName,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey.shade700,
                                    fontFamily: "Oswald",
                                    // fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Created By : ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey.shade800,
                                  fontFamily: "Oswald",
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                              Flexible(
                                child: Text(
                                  stockReceiptList[i].user_created_name,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey.shade700,
                                    fontFamily: "Oswald",
                                    // fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3.0,),
                          if (stockReceiptList[i].user_updated_name != "")
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Updated By : ',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey.shade800,
                                    fontFamily: "Oswald",
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                                Flexible(
                                  child: Text(
                                    stockReceiptList[i].user_updated_name,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey.shade700,
                                      fontFamily: "Oswald",
                                      // fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.clip,
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 5.0,),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 15, 5),
                    child: Column(
                      children: [
                        const SizedBox(height: 5.0,),
                        Row(
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(padding: const EdgeInsets.fromLTRB(0, 1, 0, 0), backgroundColor: Colors.grey.shade300),
                                // borderRadius: BorderRadius.circular(100), color: Colors.yellow),
                                onPressed: () async {
                                  var (pdf_file, err_code) = await downloadPdfFile(stockReceiptList[i].receipt_number);
                                  Uint8List pdfBytes = base64Decode(pdf_file);
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => EditStockReceiptPage(user: currentUser, stockReceipt: stockReceiptList[i], pdfFile: pdfBytes, streamControllers: widget.streamControllers))
                                  );
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
                                  showDeleteConfirmationDialog(stockReceiptList[i].receipt_number);
                                },
                                child: Icon(Icons.delete, color: Colors.grey.shade800),
                              ),
                            ),
                            const SizedBox(width: 5.0,),
                          ],
                        ),
                        const SizedBox(height: 18.0,),
                        Container(
                          width: 120.0,
                          height: 110.0,
                          padding: const EdgeInsets.only(top: 3),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade600, width: 2.0),
                            // borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: MaterialButton(
                              minWidth: double.infinity,
                              height: 20,
                              onPressed: () async {
                                exportPdfFile(stockReceiptList[i].receipt_number);
                              },
                              color: Colors.grey.shade200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Receipt",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.orangeAccent.shade400
                                    ),
                                  ),
                                  Icon(
                                    Icons.picture_as_pdf,
                                    size: 65.0,
                                    color: Colors.grey.shade700,
                                  )
                                ],
                              )
                          ),
                        ),
                      ],
                    ),
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

  Future<(String, String)> downloadPdfFile(String receiptNumber) async {
    try {
      final response = await http.post(
        Uri.parse('${IpAddress.ip_addr}/supplierManagement/request_pdf_file'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'receipt_number': receiptNumber,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (Receipt.getPdfFile(jsonDecode(response.body)), (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('PDF File failed to download');
        }
        return ("", (ErrorCodes.DOWNLOAD_PDF_FILE_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return ("", (ErrorCodes.DOWNLOAD_PDF_FILE_FAIL_API_CONNECTION));
    }
  }

  Future<List<StockReceipt>> getStockReceiptList(DateTime selectedDate) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    try {
      final response = await http.post(
        Uri.parse('${IpAddress.ip_addr}/supplierManagement/request_stock_receipt_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'selected_date': formattedDate,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return StockReceipt.getStockReceiptList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load the stock receipt list.');
      }
    } on Exception catch (e) {
      throw Exception('API Connection Error. $e');
    }
  }


  Future<List<String>> getStockUnderSupplierList(Supplier currentSupplier) async {
    try {
      final response = await http.get(
        Uri.parse('${IpAddress.ip_addr}/supplierManagement/request_stock_under_current_supplier_list/${currentSupplier.id}'),
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

  Future<(bool, String)> _submitDeleteReceipt(String receiptNumber) async {
    var (bool, err_code) = await deleteReceipt(receiptNumber);
    if (bool == true) {
      if (kDebugMode) {
        print("Failed to delete Receipt ($receiptNumber) data.");
      }
      return (false, err_code);
    }
    return (false, err_code);
  }

  Future<(bool, String)> deleteReceipt(String receiptNumber) async {
    try {
      final response = await http.put(
        Uri.parse('${IpAddress.ip_addr}/supplierManagement/delete_receipt'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'receipt_number': receiptNumber,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No Receipt ($receiptNumber) found.');
        }
        return (false, (ErrorCodes.DELETE_RECEIPT_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.DELETE_RECEIPT_FAIL_API_CONNECTION));
    }
  }
}