import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/Announcement/createAnnouncement.dart';
import 'package:keninacafe/Attendance/attendanceDashboard.dart';
import 'package:keninacafe/PersonalProfile/viewPersonalProfile.dart';
import 'package:keninacafe/Entity/User.dart';

import 'StaffManagement/staffDashboard.dart';
import 'home.dart';

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
      home: const AppsBar(),
    );
  }
}

class AppsBar extends StatefulWidget {
  const AppsBar({super.key});

  @override
  State<AppsBar> createState() => AppsBarState();
}

class AppsBarState extends State<AppsBar> {

  @override
  Widget buildDrawer(BuildContext context) {
    enterFullScreen();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
                color: Colors.green,
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('images/KE_Nina_Cafe_appsbar.jpg'))
            ),
            child: Text(
              'Side menu',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.input),
            title: const Text('Welcome'),
            onTap: () => {},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('Profile'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.border_color),
            title: const Text('Feedback'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () => {Navigator.of(context).pop()},
          ),
        ],
      ),
    );
  }

  @override
  PreferredSizeWidget buildAppBar(BuildContext context, String title, User currentUser) {

    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        // leading: Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 20),
        //   child: IconButton(
        //     icon: const Icon(Icons.arrow_back_ios_outlined),
        //     onPressed: () {
        //       // Handle back button press
        //       Navigator.pop(context);
        //     },
        //   ),
        // ),
        elevation: 0,
        toolbarHeight: 100,
        title: Text(title,
          style: const TextStyle(
          fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser))
                );
              },
              icon: const Icon(Icons.notifications, size: 35,),
            ),
          ),
          // IconButton(
          //   onPressed: () {
          //     Navigator.of(context).push(
          //         MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
          //     );
          //   },
          //   icon: const Icon(Icons.account_circle_rounded, size: 35,),
        ],
      ),
    );
  }


  PreferredSize buildBottomNavigationBar(User currentUser, BuildContext context) {
    int selectedIndex = 0;
    print(currentUser.staff_type);

    void _onItemTapped(int index) {
      // setState(() {
         selectedIndex = index;
      // });

      // Perform specific actions based on user and index
      if (currentUser.staff_type == "Restaurant Owner") {
        // Admin-specific logic
        // List<Widget> _widgetOptions = <Widget>[
        //   HomePage(user: currentUser,),
        //   ViewPersonalProfilePage(user: currentUser,),
        // ];
        // _widgetOptions.elementAt(selectedIndex);
        if (index == 0) {

        } else if (selectedIndex == 1) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
          );
        } else if (selectedIndex == 2) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
          );
        } else if (selectedIndex == 3) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
          );
        }
      } else if (currentUser.staff_type == "Restaurant Manager") {
        // List<Widget> _widgetOptions = <Widget>[
        //   HomePage(user: currentUser,),
        //   ViewPersonalProfilePage(user: currentUser,),
        // ];
        // _widgetOptions.elementAt(selectedIndex);
        // Regular user-specific logic
        if (index == 0) {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomePage(user: currentUser)),
          );
        } else if (index == 1) {
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => StaffDashboardPage(user: currentUser)),
          );
        } else if (index == 2) {
          // Navigator.of(context).push(
          //     MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
          // );
        } else if (index == 3) {
          // Navigator.of(context).push(
          //     MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
          // );
        } else if (index == 4) {
          // Navigator.of(context).push(
          //     MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
          // );
        } else if (index == 5) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
          );
        }
    } else if (currentUser.staff_type == "Restaurant Worker") {

        if (index == 0) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HomePage(user: currentUser))
          );
        } else if (index == 1) {
          // Navigator.of(context).push(
          //     MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
          // );
        } else if (index == 2) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AttendanceDashboardPage(user: currentUser))
          );
        } else if (index == 3) {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser))
          );
        }
      }
      setState(() {
        selectedIndex = index;
      });
    }


    List<BottomNavigationBarItem> bottomNavBarItems = [];
    if (currentUser.staff_type == "Restaurant Owner") {
      bottomNavBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline_outlined),
          label: 'Staff',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          label: 'Supplier',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_rounded),
          label: 'Profile',
        ),
      ];
    } else if (currentUser.staff_type == "Restaurant Manager") {
      bottomNavBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline_outlined),
          label: 'Staff',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          label: 'Supplier',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Bills',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_rounded),
          label: 'Profile',
        ),
      ];
    } else if (currentUser.staff_type == "Restaurant Worker") {
      bottomNavBarItems = const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Order',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Attendance',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle_rounded),
          label: 'Profile',
        ),
      ];
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: BottomNavigationBar(
        currentIndex: selectedIndex, // Set the current selected index
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        items: bottomNavBarItems, // Use the dynamically defined bottomNavBarItems
        onTap: _onItemTapped,
        showSelectedLabels: true, // Add this line to show the selected labels
        showUnselectedLabels: true, // Add this line to show the unselected labels
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // Customize the style of the selected label
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
    // return Scaffold(
    //   appBar: AppBar(
    //     // TRY THIS: Try changing the color here to a specific color (to
    //     // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
    //     // change color while the other colors stay the same.
    //     backgroundColor: Colors.white,
    //     // Here we take the value from the MyHomePage object that was created by
    //     // the App.build method, and use it to set our appbar title.
    //     // title: Text(widget.title),
    //   ),
    //   body: Center(
    //     // Center is a layout widget. It takes a single child and positions it
    //     // in the middle of the parent.
    //     child: Column(
    //       // Column is also a layout widget. It takes a list of children and
    //       // arranges them vertically. By default, it sizes itself to fit its
    //       // children horizontally, and tries to be as tall as its parent.
    //       //
    //       // Column has various properties to control how it sizes itself and
    //       // how it positions its children. Here we use mainAxisAlignment to
    //       // center the children vertically; the main axis here is the vertical
    //       // axis because Columns are vertical (the cross axis would be
    //       // horizontal).
    //       //
    //       // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
    //       // action in the IDE, or press "p" in the console), to see the
    //       // wireframe for each widget.
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         const Text(
    //           'You have pushed the button this many times:',
    //         ),
    //         Text(
    //           '$_counter',
    //           style: Theme.of(context).textTheme.headlineMedium,
    //         ),
    //       ],
    //     ),
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: _incrementCounter,
    //     tooltip: 'Increment',
    //     child: const Icon(Icons.add),
    //   ), // This trailing comma makes auto-formatting nicer for build methods.
    // );
}