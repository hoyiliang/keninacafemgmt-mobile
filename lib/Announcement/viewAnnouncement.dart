import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
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
      home: const ViewAnnouncementPage(),
    );
  }
}

class ViewAnnouncementPage extends StatefulWidget {
  const ViewAnnouncementPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize( //wrap with PreferredSize
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          elevation: 0,
          toolbarHeight: 100,
          title: const Text('Announcement', style: TextStyle(
            fontWeight: FontWeight.bold,
          ),),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          centerTitle: true,
          leading:
          IconButton(
              onPressed: (){
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ViewAnnouncementPage()));
              },icon: const Icon(Icons.menu,size: 30,color: Colors.black,)),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const CreateAnnouncementPage())
                );
              },
              icon: const Icon(Icons.notifications, size: 35,),
            ),

            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.account_circle_rounded, size: 35,),
            ),
          ],
        ),
      ),

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