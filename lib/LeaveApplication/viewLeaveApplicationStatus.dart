import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/LeaveApplication/applyViewLeaveApplication.dart';
import 'package:keninacafe/Announcement/createAnnouncement.dart';
import 'package:keninacafe/Announcement/viewAnnouncement.dart';

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
      home: const ViewLeaveApplicationStatusPage(),
    );
  }
}

class ViewLeaveApplicationStatusPage extends StatefulWidget {
  const ViewLeaveApplicationStatusPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<ViewLeaveApplicationStatusPage> createState() => _ViewLeaveApplicationStatusPageState();
}

class _ViewLeaveApplicationStatusPageState extends State<ViewLeaveApplicationStatusPage> {
  String title = '';
  String text = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    void saveAnnouncement(String title, String text) {
      // Save announcement logic goes here
      // print('Announcement Saved: $_title - $_text');
    }

    void showConfirmationDialog(String title, String text) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
            content: const Text('Are you sure you want to create the announcement?'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Perform save logic here
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  saveAnnouncement(title, text);
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

    void showAnnouncementCard(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
                children:[
                  const Text('Create Announcement', style: TextStyle(fontSize: 21.5, fontWeight: FontWeight.bold,),),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]
            ),
            // title: const Text('Create Announcement', style: TextStyle(fontWeight: FontWeight.bold,)),
            content: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                    validator: (title) {
                      if (title == null || title.isEmpty) return 'Please fill in the title !';
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        title = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                    onChanged: (value) {
                      setState(() {
                        text = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  // Save announcement logic goes here
                  // Navigator.of(context).pop();
                  if (_formKey.currentState!.validate()) {
                    showConfirmationDialog(title, text);
                    title = '';
                    text = '';
                  }
                },
                child: const Text('Confirm'),
              ),
              ElevatedButton(
                onPressed: () {
                  title = '';
                  text = '';
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }

    List<Widget> buildAnnouncementList() {
      List<Widget> announcementList = <Widget>[];
      // Get announcement list from django API JSON
      // announcementList.add(value);
      return announcementList;
    }

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context),
      appBar: AppsBarState().buildAppBar(context, 'LA Status'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 30,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 23),
                  child: Table(
                    border: TableBorder.symmetric(
                        // outside:
                        // const BorderSide(color: Colors.black, width: 10.0)
                    ),
                    children: [
                      //This table row is for the table header which is static
                      const TableRow(
                        decoration: BoxDecoration(color: Colors.black45),
                        children: [

                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Date From",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Date To",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Leave Type",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Details",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ),
                          ),
                        ]
                      ),
                      // Using the spread operator to add the remaining table rows which have dynamic data
                      // Be sure to use .asMap().entries.map if you want to access their indexes and objectName.map() if you have no interest in the items index.

                      TableRow(
                        decoration: const BoxDecoration(color: Colors.black26),
                        children: [

                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'aaaa',
                              ),
                            ),
                          ),
                            const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Text(
                                      'aaaa',
                                    ),
                                  ),
                                ),
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                'bbbb',
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 23),
                                child: Text.rich(
                                    TextSpan(
                                        children: [
                                          TextSpan(text: 'Approved',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              decoration: TextDecoration.underline,
                                              color: Colors.transparent,
                                              shadows: [Shadow(color: Colors.blue, offset: Offset(0, -2))],
                                              decorationThickness: 4,
                                              decorationColor: Colors.blue,
                                            ),
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // Navigator.push(
                                                //   context,
                                                //   MaterialPageRoute(
                                                //     builder: (context) => const ViewAnnouncementPage(),
                                                //   ),
                                                // );
                                              },
                                          ),
                                        ]
                                    )
                                )
                            ),
                          ),
                        ],
                      ),

                      // ...students.asMap().entries.map(
                      //       (student) {
                      //     return TableRow(
                      //         decoration: BoxDecoration(color: tertiary),
                      //         children: [
                      //
                      //           Center(
                      //             child: Padding(
                      //               padding: const EdgeInsets.symmetric(vertical: 20),
                      //               child: Text(
                      //                 student.value.id.toString(),
                      //               ),
                      //             ),
                      //           ),
                      //           Center(
                      //             child: Padding(
                      //               padding: const EdgeInsets.symmetric(vertical: 20),
                      //               child: Text(
                      //                 '${student.value.firstName} ${student.value.surName}',
                      //               ),
                      //             ),
                      //           ),
                      //           Center(
                      //             child: Padding(
                      //               padding: const EdgeInsets.symmetric(vertical: 10),
                      //               child: Checkbox(
                      //                 materialTapTargetSize:
                      //                 MaterialTapTargetSize.shrinkWrap,
                      //                 onChanged: (val) {},
                      //                 value: false,
                      //               ),
                      //             ),
                      //           ),
                      //         ]);
                      //   },
                      // )
                    // ],
                  // )
                    ],
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