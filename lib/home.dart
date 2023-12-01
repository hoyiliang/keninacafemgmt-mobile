import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/Announcement/createAnnouncement.dart';
import 'package:keninacafe/Order/manageOrder.dart';
import 'package:keninacafe/Utils/WebSocketManager.dart';
import 'Entity/User.dart';
import 'package:keninacafe/AppsBar.dart';

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
      home: const HomePage(user: null, webSocketManagers: null),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.user, this.webSocketManagers});

  final User? user;
  final Map<String,WebSocketManager>? webSocketManagers;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isHomePage = true;

  User? getUser() {
    return widget.user;
  }

  @override
  void dispose() {
    for (String key in widget.webSocketManagers!.keys) {
      widget.webSocketManagers![key]?.disconnectFromWebSocket();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Web Socket
    for (String key in widget.webSocketManagers!.keys) {
      widget.webSocketManagers![key]?.connectToWebSocket();
    }
    widget.webSocketManagers!['order']?.listenToWebSocket((message) {
      final snackBar = SnackBar(
          content: const Text('Received new order!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              dispose();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ManageOrderPage(user: getUser(), webSocketManagers: widget.webSocketManagers),
                ),
              );
            },
          )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    widget.webSocketManagers!['announcement']?.listenToWebSocket((message) {
      final snackBar = SnackBar(
          content: const Text('Received new announcement!'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              dispose();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CreateAnnouncementPage(user: getUser(), webSocketManagers: widget.webSocketManagers),
                ),
              );
            },
          )
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });

    widget.webSocketManagers!['attendance']?.listenToWebSocket((message) {
      SnackBar(
        content: const Text('Received new attendance request!'),
        // action: SnackBarAction(
        //   label: 'View',
        //   onPressed: () {
        //     dispose();
        //     Navigator.of(context).push(
        //       MaterialPageRoute(
        //         builder: (context) => (user: getUser(), webSocketManagers: widget.webSocketManagers),
        //       ),
        //     );
        //   },
        // )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    enterFullScreen();

    User? currentUser = getUser();

    print(widget.webSocketManagers == null);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: AppsBarState().buildDrawer(context, currentUser!, isHomePage, widget.webSocketManagers),
      appBar: AppsBarState().buildAppBar(context, 'Home', currentUser, widget.webSocketManagers),
      body: const Center(

      ),
      bottomNavigationBar: AppsBarState().buildBottomNavigationBar(currentUser, context, widget.webSocketManagers),
    );
  }
}