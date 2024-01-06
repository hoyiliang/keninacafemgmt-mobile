import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:keninacafe/AppsBar.dart';
import 'package:keninacafe/Utils/error_codes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../Attendance/manageAttendanceRequest.dart';
import '../Entity/AnnouncementAssignUserMoreInfo.dart';
import '../Entity/User.dart';
import '../Order/manageOrder.dart';

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
      home: const CreateAnnouncementPage(user: null, streamControllers: null),
    );
  }
}

class CreateAnnouncementPage extends StatefulWidget {
  const CreateAnnouncementPage({super.key, this.user, this.streamControllers});

  final User? user;
  final Map<String,StreamController>? streamControllers;

  @override
  State<CreateAnnouncementPage> createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final viewDescriptionController = TextEditingController();
  int numTitleText = 0;
  int maxTitleText = 25;
  int numDescriptionText = 0;
  int maxDescriptionText = 200;
  final _formKey = GlobalKey<FormState>();
  bool announcementCreated = false;
  bool announcementUpdated = false;
  bool isHomePage = false;

  User? getUser() {
    return widget.user;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    widget.streamControllers!['announcement']?.stream.listen((message) {
      setState(() {
        // do nothing
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

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
                      titleController.text = '';
                      descriptionController.text = '';
                      numTitleText = 0;
                      numDescriptionText = 0;
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
                    };
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

    void showCreateAnnouncementForm(BuildContext context) {
      titleController.text = "";
      descriptionController.text = "";
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
                children: [
                  const Text('Create', style: TextStyle(fontSize: 23.5,
                    fontFamily: "Gabarito",
                    fontWeight: FontWeight.bold,),),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 2.0, vertical: 0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          titleController.text = '';
                          descriptionController.text = '';
                          numTitleText = 0;
                          numDescriptionText = 0;
                          Navigator.of(context).pop();
                        });
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.grey.shade300,
                          // border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        // padding: const EdgeInsets.all(1),
                        child: Icon(
                          Icons.close_outlined,
                          size: 25.0,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ]
            ),
            content: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    maxLines: null,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                      // Limit to 25 characters (words)
                    ],
                    onChanged: (text) {
                      setState(() {
                        // numTitleText = titleController.text.length;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Title',
                      labelStyle: const TextStyle(color: Colors.black),
                      // Set label color to white
                      // prefixIcon: const Icon(Icons.email, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black,
                            width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black,
                            width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      errorBorder: OutlineInputBorder( // Border style for error state
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.red,
                          width: 2.0,),
                      ),
                      // hintText: 'Please enter your email',
                      // hintStyle: TextStyle(color: Colors.white),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gabarito",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the title';
                      }
                      return null;
                    },
                  ),
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: Text(
                  //     '$numTitleText/$maxTitleText',
                  //     style: TextStyle(
                  //       fontSize: 13.0,
                  //       color: Colors.grey.shade600,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: null,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(120),
                      // Limit to 25 characters (words)
                    ],
                    onChanged: (text) {
                      setState(() {
                        // numDescriptionText = descriptionController.text.length;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: const TextStyle(color: Colors.black),
                      // Set label color to white
                      // prefixIcon: const Icon(Icons.email, color: Colors.black),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black,
                            width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.black,
                            width: 2.0),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      errorBorder: OutlineInputBorder( // Border style for error state
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(color: Colors.red,
                          width: 2.0,),
                      ),
                      // hintText: 'Please enter your email',
                      // hintStyle: TextStyle(color: Colors.white),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                    ),
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Gabarito",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the description';
                      }
                      return null;
                    },
                  ),
                  // Align(
                  //   alignment: Alignment.topRight,
                  //   child: Text(
                  //     '${descriptionController.text
                  //         .length}/$maxDescriptionText',
                  //     style: TextStyle(
                  //       fontSize: 13.0,
                  //       color: Colors.grey.shade600,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    showConfirmationDialog(
                        titleController.text, descriptionController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                ),
                child: const Text(
                  'Confirm',
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

    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.streamControllers),
      appBar: AppsBarState().buildAnnouncementAppBar(context, 'Announcement', currentUser!, widget.streamControllers),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              children: [
                FutureBuilder<List<AnnouncementAssignUserMoreInfo>>(
                  future: getAnnouncement(currentUser),
                  builder: (BuildContext context, AsyncSnapshot<List<AnnouncementAssignUserMoreInfo>> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: buildAnnouncementCards(snapshot.data, currentUser),
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
      floatingActionButton: currentUser.staff_type != "Restaurant Worker" ? FloatingActionButton(
        onPressed: () {
          showCreateAnnouncementForm(context);
        },
        child: const Icon(
          Icons.add,
          size: 27.0,
        ),
      ) : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: currentUser.staff_type != "Restaurant Worker" ? BottomAppBar(
        height: 20.0,
        color: Theme.of(context).colorScheme.inversePrimary,
        shape: const CircularNotchedRectangle(),
      ) : null,
      // bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context),
    );
  }

  void showUpdateAnnouncementForm(AnnouncementAssignUserMoreInfo currentAnnouncementAssign, User currentUser) {
    titleController.text = currentAnnouncementAssign.title;
    descriptionController.text = currentAnnouncementAssign.description;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
              children: [
                const Text('Update', style: TextStyle(fontSize: 23.5,
                  fontFamily: "Gabarito",
                  fontWeight: FontWeight.bold,),),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        titleController.text = '';
                        descriptionController.text = '';
                        numTitleText = 0;
                        numDescriptionText = 0;
                        Navigator.of(context).pop();
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey.shade300,
                        // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      // padding: const EdgeInsets.all(1),
                      child: Icon(
                        Icons.close_outlined,
                        size: 25.0,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              ]
          ),
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    // Limit to 25 characters (words)
                  ],
                  onChanged: (text) {
                    setState(() {
                      // numTitleText = titleController.text.length;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: const TextStyle(color: Colors.black),
                    // Set label color to white
                    // prefixIcon: const Icon(Icons.email, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    errorBorder: OutlineInputBorder( // Border style for error state
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.red,
                        width: 2.0,),
                    ),
                    // hintText: 'Please enter your email',
                    // hintStyle: TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the title';
                    }
                    return null;
                  },
                ),
                // Align(
                //   alignment: Alignment.topRight,
                //   child: Text(
                //     '$numTitleText/$maxTitleText',
                //     style: TextStyle(
                //       fontSize: 13.0,
                //       color: Colors.grey.shade600,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: descriptionController,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(120),
                    // Limit to 25 characters (words)
                  ],
                  onChanged: (text) {
                    setState(() {
                      // numDescriptionText = descriptionController.text.length;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Colors.black),
                    // Set label color to white
                    // prefixIcon: const Icon(Icons.email, color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    errorBorder: OutlineInputBorder( // Border style for error state
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.red,
                        width: 2.0,),
                    ),
                    // hintText: 'Please enter your email',
                    // hintStyle: TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  style: const TextStyle(color: Colors.black),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the description';
                    }
                    return null;
                  },
                ),
                // Align(
                //   alignment: Alignment.topRight,
                //   child: Text(
                //     '${descriptionController.text
                //         .length}/$maxDescriptionText',
                //     style: TextStyle(
                //       fontSize: 13.0,
                //       color: Colors.grey.shade600,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  showConfirmationUpdateDialog(currentAnnouncementAssign, currentUser);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
              ),
              child: const Text(
                'Confirm',
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

  void showViewAnnouncementDialog(String description) {
    viewDescriptionController.text = description;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
              children: [
                const Text('Description', style: TextStyle(fontSize: 23.5,
                  fontFamily: "Itim",
                  fontWeight: FontWeight.bold,),),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        Navigator.of(context).pop();
                      });
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.grey.shade300,
                        // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      // padding: const EdgeInsets.all(1),
                      child: Icon(
                        Icons.close_outlined,
                        size: 25.0,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ),
              ]
          ),
          content: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: viewDescriptionController,
                  maxLines: null,
                  enabled: false,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(130),
                  ],
                  onChanged: (text) {
                    setState(() {
                      numDescriptionText = descriptionController.text.length;
                    });
                  },
                  decoration: InputDecoration(
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    errorBorder: OutlineInputBorder( // Border style for error state
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(color: Colors.red,
                        width: 2.0,),
                    ),
                    // hintText: 'Please enter your email',
                    // hintStyle: TextStyle(color: Colors.white),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteConfirmationDialog(AnnouncementAssignUserMoreInfo currentAnnouncementAssign) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to delete this announcement (${currentAnnouncementAssign.title})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                var (deleteAnnouncementAsync, err_code) = await deleteAnnouncement(currentAnnouncementAssign);
                setState(() {
                  if (err_code == ErrorCodes.DELETE_ANNOUNCEMENT_FAIL_BACKEND) {
                    showDialog(context: context, builder: (
                        BuildContext context) =>
                        AlertDialog(
                          title: const Text('Error'),
                          content: Text('An Error occurred while trying to delete the announcement (${currentAnnouncementAssign.title}).\n\nError Code: $err_code'),
                          actions: <Widget>[
                            TextButton(onPressed: () =>
                                Navigator.pop(context, 'Ok'),
                                child: const Text('Ok')),
                          ],
                        ),
                    );
                  } else if (err_code == ErrorCodes.DELETE_ANNOUNCEMENT_FAIL_API_CONNECTION){
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
                          title: Text('Delete This Announcement (${currentAnnouncementAssign.title}) Successful'),
                          // content: const Text(''),
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

  void showConfirmationUpdateDialog(AnnouncementAssignUserMoreInfo currentAnnouncementAssign, User currentUser) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation', style: TextStyle(fontWeight: FontWeight.bold,)),
          content: Text('Are you sure you want to update this announcement (${currentAnnouncementAssign.title})?'),
          actions: [
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var (announcementUpdatedAsync, err_code) = await _submitUpdateAnnouncementDetails(currentAnnouncementAssign, currentUser);
                  setState(() {
                    announcementUpdated = announcementUpdatedAsync;
                    if (!announcementUpdated) {
                      if (err_code == ErrorCodes.UPDATE_ANNOUNCEMENT_FAIL_BACKEND) {
                        showDialog(context: context, builder: (
                            BuildContext context) =>
                            AlertDialog(
                              title: const Text('Error'),
                              content: Text('An Error occurred while trying to update this announcement (${currentAnnouncementAssign.title}).\n\nError Code: $err_code'),
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
                            title: const Text('Update Announcement Successful'),
                            content: Text('The updated announcement titled (${titleController.text}) can be viewed in the announcement page.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                      );
                      _formKey.currentState?.reset();
                      setState(() {
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

  void showErrorDialogIfUpdateIsReadFail(String errCode) {
    if (errCode == ErrorCodes.UPDATE_ANNOUNCEMENT_FAIL_BACKEND) {
      showDialog(context: context, builder: (
        BuildContext context) =>
        AlertDialog(
          title: const Text('Error'),
          content: Text('An Error occurred while trying to update this announcement Is Read status.\n\nError Code: $errCode'),
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
              'Unable to establish connection to our services. Please make sure you have an internet connection.\n\nError Code: $errCode'),
          actions: <Widget>[
            TextButton(onPressed: () =>
                Navigator.pop(context, 'Ok'),
                child: const Text('Ok')),
          ],
        ),
      );
    }
  }

  List<Widget> buildAnnouncementCards(List<AnnouncementAssignUserMoreInfo>? listAnnouncement, User? currentUser) {
    List<Widget> cards = [];
    if (listAnnouncement!.isEmpty) {
      cards.add(
        Column(
          mainAxisAlignment: MainAxisAlignment.center, // Vertically center the content
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 100, 0, 30),
              child: Image.asset(
                "images/noAnnouncement.png",
                // fit: BoxFit.cover,
                // height: 500,
              ),
            ),
          ],
        ),
      );
    } else {
      for (AnnouncementAssignUserMoreInfo a in listAnnouncement!) {
        bool diffSeconds = false;
        bool diffMinutes = false;
        bool diffHours = false;
        bool diffDaysInWeek = false;
        DateTime nowDateTime = DateTime.now().toUtc().toLocal();
        DateTime dateCreated = a.date_created;
        String formattedDate = DateFormat('dd MMM yyyy').format(dateCreated);
        Duration difference = nowDateTime.difference(dateCreated);

        if (difference.inDays == 0 && difference.inHours == 0 && difference.inMinutes == 0 && difference.inSeconds != 0) {
          diffSeconds = true;
        } else if (difference.inDays == 0 && difference.inHours == 0 &&
            difference.inMinutes != 0) {
          diffMinutes = true;
        } else if (difference.inDays == 0 && difference.inHours != 0) {
          diffHours = true;
        } else if (difference.inDays == 1 && difference.inHours != 0) {
          diffHours = true;
        } else if (difference.inDays != 0 && difference.inDays <= 7) {
          diffDaysInWeek = true;
        } else if (difference.inDays != 0 && difference.inDays > 7) {
          diffDaysInWeek = false;
        }
        cards.add(
          Container(
            color: a.is_read ? Colors.white : Colors.grey.shade200,
            height: currentUser?.staff_type != "Restaurant Worker" ? 165.0 : 150.0,
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              a.title,
                              style: TextStyle(
                                fontSize: 19.0,
                                color: Colors.grey.shade900,
                                fontFamily: "BreeSerif",
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.clip,
                            ),
                            const Spacer(),
                            if (currentUser?.staff_type != "Restaurant Worker")
                              Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.grey.shade300,
                                    // border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      showUpdateAnnouncementForm(a, currentUser!);
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      size: 30.0,
                                      color: Colors.grey.shade800,
                                    ),
                                  )
                              ),
                            if (currentUser?.staff_type != "Restaurant Worker")
                              const SizedBox(width: 25.0),
                            if (currentUser?.staff_type != "Restaurant Worker")
                              Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.grey.shade300,
                                    // border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      showDeleteConfirmationDialog(a);
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      size: 30.0,
                                      color: Colors.grey.shade800,
                                    ),
                                  )
                              ),
                          ],
                        ),
                        const SizedBox(height: 5.0,),
                        Text(
                          "Created by:  ${a.user_created_name}",
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Colors.grey.shade700,
                            fontFamily: "Oswald",
                            // fontWeight: FontWeight.bold,
                          ),
                        ),
                        // if (a.user_updated_name != "")
                        Row(
                          children: [
                            if (a.user_updated_name != "")
                              Text(
                                "Updated by:  ${a.user_created_name}",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Colors.grey.shade700,
                                  fontFamily: "Oswald",
                                  // fontWeight: FontWeight.bold,
                                ),
                              ),
                            const Spacer(),
                            if (!a.is_read)
                              SizedBox(
                                height: 20,
                                width: 70,
                                child: Material(
                                    elevation: 3.0, // Add elevation to simulate a border
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Colors.red, // Border color
                                        width: 2.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                    ),
                                    child: const Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Unread",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9.0,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                ),
                              )
                            else
                              SizedBox(
                                height: 20,
                                width: 70,
                                child: Material(
                                    elevation: 3.0, // Add elevation to simulate a border
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: Colors.green.shade400, // Border color
                                        width: 2.0, // Border width
                                      ),
                                      borderRadius: BorderRadius.circular(200), // Apply border radius if needed
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Read",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9.0,
                                          color: Colors.green.shade400,
                                        ),
                                      ),
                                    )
                                ),
                              )
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: 10.0),
                        Row(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                width: 150.0,
                                height: 30.0,
                                padding: const EdgeInsets.only(top: 3),
                                child: MaterialButton(
                                  minWidth: double.infinity,
                                  height: 20,
                                  onPressed: () async {
                                    showViewAnnouncementDialog(a.description);
                                    if (!a.is_read) {
                                      var (announcementIsReadUpdated, err_codes) = await _submitUpdateAnnouncementIsRead(a);
                                      if (!announcementIsReadUpdated) {
                                        showErrorDialogIfUpdateIsReadFail(err_codes);
                                      }
                                      setState(() {

                                      });
                                    }
                                  },
                                  color: Colors.grey.shade200,
                                  child: Text(
                                    "View Description",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Colors.orangeAccent.shade400
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (diffSeconds == true)
                              Text(
                                "< 1 minutes ago",
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.grey.shade900,
                                  fontFamily: "Rajdhani",
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            if (diffMinutes == true)
                              Text(
                                "${difference.inMinutes.toStringAsFixed(0)} minute(s) ago",
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.grey.shade900,
                                  fontFamily: "Rajdhani",
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            if (diffHours == true)
                              Text(
                                "${difference.inHours.toStringAsFixed(0)} hour(s) ago",
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.grey.shade900,
                                  fontFamily: "Rajdhani",
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            if (diffDaysInWeek == true)
                              Text(
                                "${difference.inDays.toStringAsFixed(0)} day(s) ago",
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.grey.shade900,
                                  fontFamily: "Rajdhani",
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            if (difference.inDays > 7 && diffDaysInWeek == false)
                              Text(
                                formattedDate,
                                style: TextStyle(
                                  fontSize: 17.0,
                                  color: Colors.grey.shade900,
                                  fontFamily: "Rajdhani",
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.clip,
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        cards.add(const Divider(height: 0,));
        // cards.add(const SizedBox(height: 15,),);
      }
    }
    return cards;
  }

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

  Future<List<AnnouncementAssignUserMoreInfo>> getAnnouncement(User currentUser) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/announcements/request_list'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'current_user_id': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print(AnnouncementAssignUserMoreInfo.getAnnouncementList(jsonDecode(response.body)));
        return AnnouncementAssignUserMoreInfo.getAnnouncementList(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load all the announcements');
      }
    } on Exception catch (e) {
      throw Exception('Failed to connect API $e');
    }
  }

  Future<(bool, String)> deleteAnnouncement(AnnouncementAssignUserMoreInfo currentAnnouncementAssign) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/announcements/delete_announcement'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'current_announcement_id': currentAnnouncementAssign.announcement_id,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return (true, (ErrorCodes.OPERATION_OK));
      } else {
        if (kDebugMode) {
          print('No Announcement Titled (${currentAnnouncementAssign.title}) found.');
        }
        return (false, (ErrorCodes.DELETE_ANNOUNCEMENT_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.DELETE_ANNOUNCEMENT_FAIL_API_CONNECTION));
    }
  }

  Future<(bool, String)> _submitUpdateAnnouncementDetails(AnnouncementAssignUserMoreInfo currentAnnouncementAssign, User currentUser) async {
    String title = titleController.text;
    String description = descriptionController.text;

    if (kDebugMode) {
      print('title: $title');
      print('description: $description');
    }
    var (success, err_code) = await updateAnnouncement(title, description, currentAnnouncementAssign, currentUser);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to update the announcement.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> updateAnnouncement(String title, String description, AnnouncementAssignUserMoreInfo currentAnnouncementAssign, User currentUser) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/announcements/update_announcement'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'title': title,
          'description': description,
          'current_announcement_id': currentAnnouncementAssign.announcement_id,
          'user_updated_uid': currentUser.uid,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Update Announcement Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Failed to update announcement.');
        }
        return (false, (ErrorCodes.UPDATE_ANNOUNCEMENT_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_ANNOUNCEMENT_FAIL_API_CONNECTION));
    }
  }

  Future<(bool, String)> _submitUpdateAnnouncementIsRead(AnnouncementAssignUserMoreInfo currentAnnouncementAssign) async {
    var (success, err_code) = await updateAnnouncementIsRead(currentAnnouncementAssign);
    if (success == false) {
      if (kDebugMode) {
        print("Failed to update the announcement Is Read.");
      }
      return (false, err_code);
    }
    return (true, err_code);
  }

  Future<(bool, String)> updateAnnouncementIsRead(AnnouncementAssignUserMoreInfo currentAnnouncementAssign) async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8000/announcements/update_announcement_is_read'),

        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic> {
          'id': currentAnnouncementAssign.id
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (kDebugMode) {
          print("Update Announcement Is Read Successful.");
        }
        return (true, ErrorCodes.OPERATION_OK);
      } else {
        if (kDebugMode) {
          print(response.body);
          print('Failed to update announcement Is Read.');
        }
        return (false, (ErrorCodes.UPDATE_ANNOUNCEMENT_ISREAD_FAIL_BACKEND));
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print('API Connection Error. $e');
      }
      return (false, (ErrorCodes.UPDATE_ANNOUNCEMENT_ISREAD_FAIL_API_CONNECTION));
    }
  }
}