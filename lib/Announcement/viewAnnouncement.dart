import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/AppsBar.dart';

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
      home: const ViewAnnouncementPage(user: null,),
    );
  }
}

class ViewAnnouncementPage extends StatefulWidget {
  const ViewAnnouncementPage({super.key, this.user});

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
  State<ViewAnnouncementPage> createState() => _ViewAnnouncementPageState();
}

class _ViewAnnouncementPageState extends State<ViewAnnouncementPage> {

  User? getUser() {
    return widget.user;
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();
    User? currentUser = getUser();
    print(currentUser?.name);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context),
      appBar: AppsBarState().buildAppBar(context, 'Announcement'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10,),
                  child: Card (
                    color: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 15,
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          tileColor: Colors.black12,
                          title: Text(
                            "Title",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        // const SizedBox(
                          child: Text('Hari Rayaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', style: TextStyle(fontSize: 15,),),
                          // Text(' (26/04/2023)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                        // ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10,),
                  child: Card (
                    color: Colors.white,
                    shadowColor: Colors.black,
                    elevation: 15,
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          tileColor: Colors.black12,
                          title: Text(
                            "Description",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          // const SizedBox(
                          child: Text('Hari Rayaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', style: TextStyle(fontSize: 15,),),
                          // Text(' (26/04/2023)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),),
                          // ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric( horizontal: 32, vertical: 15),
                  child: Align(
                    alignment: Alignment.center,
                    child: FloatingActionButton.extended(
                      // child: Icon(Icons.navigation),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      onPressed: () => {
                        Navigator.pop(context),
                      },
                      label: const Text("Back", style: TextStyle(fontSize: 18)),
                      icon: const Icon(Icons.arrow_back_ios_new),
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