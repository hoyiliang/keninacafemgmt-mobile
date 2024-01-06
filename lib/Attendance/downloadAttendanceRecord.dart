import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import '../Announcement/createAnnouncement.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/Receipt.dart';
import '../Entity/Stock.dart';
import '../Entity/StockReceipt.dart';
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
      home: const DownloadAttendanceRecordPage(user: null, streamControllers: null),
    );
  }
}

class DownloadAttendanceRecordPage extends StatefulWidget {
  const DownloadAttendanceRecordPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<DownloadAttendanceRecordPage> createState() => _DownloadAttendanceRecordPageState();
}

class _DownloadAttendanceRecordPageState extends State<DownloadAttendanceRecordPage> {
  DateTime? selectedDate;
  bool isHomePage = false;
  bool isLoading = false;

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final selected = await showMonthPicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime.now(),
    );

    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
        print("Selected date: $selectedDate");
      });
    }
  }

  void downloadAttendanceRecordInExcelFile(DateTime selectedDate) async {
    setState(() {
      isLoading = true;
    });
    int month = selectedDate.month;
    int year = selectedDate.year;
    String monthYearText = DateFormat('MMMM_yyyy').format(selectedDate!);
    var (excelFileEncode, err_code) = await downloadAttendanceRecord(month, year);
    if (err_code == ErrorCodes.DOWNLOAD_ATTENDANCE_RECORD_FAIL_BACKEND) {
      showDialog(context: context, builder: (BuildContext context) =>
          AlertDialog(
            title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold,)),
            content: Text(
                'An Error occurred while trying to download the attendance record.\n\nError Code: $err_code'),
            actions: <Widget>[
              TextButton(onPressed: () =>
                  Navigator.pop(context, 'Ok'),
                  child: const Text('Ok')),
            ],
          ),
      );
    } else if (err_code == ErrorCodes.DOWNLOAD_ATTENDANCE_RECORD_FAIL_NO_RECORD) {
      showDialog(context: context, builder: (BuildContext context) =>
          AlertDialog(
            title: const Text('No Attendance Record', style: TextStyle(fontWeight: FontWeight.bold,)),
            content: Text(
                'No attendances have been in this month.\n\nError Code: $err_code'),
            actions: <Widget>[
              TextButton(onPressed: () =>
                  Navigator.pop(context, 'Ok'),
                  child: const Text('Ok')),
            ],
          ),
      );
    } else if (err_code == ErrorCodes.DOWNLOAD_ATTENDANCE_RECORD_FAIL_NO_STAFF) {
      showDialog(context: context, builder: (BuildContext context) =>
          AlertDialog(
            title: const Text('No Staff Is Available', style: TextStyle(fontWeight: FontWeight.bold,)),
            content: Text(
                'No attendances have been in this month.\n\nError Code: $err_code'),
            actions: <Widget>[
              TextButton(onPressed: () =>
                  Navigator.pop(context, 'Ok'),
                  child: const Text('Ok')),
            ],
          ),
      );
    } else if (err_code == ErrorCodes.DOWNLOAD_ATTENDANCE_RECORD_FAIL_API_CONNECTION){
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
      Uint8List bytes = base64Decode(excelFileEncode);
      String dir = "/sdcard/Documents";
      File file = File("$dir/atten_record_$monthYearText.xlsx");
      int fileNumber = 1;
      while (await file.exists()) {
        String fileName = "atten_record_${monthYearText}_$fileNumber.xlsx";
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
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers!),
      appBar: AppsBarState().buildStaffListAppBarDetails(context, 'Export Record', currentUser, widget.streamControllers),
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
                          if (selectedDate != null)
                            Text(
                              DateFormat('MMMM yyyy').format(selectedDate!),
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
            const SizedBox(height: 150.0,),
            Container(
              width: 200.0,
              height: 116.0,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: selectedDate != null ? Colors.greenAccent.shade400 : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10.0), // Adjust the radius as needed
              ),
              child: MaterialButton(
                  height:116,
                  onPressed: selectedDate != null ? () {
                    downloadAttendanceRecordInExcelFile(selectedDate!);
                  } : null,
                  child: isLoading
                      ? LoadingAnimationWidget.threeRotatingDots(
                    color: Colors.black,
                    size: 20,
                  ) : const Column(
                    children: [
                      SizedBox(height: 10.0,),
                      Icon(
                        Icons.cloud_download,
                        color: Colors.white,
                        size: 55,
                      ),
                      SizedBox(height: 5.0,),
                      Text(
                        "Export",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.0,),
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<(dynamic, String)> downloadAttendanceRecord(int month, int year) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/attendance/download_all_staff_attendance_by_month'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'month': month,
          'year': year,
        }),
      );
      final responseData = json.decode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return (responseData['data'], (ErrorCodes.OPERATION_OK));
      } else {
        if (responseData['error'] == "No data is recorded in this month.") {
          return ("", (ErrorCodes.DOWNLOAD_ATTENDANCE_RECORD_FAIL_NO_RECORD));
        } else if (responseData['error'] == "No staff is active in this month.") {
        return ("", (ErrorCodes.DOWNLOAD_ATTENDANCE_RECORD_FAIL_NO_STAFF));
        } else {
          return ("", (ErrorCodes.DOWNLOAD_ATTENDANCE_RECORD_FAIL_BACKEND));
        }
      }
    } on Exception catch (e) {
      return ("", (ErrorCodes.DOWNLOAD_ATTENDANCE_RECORD_FAIL_API_CONNECTION));
    }
  }
}