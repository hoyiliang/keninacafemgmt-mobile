import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/Announcement/createAnnouncement.dart';

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ApplyLeaveFormPage(),
    );
  }
}

class ApplyLeaveFormPage extends StatefulWidget {
  const ApplyLeaveFormPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<ApplyLeaveFormPage> createState() => _ApplyLeaveFormPageState();
}

class _ApplyLeaveFormPageState extends State<ApplyLeaveFormPage> {
  final dateFromController = TextEditingController();
  final dateToController = TextEditingController();
  final commentsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  // final _dateFromKey = GlobalKey<FormState>();
  // final _dateToFormKey = GlobalKey<FormState>();
  String? selectedValue;

  @override
  void initState() {
    dateFromController.text = ""; //set the initial value of text field
    dateToController.text = "";
    super.initState();
  }

  // final List<String> dropdownItems = [
  //   'Male',
  //   'Female',
  // ];

  List<DropdownMenuItem<String>> get dropdownItems{
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(child: Text("USA"),value: "USA"),
      const DropdownMenuItem(child: Text("Canada"),value: "Canada"),
      const DropdownMenuItem(child: Text("Brazil"),value: "Brazil"),
      const DropdownMenuItem(child: Text("England"),value: "England"),
    ];
    return menuItems;
  }


  @override
  Widget build(BuildContext context) {
    enterFullScreen();
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context),
      appBar: AppsBarState().buildAppBar(context, 'Leave Form'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  // child: Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Leave Type', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                          // child: Form(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DropdownButtonFormField(
                                  decoration: const InputDecoration(
                                    hintText: 'Please select the leave',
                                    border: OutlineInputBorder(
                                      // borderSide: const BorderSide(color: Colors.blue, width: 2),
                                      // borderRadius: BorderRadius.circular(20),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  // dropdownColor: Colors.white,
                                  // validator: (value) => value == null ? "Select a country" : null,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Please select the leave type !';
                                    return null;
                                  },
                                  value: selectedValue,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedValue = newValue!;
                                    });
                                  },
                                  items: dropdownItems),
                              // ElevatedButton(
                              //     onPressed: () {
                              //       if (_formKey.currentState!.validate()) {
                              //         //valid flow
                              //       }
                              //     },
                              //     child: const Text("Submit")
                              // )
                            ],
                          )

                          // ),
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Date From', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:TextFormField(
                              controller: dateFromController, //editing controller of this TextField
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.calendar_today), //icon of text field
                                  labelText: "Date From" //label text of field
                              ),
                              validator: (dateFromController) {
                                if (dateFromController == null || dateFromController.isEmpty) return 'Please choose the date from !';
                                return null;
                              },
                              readOnly: true,  //set it true, so that user will not able to edit text
                              onTap: () async {
                                var pickedDate = await showDatePicker(
                                    context: context, initialDate: DateTime.now(),
                                    firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                                    lastDate: DateTime(2101)
                                );

                                if(pickedDate != null ){
                                  // print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                                  String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                  // print(formattedDate); //formatted date output using intl package =>  2021-03-16
                                  //you can implement different kind of Date Format here according to your requirement
                                  setState(() {
                                    dateFromController.text = formattedDate; //set output date to TextField value.
                                  });
                                }else{
                                  // print("Date is not selected");
                                }
                              },
                            )
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Date To', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child:TextFormField(
                              controller: dateToController, //editing controller of this TextField
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.calendar_today), //icon of text field
                                  labelText: "Date To" //label text of field
                              ),
                              validator: (dateToController) {
                                if (dateToController == null || dateToController.isEmpty) return 'Please choose the date to !';
                                return null;
                              },
                              readOnly: true,  //set it true, so that user will not able to edit text
                              onTap: () async {
                                var pickedDate = await showDatePicker(
                                    context: context, initialDate: DateTime.now(),
                                    firstDate: DateTime(2000), //DateTime.now() - not to allow to choose before today.
                                    lastDate: DateTime(2101)
                                );

                                if(pickedDate != null ){
                                  // print(pickedDate);  //pickedDate output format => 2021-03-10 00:00:00.000
                                  String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                                  // print(formattedDate); //formatted date output using intl package =>  2021-03-16
                                  //you can implement different kind of Date Format here according to your requirement

                                  setState(() {
                                    dateToController.text = formattedDate; //set output date to TextField value.
                                  });
                                }else{
                                  // print("Date is not selected");
                                }
                              },
                            )
                        ),

                        const SizedBox(height: 13,),

                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                            child: Row(
                                children: [
                                  Text('Comments', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),),
                                  Text(' *', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                                ]
                            )
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6),
                          child:
                          TextFormField(
                            controller: commentsController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Please state your reason',
                            ),
                            validator: (commentsController) {
                              if (commentsController == null || commentsController.isEmpty) return 'Please state your reason !';
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 13,),
                      ],

                    ),
                  ),
                ),

                // const SizedBox(height: 13,),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 120),
                  child: Container(
                    padding: const EdgeInsets.only(top: 3,left: 3),
                    // decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(40),
                    //     border: const Border(
                    //         bottom: BorderSide(color: Colors.black),
                    //         top: BorderSide(color: Colors.black),
                    //         right: BorderSide(color: Colors.black),
                    //         left: BorderSide(color: Colors.black)
                    //     )
                    // ),
                    child: MaterialButton(
                      minWidth: double.infinity,
                      height:40,
                      onPressed: (){
                        if (_formKey.currentState!.validate()) {
                                 //valid flow
                        }
                      },
                      color: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40)
                      ),
                      child: const Text("Submit",style: TextStyle(
                        fontWeight: FontWeight.w600,fontSize: 16,
                      ),),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}