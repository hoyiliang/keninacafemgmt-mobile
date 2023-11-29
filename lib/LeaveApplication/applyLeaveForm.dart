// import 'dart:convert';
// import 'dart:ffi';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:keninacafe/AppsBar.dart';
// import 'package:http/http.dart' as http;
// import 'package:keninacafe/Announcement/createAnnouncement.dart';
// import 'package:keninacafe/Entity/LeaveFormData.dart';
// import 'package:keninacafe/LeaveApplication/manageLeaveApplicationRequest.dart';
// import 'package:keninacafe/Utils/error_codes.dart';
//
// import '../Entity/User.dart';
// import '../Entity/LeaveType.dart';
// import '../Entity/LeaveFormData.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// void enterFullScreen() {
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive, overlays: []);
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // TRY THIS: Try running your application with "flutter run". You'll see
//         // the application has a blue toolbar. Then, without quitting the app,
//         // try changing the seedColor in the colorScheme below to Colors.green
//         // and then invoke "hot reload" (save your changes or press the "hot
//         // reload" button in a Flutter-supported IDE, or press "r" if you used
//         // the command line to start the app).
//         //
//         // Notice that the counter didn't reset back to zero; the application
//         // state is not lost during the reload. To reset the state, use hot
//         // restart instead.
//         //
//         // This works for code too, not just values: Most code changes can be
//         // tested with just a hot reload.
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const ApplyLeaveFormPage(leaveFormData: null, user: null,),
//     );
//   }
// }
//
// class ApplyLeaveFormPage extends StatefulWidget {
//   const ApplyLeaveFormPage({super.key, this.user, this.leaveFormData});
//
//   final User? user;
//   final LeaveFormData? leaveFormData;
//
//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.
//
//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".
//
//   // final String title;
//
//   @override
//   State<ApplyLeaveFormPage> createState() => _ApplyLeaveFormPageState();
// }
//
// class _ApplyLeaveFormPageState extends State<ApplyLeaveFormPage> {
//   final dateFromController = TextEditingController();
//   final dateToController = TextEditingController();
//   final totalDayController = TextEditingController();
//   final commentsController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   // List<DropdownMenuItem<String>> leaveTypeNames = [];
//   bool leaveFormDataCreated = false;
//   bool leaveApplicationUpdated = false;
//   String? selectedValue;
//
//   User? getUser() {
//     return widget.user;
//   }
//
//   LeaveFormData? getLeaveFormData() {
//     return widget.leaveFormData;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     enterFullScreen();
//     // stream: dropdownItems.stream;
//
//     User? currentUser = getUser();
//     print(currentUser?.name);
//
//     LeaveFormData? leaveFormData = getLeaveFormData();
//     print(leaveFormData?.is_active);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: AppsBarState().buildDrawer(context),
//       appBar: AppsBarState().buildAppBar(context, 'Leave Form', currentUser!),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: SizedBox(
//             child: buildLeaveForm(leaveFormData, currentUser!),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildDropDownButtonFormField(List<LeaveType>? leaveTypes) {
//     List<DropdownMenuItem<String>> leaveTypeNames = [];
//     leaveTypeNames = getDropDownMenuItem(leaveTypes!);
//     return DropdownButtonFormField(
//         decoration: const InputDecoration(
//           hintText: 'Please select the leave',
//           border: OutlineInputBorder(
//             // borderSide: const BorderSide(color: Colors.blue, width: 2),
//             // borderRadius: BorderRadius.circular(20),
//           ),
//           filled: true,
//           fillColor: Colors.white,
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) return 'Please select the leave type !';
//           return null;
//         },
//         value: selectedValue,
//         onChanged: (String? newValue) {
//           setState(() {
//             selectedValue = newValue!;
//           });
//         },
//         items: leaveTypeNames,
//     );
//   }
//
//   Widget buildReadOnlyDropDownButtonFormField(List<LeaveType>? leaveTypes) {
//     List<DropdownMenuItem<String>> leaveTypeNames = [];
//     leaveTypeNames = getDropDownMenuItem(leaveTypes!);
//     return DropdownButtonFormField(
//       decoration: const InputDecoration(
//         hintText: 'Please select the leave',
//         border: OutlineInputBorder(
//           // borderSide: const BorderSide(color: Colors.blue, width: 2),
//           // borderRadius: BorderRadius.circular(20),
//         ),
//         filled: true,
//         fillColor: Colors.white,
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) return 'Please select the leave type !';
//         return null;
//       },
//       value: selectedValue,
//       onChanged: null,
//       items: leaveTypeNames,
//     );
//   }
//
//   Widget buildBlankLeaveForm(User currentUser){
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 10,
//           ),
//           // child: Expanded(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: Row(
//                         children: [
//                           Text('Leave Type', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
//                           Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
//                         ]
//                     )
//                 ),
//
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     // child: Form(
//
//                     child: FutureBuilder<List<LeaveType>>(
//                         future: getLeaveType(),
//                         builder: (BuildContext context, AsyncSnapshot<List<LeaveType>> snapshot) {
//                           if (snapshot.hasData) {
//                             return Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [buildDropDownButtonFormField(snapshot.data)]
//                             );
//                           } else {
//                             if (snapshot.hasError) {
//                               return Center(child: Text('Error: ${snapshot.error}'));
//                             } else {
//                               return const Center(child: Text('Error: invalid state'));
//                             }
//                           }
//                         }
//                     )
//                 ),
//
//                 const SizedBox(height: 13,),
//
//                 const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: Row(
//                         children: [
//                           Text('Date From', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
//                           Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
//                         ]
//                     )
//                 ),
//
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child:TextFormField(
//                       controller: dateFromController, //editing controller of this TextField
//                       decoration: const InputDecoration(
//                           icon: Icon(Icons.calendar_today), //icon of text field
//                           labelText: "Date From" //label text of field
//                       ),
//                       validator: (dateFromController) {
//                         if (dateFromController == null || dateFromController.isEmpty) return 'Please choose the date from !';
//                         return null;
//                       },
//                       readOnly: true,  //set it true, so that user will not able to edit text
//                       onTap: () async {
//                         var pickedDate = await showDatePicker(
//                             context: context, initialDate: DateTime.now(),
//                             firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
//                             lastDate: DateTime(2101)
//                         );
//
//                         if(pickedDate != null ){
//                           // print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
//                           String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
//                           // print(formattedDate); //formatted date output using intl package =>  2021-03-16
//                           //you can implement different kind of Date Format here according to your requirement
//                           setState(() {
//                             dateFromController.text = formattedDate; //set output date to TextField value.
//                             if (dateFromController.text.isNotEmpty && dateToController.text.isNotEmpty) {
//                               DateTime dateFrom = DateTime.parse(dateFromController.text);
//                               DateTime dateTo = DateTime.parse(dateToController.text);
//                               final Duration duration = dateTo.difference(dateFrom);
//                               String durationInDays = '';
//                               if (duration.inDays >= 0) {
//                                 durationInDays = ((duration.inDays)+1).toString();
//                               }
//                               else {
//                                 durationInDays = ((duration.inDays)-1).toString();
//                               }
//                               // String durationInDays = duration.inDays.toString();
//                               totalDayController.text = durationInDays;
//                               //set output date to TextField value.
//                             }
//                           });
//                         }else{
//                           // print("Date is not selected");
//                         }
//                       },
//                     )
//                 ),
//
//                 const SizedBox(height: 13,),
//
//                 const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: Row(
//                         children: [
//                           Text('Date To', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
//                           Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
//                         ]
//                     )
//                 ),
//
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child:TextFormField(
//                       controller: dateToController, //editing controller of this TextField
//                       decoration: const InputDecoration(
//                           icon: Icon(Icons.calendar_today), //icon of text field
//                           labelText: "Date To" //label text of field
//                       ),
//                       validator: (dateToController) {
//                         if (dateToController == null || dateToController.isEmpty) return 'Please choose the date to !';
//                         return null;
//                       },
//                       readOnly: true,  //set it true, so that user will not able to edit text
//                       onTap: () async {
//                         var pickedDate = await showDatePicker(
//                             context: context, initialDate: DateTime.now(),
//                             firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
//                             lastDate: DateTime(2101)
//                         );
//
//                         if(pickedDate != null ){
//                           // print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
//                           String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
//                           // print(formattedDate); //formatted date output using intl package =>  2021-03-16
//                           //you can implement different kind of Date Format here according to your requirement
//
//                           setState(() {
//                             dateToController.text = formattedDate;
//                             if (dateFromController.text.isNotEmpty && dateToController.text.isNotEmpty) {
//                               DateTime dateFrom = DateTime.parse(dateFromController.text);
//                               DateTime dateTo = DateTime.parse(dateToController.text);
//                               final Duration duration = dateTo.difference(dateFrom);
//                               String durationInDays = '';
//                               if (duration.inDays >= 0) {
//                                 durationInDays = ((duration.inDays)+1).toString();
//                               }
//                               else {
//                                 durationInDays = ((duration.inDays)-1).toString();
//                               }
//                               // String durationInDays = duration.inDays.toString();
//                               totalDayController.text = durationInDays;
//                               //set output date to TextField value.
//                             }
//                           });
//                         }else{
//                           // print("Date is not selected");
//                         }
//                       },
//                     )
//                 ),
//
//                 const SizedBox(height: 13,),
//
//                 const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: Row(
//                         children: [
//                           Text('Total Day(s)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
//                           Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
//                         ]
//                     )
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                   child:
//                   TextFormField(
//                     controller: totalDayController,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'Please state your reason',
//                     ),
//                     validator: (totalDayController) {
//                       // if (totalDayController == null || totalDayController.isEmpty) return 'Please state your reason !';
//                       // return null;
//                       if (dateFromController.text.isNotEmpty && dateToController.text.isNotEmpty) {
//                         DateTime dateFrom = DateTime.parse(dateFromController.text);
//                         DateTime dateTo = DateTime.parse(dateToController.text);
//                         final Duration duration = dateTo.difference(dateFrom);
//                         String durationInDays = '';
//                         if (duration.inDays >= 0) {
//                           durationInDays = ((duration.inDays)+1).toString();
//                         }
//                         else {
//                           durationInDays = ((duration.inDays)-1).toString();
//                         }
//
//                         if (totalDayController != durationInDays) {
//                           return 'The total Day(s) is not matched !';
//                         }
//                         if (duration.inDays < 0) {
//                           return 'The total Day(s) cannot be zero or in negative value !';
//                         }
//                         return null;
//                         //set output date to TextField value.
//                       }
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 13,),
//
//                 const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: Row(
//                         children: [
//                           Text('Comments', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
//                           Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
//                         ]
//                     )
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                   child:
//                   TextFormField(
//                     controller: commentsController,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'Please state your reason',
//                     ),
//                     validator: (commentsController) {
//                       if (commentsController == null || commentsController.isEmpty) return 'Please state your reason !';
//                       return null;
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 13,),
//               ],
//
//             ),
//           ),
//         ),
//
//         // const SizedBox(height: 13,),
//
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 120),
//           child: Container(
//             padding: const EdgeInsets.only(top: 3,left: 3),
//             // decoration: BoxDecoration(
//             //     borderRadius: BorderRadius.circular(40),
//             //     border: const Border(
//             //         bottom: BorderSide(color: Colors.black),
//             //         top: BorderSide(color: Colors.black),
//             //         right: BorderSide(color: Colors.black),
//             //         left: BorderSide(color: Colors.black)
//             //     )
//             // ),
//             child: MaterialButton(
//               minWidth: double.infinity,
//               height:40,
//               onPressed: (){
//                 if (_formKey.currentState!.validate()) {
//                   showConfirmationCreateDialog(currentUser);
//                 }
//               },
//               color: Colors.lightBlueAccent,
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(40)
//               ),
//               child: const Text("Submit",style: TextStyle(
//                 fontWeight: FontWeight.w600,fontSize: 16,
//               ),),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget buildLeaveFormWithValue(LeaveFormData leaveFormData, User currentUser){
//     selectedValue = leaveFormData.leave_type;
//     dateFromController.text = leaveFormData.date_from.toString().substring(0,10);
//     dateToController.text = leaveFormData.date_to.toString().substring(0,10);
//     totalDayController.text = leaveFormData.total_day.toString().substring(leaveFormData.total_day.toString().length - 3, leaveFormData.total_day.toString().length - 2);
//     commentsController.text = leaveFormData.comments.toString();
//
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 20,
//             vertical: 10,
//           ),
//           // child: Expanded(
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: Row(
//                         children: [
//                           Text('Leave Type', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
//                           Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
//                         ]
//                     )
//                 ),
//
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: FutureBuilder<List<LeaveType>>(
//                         future: getLeaveType(),
//                         builder: (BuildContext context, AsyncSnapshot<List<LeaveType>> snapshot) {
//                           if (snapshot.hasData) {
//                             return Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [buildReadOnlyDropDownButtonFormField(snapshot.data)]
//                             );
//                           } else {
//                             if (snapshot.hasError) {
//                               return Center(child: Text('Error: ${snapshot.error}'));
//                             } else {
//                               return const Center(child: Text('Error: invalid state'));
//                             }
//                           }
//                         }
//                     )
//                 ),
//
//                 const SizedBox(height: 13,),
//
//                 const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: Row(
//                         children: [
//                           Text('Date From', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
//                           Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
//                         ]
//                     )
//                 ),
//
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child:TextFormField(
//                       controller: dateFromController, //editing controller of this TextField
//                       decoration: const InputDecoration(
//                           icon: Icon(Icons.calendar_today), //icon of text field
//                           labelText: "Date From" //label text of field
//                       ),
//                       readOnly: true,
//                       validator: (dateFromController) {
//                         if (dateFromController == null || dateFromController.isEmpty) return 'Please choose the date from !';
//                         return null;
//                       }, //set it true, so that user will not able to edit text
//                       onTap: null,
//                     )
//                 ),
//
//                 const SizedBox(height: 13,),
//
//                 const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: Row(
//                         children: [
//                           Text('Date To', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
//                           Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
//                         ]
//                     )
//                 ),
//
//                 Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child:TextFormField(
//                       controller: dateToController, //editing controller of this TextField
//                       decoration: const InputDecoration(
//                           icon: Icon(Icons.calendar_today), //icon of text field
//                           labelText: "Date To" //label text of field
//                       ),
//                       readOnly: true,
//                       validator: (dateToController) {
//                         if (dateToController == null || dateToController.isEmpty) return 'Please choose the date to !';
//                         return null;
//                       }, //set it true, so that user will not able to edit text
//                       onTap: null,
//                     )
//                 ),
//
//                 const SizedBox(height: 13,),
//
//                 const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: Row(
//                         children: [
//                           Text('Total Day(s)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
//                           Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
//                         ]
//                     )
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                   child:
//                   TextFormField(
//                     controller: totalDayController,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'Please state your reason',
//                     ),
//                     readOnly: true,
//                     validator: (totalDayController) {
//                       // if (totalDayController == null || totalDayController.isEmpty) return 'Please state your reason !';
//                       // return null;
//                       if (dateFromController.text.isNotEmpty && dateToController.text.isNotEmpty) {
//                         DateTime dateFrom = DateTime.parse(dateFromController.text);
//                         DateTime dateTo = DateTime.parse(dateToController.text);
//                         final Duration duration = dateTo.difference(dateFrom);
//                         String durationInDays = '';
//                         if (duration.inDays >= 0) {
//                           durationInDays = ((duration.inDays)+1).toString();
//                         }
//                         else {
//                           durationInDays = ((duration.inDays)-1).toString();
//                         }
//
//                         if (totalDayController != durationInDays) {
//                           return 'The total Day(s) is not matched !';
//                         }
//                         if (duration.inDays < 0) {
//                           return 'The total Day(s) cannot be zero or in negative value !';
//                         }
//                         return null;
//                         //set output date to TextField value.
//                       }
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 13,),
//
//                 const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                     child: Row(
//                         children: [
//                           Text('Comments', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
//                           Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
//                         ]
//                     )
//                 ),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
//                   child:
//                   TextFormField(
//                     controller: commentsController,
//                     decoration: const InputDecoration(
//                       border: OutlineInputBorder(),
//                       hintText: 'Please state your reason',
//                     ),
//                     readOnly: true,
//                     validator: (commentsController) {
//                       if (commentsController == null || commentsController.isEmpty) return 'Please state your reason !';
//                       return null;
//                     },
//                   ),
//                 ),
//
//                 const SizedBox(height: 13,),
//               ],
//
//             ),
//           ),
//         ),
//         buildLeaveFormStatusBelow(leaveFormData, currentUser),
//       ],
//     );
//   }
//
//   Widget buildLeaveForm(LeaveFormData? leaveFormData, User currentUser) {
//     if (leaveFormData == null) {
//       return buildBlankLeaveForm(currentUser);
//     } else if (leaveFormData.leave_type.isNotEmpty) {
//       return buildLeaveFormWithValue(leaveFormData, currentUser);
//     } else {
//       return const SizedBox.shrink();
//     }
//   }
//
//   Widget buildLeaveFormStatusBelow(LeaveFormData leaveFormData, User currentUser) {
//     if (currentUser.staff_type == "Restaurant Staff") {
//       if (leaveFormData.is_active && leaveFormData.user_name == currentUser.name) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 120),
//           child: Container(
//             width: 150,
//             height: 50,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(40),
//               color: Colors.lightBlueAccent,
//             ),
//             child: const Center(
//               child: Text(
//                 'Pending',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         );
//       } else if (leaveFormData.is_approve) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 120),
//           child: Container(
//             width: 150,
//             height: 50,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(40),
//               color: Colors.green,
//             ),
//             child: const Center(
//               child: Text(
//                 'Approved',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         );
//       } else if (leaveFormData.is_reject) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 120),
//           child: Container(
//             width: 150,
//             height: 50,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(40),
//               color: Colors.red,
//             ),
//             child: const Center(
//               child: Text(
//                 'Rejected',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         );
//       } else {
//         return const SizedBox.shrink();
//       }
//     } else if (currentUser.staff_type == "Restaurant Manager") {
//       if (leaveFormData.is_active) {
//         return Padding(
//           padding: const EdgeInsets.symmetric(),
//           child: Row (
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               MaterialButton(
//                 // minWidth: double.infinity,
//                 height:40,
//                 onPressed: (){
//                   if (_formKey.currentState!.validate()) {
//                     showConfirmationUpdateDialog('Are you sure you want to approve the leave application?', 'An Error occurred while trying to approve the leave application.', 'Approve Leave Application Successful', 'Can update the status to the Restaurant Staff', currentUser, leaveFormData, "Approve");
//                   }
//                 },
//                 color: Colors.green,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(40)
//                 ),
//                 child: const Text("Approve",style: TextStyle(
//                   fontWeight: FontWeight.w600,fontSize: 16,
//                 ),),
//               ),
//               const SizedBox(width: 16),
//               MaterialButton(
//                 // minWidth: double.infinity,
//                 height:40,
//                 onPressed: (){
//                   if (_formKey.currentState!.validate()) {
//                     showConfirmationUpdateDialog('Are you sure you want to reject the leave application?', 'An Error occurred while trying to reject the leave application.', 'Reject Leave Application Successful', 'Can update the status to the Restaurant Staff', currentUser, leaveFormData, "Reject");
//                   }
//                 },
//                 color: Colors.red,
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(40)
//                 ),
//                 child: const Text("Reject",style: TextStyle(
//                   fontWeight: FontWeight.w600,fontSize: 16,
//                 ),),
//               ),
//             ]
//           )
//         );
//       } else {
//         return const SizedBox.shrink();
//       }
//     } else {
//       return const SizedBox.shrink();
//     }
//   }
//
//   List<DropdownMenuItem<String>> getDropDownMenuItem(List<LeaveType> listLeaveType) {
//     List<DropdownMenuItem<String>> leaveFormDataItems = [];
//     for (LeaveType a in listLeaveType) {
//       leaveFormDataItems.add(DropdownMenuItem(value: a.name, child: Text(a.name)));
//     }
//     return leaveFormDataItems;
//   }
//
//   Future<(bool, String)> _submitLeaveFormDataDetails(User currentUser) async {
//     String? leaveType = selectedValue;
//     DateTime dateFrom = DateTime.parse(dateFromController.text);
//     DateTime dateTo = DateTime.parse(dateToController.text);
//     double totalDay = double.parse(totalDayController.text);
//     String comments = commentsController.text;
//
//     if (kDebugMode) {
//       print('leaveType: $leaveType');
//       print('dateFrom: $dateFrom');
//       print('dateTo: $dateTo');
//       print('totalDay: $totalDay');
//       print('comments: $comments');
//     }
//
//     var (success, err_code) = await createLeaveFormData(leaveType!, dateFrom, dateTo, totalDay, comments, currentUser);
//     return (success, err_code);
//   }
//
//   Future<(bool, String)> createLeaveFormData(String leaveType, DateTime dateFrom, DateTime dateTo, double totalDay, String comments, User currentUser) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://10.0.2.2:8000/leave/leave_form_data'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, dynamic> {
//           'leaveType': leaveType,
//           'dateFrom': dateFrom.toString(),
//           'dateTo': dateTo.toString(),
//           'totalDay': totalDay,
//           'comments': comments,
//           'user_created_id': currentUser.uid,
//         }),
//       );
//
//       if (response.statusCode == 201 || response.statusCode == 200) {
//         if (kDebugMode) {
//           print("Create Leave Form Data Successful.");
//         }
//         return (true, ErrorCodes.OPERATION_OK);
//       } else {
//         if (kDebugMode) {
//           print('Failed to Create Leave Form Data Announcement.');
//         }
//         return (false, ErrorCodes.LEAVE_FORM_DATA_CREATE_FAIL_BACKEND);
//       }
//     } on Exception catch (e) {
//       if (kDebugMode) {
//         print('API Connection Error. $e');
//       }
//       return (false, ErrorCodes.LEAVE_FORM_DATA_CREATE_FAIL_API_CONNECTION);
//     }
//   }
//
//   Future<(bool, String)> approveLeaveForm(LeaveFormData leaveFormData, User currentUser) async {
//     try {
//       final response = await http.put(
//         Uri.parse('http://10.0.2.2:8000/leave/update_application/${leaveFormData.id}/'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, dynamic> {
//           // 'id': leaveFormData.id,
//           'is_active': !leaveFormData.is_active,
//           'is_approve': !leaveFormData.is_approve,
//           'is_reject': leaveFormData.is_reject,
//         }),
//       );
//
//       if (response.statusCode == 201 || response.statusCode == 200) {
//         if (kDebugMode) {
//           print("Approve Leave Application Successful.");
//         }
//         return (true, ErrorCodes.OPERATION_OK);
//       } else {
//         if (kDebugMode) {
//           print('Failed to Approve Leave Application.');
//         }
//         return (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_BACKEND);
//       }
//     } on Exception catch (e) {
//       if (kDebugMode) {
//         print('API Connection Error. $e');
//       }
//       return (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_API_CONNECTION);
//     }
//   }
//
//   Future<(bool, String)> rejectLeaveForm(LeaveFormData leaveFormData, User currentUser) async {
//     try {
//       final response = await http.put(
//         Uri.parse('http://10.0.2.2:8000/leave/update_application/${leaveFormData.id}/'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//         body: jsonEncode(<String, dynamic> {
//           // 'id': leaveFormData.id,
//           'is_active': !leaveFormData.is_active,
//           'is_approve': leaveFormData.is_approve,
//           'is_reject': !leaveFormData.is_reject,
//         }),
//       );
//
//       if (response.statusCode == 201 || response.statusCode == 200) {
//         if (kDebugMode) {
//           print("Reject Leave Application Successful.");
//         }
//         return (true, ErrorCodes.OPERATION_OK);
//       } else {
//         if (kDebugMode) {
//           print('Failed to Reject Leave Application.');
//         }
//         return (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_BACKEND);
//       }
//     } on Exception catch (e) {
//       if (kDebugMode) {
//         print('API Connection Error. $e');
//       }
//       return (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_API_CONNECTION);
//     }
//   }
//
//   Future<List<LeaveType>> getLeaveType() async {
//     // String title = titleController.text;
//     // String description = descriptionController.text;
//
//     try {
//       final response = await http.get(
//         Uri.parse('http://10.0.2.2:8000/leave/request_type_list'),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//         },
//       );
//
//       if (response.statusCode == 201 || response.statusCode == 200) {
//         print(response.body.toString());
//
//         return LeaveType.getLeaveTypeList(jsonDecode(response.body));
//       } else {
//         throw Exception('Failed to load leave type');
//       }
//     } on Exception catch (e) {
//       throw Exception('Failed to connect API $e');
//     }
//   }
//
//   void showConfirmationUpdateDialog(String question, String error, String information, String informationContent, User currentUser, LeaveFormData leaveFormData, String action) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
//           content: Text(question),
//           // content: const Text('Are you sure you want to submit the leave form?'),
//           actions: [
//             ElevatedButton(
//               onPressed: () async {
//                 // Perform save logic here
//                 // Navigator.of(context).pop();
//                 // Navigator.of(context).pop();
//                 if (_formKey.currentState!.validate()) {
//                   var (leaveApplicationUpdatedAsync, err_code) = (false, ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_BACKEND);
//                   if (action == 'Approve') {
//                     (leaveApplicationUpdatedAsync, err_code) = await approveLeaveForm(leaveFormData, currentUser);
//                   } else {
//                     (leaveApplicationUpdatedAsync, err_code) = await rejectLeaveForm(leaveFormData, currentUser);
//                   }
//
//                   setState(() {
//                     leaveApplicationUpdated = leaveApplicationUpdatedAsync;
//                     if (!leaveApplicationUpdated) {
//                       if (err_code == ErrorCodes.LEAVE_APPLICATION_UPDATE_FAIL_BACKEND) {
//                         showDialog(context: context, builder: (
//                             BuildContext context) =>
//                             AlertDialog(
//                               title: const Text('Error'),
//                               content: Text('$error\n\nError Code: $err_code'),
//                               // content: Text('An Error occurred while trying to create a new leave form data.\n\nError Code: $err_code'),
//                               actions: <Widget>[
//                                 TextButton(onPressed: () =>
//                                     Navigator.pop(context, 'Ok'),
//                                     child: const Text('Ok')),
//                               ],
//                             ),
//                         );
//                       } else {
//                         showDialog(context: context, builder: (
//                             BuildContext context) =>
//                             AlertDialog(
//                               title: const Text('Connection Error'),
//                               content: Text(
//                                   'Unable to establish connection to our services. Please make sure you have an internet connection.\n\nError Code: $err_code'),
//                               actions: <Widget>[
//                                 TextButton(onPressed: () =>
//                                     Navigator.pop(context, 'Ok'),
//                                     child: const Text('Ok')),
//                               ],
//                             ),
//                         );
//                       }
//                     } else {
//                       // If Leave Form Data success created
//
//                       Navigator.of(context).pop();
//                       showDialog(context: context, builder: (
//                           BuildContext context) =>
//                           AlertDialog(
//                             title: Text(information),
//                             content: Text(informationContent),
//                             // title: const Text('Create New Leave Form Data Successful'),
//                             // content: const Text('The Leave Form Data can be viewed in the LA status page.'),
//                             actions: <Widget>[
//                               TextButton(
//                                 child: const Text('Ok'),
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(builder: (context) => ManageLeaveApplicationRequestPage(user: currentUser)),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                       );
//                       _formKey.currentState?.reset();
//                       setState(() {
//                         selectedValue = null;
//                         dateFromController.text = "";
//                         dateToController.text = "";
//                         totalDayController.text = '';
//                         commentsController.text = '';
//                       });
//                     }
//                   });
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//               ),
//               child: const Text('Yes'),
//
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               child: const Text('No'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void showConfirmationCreateDialog(User currentUser) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
//           content: const Text('Are you sure you want to submit the leave form?'),
//           actions: [
//             ElevatedButton(
//               onPressed: () async {
//                 // Perform save logic here
//                 // Navigator.of(context).pop();
//                 // Navigator.of(context).pop();
//                 if (_formKey.currentState!.validate()) {
//                   var (leaveFormDataCreatedAsync, err_code) = await _submitLeaveFormDataDetails(currentUser);
//                   setState(() {
//                     leaveFormDataCreated = leaveFormDataCreatedAsync;
//                     if (!leaveFormDataCreated) {
//                       if (err_code == ErrorCodes.LEAVE_FORM_DATA_CREATE_FAIL_BACKEND) {
//                         showDialog(context: context, builder: (
//                             BuildContext context) =>
//                             AlertDialog(
//                               title: const Text('Error'),
//                               content: Text('An Error occurred while trying to create a new leave form data.\n\nError Code: $err_code'),
//                               actions: <Widget>[
//                                 TextButton(onPressed: () =>
//                                     Navigator.pop(context, 'Ok'),
//                                     child: const Text('Ok')),
//                               ],
//                             ),
//                         );
//                       } else {
//                         showDialog(context: context, builder: (
//                             BuildContext context) =>
//                             AlertDialog(
//                               title: const Text('Connection Error'),
//                               content: Text(
//                                   'Unable to establish connection to our services. Please make sure you have an internet connection.\n\nError Code: $err_code'),
//                               actions: <Widget>[
//                                 TextButton(onPressed: () =>
//                                     Navigator.pop(context, 'Ok'),
//                                     child: const Text('Ok')),
//                               ],
//                             ),
//                         );
//                       }
//                     } else {
//                       // If Leave Form Data success created
//
//                       Navigator.of(context).pop();
//                       showDialog(context: context, builder: (
//                           BuildContext context) =>
//                           AlertDialog(
//                             title: const Text('Create New Leave Form Data Successful'),
//                             content: const Text('The Leave Form Data can be viewed in the LA status page.'),
//                             actions: <Widget>[
//                               TextButton(
//                                 child: const Text('Ok'),
//                                 onPressed: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(builder: (context) => ApplyLeaveFormPage(user: currentUser)),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                       );
//                       _formKey.currentState?.reset();
//                       setState(() {
//                         selectedValue = null;
//                         dateFromController.text = "";
//                         dateToController.text = "";
//                         totalDayController.text = '';
//                         commentsController.text = '';
//                       });
//                     }
//                   });
//                 }
//                 // saveAnnouncement(title, text);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//               ),
//               child: const Text('Yes'),
//
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//               ),
//               child: const Text('No'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }