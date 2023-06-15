import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/Announcement/viewAnnouncement.dart';
import 'package:keninacafe/Entity/Announcement.dart';
import 'package:keninacafe/Utils/error_codes.dart';
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
      home: const CreateAnnouncementPage(user: null,),
    );
  }
}

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key, this.user});

  final User? user;
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  // final String title;

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool announcementCreated = false;
  // late List<Announcement> announcements = [];

  User? getUser() {
    return widget.user;
  }

  @override
  void initState() {
    super.initState();
    // List<dynamic> announcementList = getAnnouncement();
  }
  // List<Widget> buildAnnouncementList() {
  //   List<Widget> announcementList = <Widget>[];
  //   // Get announcement list from django API JSON
  //   // announcementList.add(value);
  //   return announcementList;
  // }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();
    // getAnnouncement();

    User? currentUser = getUser();
    print(currentUser?.name);

    void showConfirmationDialog(String title, String description) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
            content: const Text('Are you sure you want to create the announcement?'),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  // Perform save logic here
                  // Navigator.of(context).pop();
                  // Navigator.of(context).pop();
                  if (_formKey.currentState!.validate()) {
                    var (announcementCreatedAsync, err_code) = await _submitAnnouncementDetails(title, description, currentUser!);
                    setState(() {
                      announcementCreated = announcementCreatedAsync;
                      if (!announcementCreated) {
                        if (err_code == ErrorCodes.ANNOUNCEMENT_CREATE_FAIL_BACKEND) {
                          showDialog(context: context, builder: (
                              BuildContext context) =>
                              AlertDialog(
                                title: const Text('Error'),
                                content: Text(
                                    'An Error occurred while trying to create a new announcement.\n\nError Code: $err_code'),
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
                        // If Announcement success created
                        titleController.text = '';
                        descriptionController.text = '';
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        showDialog(context: context, builder: (
                            BuildContext context) =>
                            AlertDialog(
                              title: const Text('Create New Announcement Successful'),
                              content: const Text(
                                  'The announcement can be viewed in the Announcement page.'),
                              actions: <Widget>[
                                TextButton(onPressed: () =>
                                    Navigator.pop(context, 'Ok'),
                                    child: const Text('Ok')),
                              ],
                            ),
                        );
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         const HomePage(),
                        //   ),
                        // );
                      }
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) =>
                        //         const HomePage(),
                        //   ),
                        // );
                      // }
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
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                    validator: (titleController) {
                      if (titleController == null || titleController.isEmpty) return 'Please fill in the title !';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
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
                    showConfirmationDialog(titleController.text, descriptionController.text);
                  }
                },
                child: const Text('Confirm'),
              ),
              ElevatedButton(
                onPressed: () {
                  titleController.text = '';
                  descriptionController.text = '';
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context),
      appBar: AppsBarState().buildAppBar(context, 'Announcement'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                padding: const EdgeInsets.symmetric( horizontal: 32, vertical: 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FloatingActionButton.extended(
                      // child: Icon(Icons.navigation),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      onPressed: () => {
                        showAnnouncementCard(context),
                      },
                      label: const Text("Create", style: TextStyle(fontSize: 18)),
                      icon: const Icon(Icons.add_alert_sharp),
                    ),
                  ),
                ),

                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FutureBuilder<List<Announcement>>(
                  future: getAnnouncement(),
                  builder: (BuildContext context, AsyncSnapshot<List<Announcement>> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: buildAnnouncementCards(snapshot.data, currentUser),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildAnnouncementCards(List<Announcement>? listAnnouncement, User? currentUser) {
    List<Widget> cards = [];
    for (Announcement a in listAnnouncement!) {
      cards.add(
        Card (
          color: Colors.white,
          shadowColor: Colors.black,
          elevation: 15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
            [
              ListTile(
                title: Text(
                  a.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis,),
                ),
                subtitle: Text(
                  'Created by ${a.name}',
                  style: const TextStyle(overflow: TextOverflow.ellipsis,),
                ),
              ),
              SizedBox(
                child: Text(a.description, style: const TextStyle(fontSize: 15, overflow: TextOverflow.ellipsis,),),
              ),

              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text.rich(
                          TextSpan(
                              children: [
                                TextSpan(text: 'View Announcement',
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ViewAnnouncementPage(announcement: a, user: currentUser),
                                        ),
                                      );
                                    },
                                ),
                              ]
                          )
                      )
                  )
              )
            ],
          ),
        ),
      );
      cards.add(const SizedBox(height: 15,),);
    }
    return cards;
  }

  // Create Announcement
  Future<(bool, String)> _submitAnnouncementDetails(String title, String description, User currentUser) async {
    String title = titleController.text;
    String description = descriptionController.text;

    if (kDebugMode) {
      print('title: $title');
      print('description: $description');
    }

    var (success, err_code) = await createAnnouncement(title, description, currentUser);
    return (success, err_code);
  }

  Future<(bool, String)> createAnnouncement(String title, String description, User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/announcements/announcement_form'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'title': title,
          'description': description,
          'user_created_id': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Create Announcement Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print('Failed to Create Announcement.');
        }
        return (false, ErrorCodes.ANNOUNCEMENT_CREATE_FAIL_BACKEND);
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, ErrorCodes.ANNOUNCEMENT_CREATE_FAIL_API_CONNECTION);
    }
  }

  // Get Announcement
  Future<List<Announcement>> getAnnouncement() async {
    // String title = titleController.text;
    // String description = descriptionController.text;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/announcements/request_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // var futureAnnouncements = jsonDecode(response.body);
        // List<Announcement> announcement = [];
        // for (var futureAnnouncement in futureAnnouncements) {
        //    Announcement announcements = Announcement(
        //       title: futureAnnouncement["title"],
        //       description: futureAnnouncement["description"],
        //       user: futureAnnouncement["user_created"],
        //    );
        //   //Adding user to the list.
        //   announcement.add(announcements);
        // }
        // return announcement;

        // print(response.body.toString());


        return Announcement.getAnnouncementList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load album');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }

    // if (kDebugMode) {
    //   print('title: $title');
    //   print('description: $description');
    // }
    //
    // var (success, err_code) = await createAnnouncement(title, description, currentUser);
    // return (success, err_code);
  }
}