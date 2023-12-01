import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keninacafe/Announcement/createAnnouncement.dart';
import 'package:keninacafe/Attendance/attendanceDashboard.dart';
import 'package:keninacafe/MenuManagement/menuList.dart';
import 'package:keninacafe/PersonalProfile/viewPersonalProfile.dart';
import 'package:keninacafe/Entity/User.dart';


import 'Auth/login.dart';
import 'Order/manageOrder.dart';
import 'StaffManagement/staffDashboard.dart';
import 'SupplierManagement/supplierDashboard.dart';
import 'Utils/WebSocketManager.dart';
import 'VoucherManagement/voucherAvailableList.dart';
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AppsBar( webSocketManagers: null,),
    );
  }
}

class AppsBar extends StatefulWidget {
  AppsBar({super.key, this.webSocketManagers});

  Map<String,WebSocketManager>? webSocketManagers;

  @override
  State<AppsBar> createState() => AppsBarState();
}

class AppsBarState extends State<AppsBar> {

  @override
  void dispose() {
    super.dispose();
  }

  void disconnectWS(final Map<String,WebSocketManager>? webSocketManagers) {
    if (webSocketManagers != null) {
      webSocketManagers.forEach((key, value) {
        value.disconnectFromWebSocket();
      });
    }
  }

  @override
  Widget buildDrawer(BuildContext context, User currentUser, bool isHomePage, final Map<String,WebSocketManager>? webSocketManagers) {
    enterFullScreen();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // const DrawerHeader(
          //   decoration: BoxDecoration(
          //       color: Colors.green,
          //       // image: DecorationImage(
          //       //     fit: BoxFit.fill,
          //       //     image: AssetImage('images/KE_Nina_Cafe_appsbar.jpg'))
          //   ),
          //   child: Text(
          //     'Side menu',
          //     style: TextStyle(color: Colors.white, fontSize: 25),
          //   ),
          // ),
          Container(
            color: Colors.deepPurple.shade400,
            padding: const EdgeInsets.fromLTRB(0, 30, 0, 30),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 45,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0), // Border radius
                      child: ClipOval(child: Image.asset('images/KE_Nina_Cafe_logo.jpg')),
                    ),
                  ),
                  const SizedBox(width: 20.0,),
                  const Text(
                    'Admin System',
                    style: TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                ]
            ),
          ),
          const SizedBox(height: 10,),
          if (isHomePage == false)
            ListTile(
              leading: Icon(
                Icons.home,
                color: Colors.deepPurple.shade300,
              ),
              title: Text(
                'Home',
                style: TextStyle(
                  color: Colors.deepPurple.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                disconnectWS(webSocketManagers),
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage(user: currentUser, webSocketManagers: webSocketManagers))
                ),
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 19, 15, 10),
            child: Text(
              'Management',
              style: TextStyle(color: Colors.grey.shade800, fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.receipt_outlined,
              color: Colors.deepPurple.shade300,
            ),
            title: Text(
              'Order',
              style: TextStyle(
                color: Colors.deepPurple.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            onTap: () => {
              disconnectWS(webSocketManagers),
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ManageOrderPage(user: currentUser, webSocketManagers: webSocketManagers))
              ),
            },
          ),
          if (currentUser.staff_type != "Restaurant Worker")
            ListTile(
              leading: Icon(
                Icons.menu_book_outlined,
                color: Colors.deepPurple.shade300
              ),
              title: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.deepPurple.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                disconnectWS(webSocketManagers),
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MenuListPage(user: currentUser, webSocketManagers: webSocketManagers))
                ),
              },
            ),
          if (currentUser.staff_type != "Restaurant Worker")
            ListTile(
              leading: Icon(
                Icons.discount_outlined,
                color: Colors.deepPurple.shade300,
              ),
              title: Text(
                'Voucher',
                style: TextStyle(
                  color: Colors.deepPurple.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                disconnectWS(webSocketManagers),
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => VoucherAvailableListPage(user: currentUser, webSocketManagers: webSocketManagers))
                ),
              },
            ),
          if (currentUser.staff_type != "Restaurant Worker")
            ListTile(
              leading: Icon(
                Icons.people_outline_outlined,
                color: Colors.deepPurple.shade300
              ),
              title: Text(
                'Staff',
                style: TextStyle(
                  color: Colors.deepPurple.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                disconnectWS(webSocketManagers),
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => StaffDashboardPage(user: currentUser, webSocketManagers: webSocketManagers))
                ),
              },
            ),
          if (currentUser.staff_type != "Restaurant Worker")
            ListTile(
              leading: Icon(
                Icons.local_shipping_outlined,
                color: Colors.deepPurple.shade300
              ),
              title: Text(
                'Supplier',
                style: TextStyle(
                  color: Colors.deepPurple.shade400,
                  fontWeight: FontWeight.bold,
                  fontSize: 17.0,
                ),
              ),
              onTap: () => {
                disconnectWS(webSocketManagers),
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SupplierDashboardPage(user: currentUser, webSocketManagers: webSocketManagers))
                ),
              },
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 18, 15, 10),
            child: Text(
              'Account',
              style: TextStyle(color: Colors.grey.shade800, fontSize: 19, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.account_circle_rounded,
              color: Colors.deepPurple.shade300
            ),
            title: Text(
              'Profile',
              style: TextStyle(
                color: Colors.deepPurple.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            onTap: () => {
              disconnectWS(webSocketManagers),
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser, webSocketManagers: webSocketManagers))
              ),
            },
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.deepPurple.shade300
            ),
            title: Text(
              'Log Out',
              style: TextStyle(
                color: Colors.deepPurple.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
            onTap: () => {
              disconnectWS(webSocketManagers),
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const LoginPage(), ),
              )
            },
          ),
        ],
      ),
    );
  }

  @override
  PreferredSizeWidget buildAppBar(BuildContext context, String title, User currentUser, final Map<String,WebSocketManager>? webSocketManagers) {

    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
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
                disconnectWS(webSocketManagers);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser, webSocketManagers: webSocketManagers))
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


  @override
  PreferredSizeWidget buildSupplierDashboardAppBar(BuildContext context, String title, User currentUser, final Map<String,WebSocketManager>? webSocketManagers) {

    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        elevation: 0,
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(7, 0, 0, 0),
          child: Text(title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 28, 0),
            child: IconButton(
              onPressed: () {
                disconnectWS(webSocketManagers);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser, webSocketManagers: webSocketManagers))
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

  @override
  PreferredSizeWidget buildSupplierManagementAppBarDetails(BuildContext context, String title, User currentUser, final Map<String,WebSocketManager>? webSocketManagers) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            disconnectWS(webSocketManagers);
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SupplierDashboardPage(user: currentUser, webSocketManagers: webSocketManagers))
            );
          },
        ),
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
                disconnectWS(webSocketManagers);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser, webSocketManagers: webSocketManagers))
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

  @override
  PreferredSizeWidget buildAppBarDetails(BuildContext context, String title, User currentUser, final Map<String,WebSocketManager>? webSocketManagers) {

    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            disconnectWS(webSocketManagers);
            // Handle back button press
            Navigator.pop(context);
          },
        ),
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
                disconnectWS(webSocketManagers);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser, webSocketManagers: webSocketManagers))
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

  @override
  PreferredSizeWidget buildDetailsAppBar(BuildContext context, String title, User currentUser, final Map<String,WebSocketManager>? webSocketManagers) {

    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            disconnectWS(webSocketManagers);
            Navigator.pop(context);
          },
        ),
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
                disconnectWS(webSocketManagers);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser, webSocketManagers: webSocketManagers))
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

  @override
  PreferredSizeWidget buildOrderAppBar(BuildContext context, String title, User currentUser, final Map<String,WebSocketManager>? webSocketManagers) {

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
        bottom: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.directions_car)),
            Tab(icon: Icon(Icons.directions_transit)),
            Tab(icon: Icon(Icons.directions_bike)),
          ],
        ),
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
                disconnectWS(webSocketManagers);
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => CreateAnnouncementPage(user: currentUser, webSocketManagers: webSocketManagers))
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


  PreferredSize buildBottomNavigationBar(User currentUser, BuildContext context, final Map<String,WebSocketManager>? webSocketManagers) {
    int selectedIndex = 0;

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
          disconnectWS(webSocketManagers);
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomePage(user: currentUser, webSocketManagers: webSocketManagers)),
          );
        } else if (selectedIndex == 1) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => StaffDashboardPage(user: currentUser, webSocketManagers: webSocketManagers))
          );
        } else if (selectedIndex == 2) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SupplierDashboardPage(user: currentUser, webSocketManagers: webSocketManagers))
          );
        } else if (selectedIndex == 3) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser, webSocketManagers: webSocketManagers))
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
          disconnectWS(webSocketManagers);
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomePage(user: currentUser, webSocketManagers: webSocketManagers)),
          );
        } else if (index == 1) {
          disconnectWS(webSocketManagers);
          Navigator.push(context,
            MaterialPageRoute(builder: (context) => StaffDashboardPage(user: currentUser, webSocketManagers: webSocketManagers)),
          );
        } else if (index == 2) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SupplierDashboardPage(user: currentUser, webSocketManagers: webSocketManagers))
          );
        } else if (index == 3) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MenuListPage(user: currentUser, webSocketManagers: webSocketManagers))
          );
        } else if (index == 4) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => VoucherAvailableListPage(user: currentUser, webSocketManagers: webSocketManagers))
          );
        } else if (index == 5) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser, webSocketManagers: webSocketManagers))
          );
        }
    } else if (currentUser.staff_type == "Restaurant Worker") {

        if (index == 0) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => HomePage(user: currentUser, webSocketManagers: webSocketManagers))
          );
        } else if (index == 1) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ManageOrderPage(user: currentUser, webSocketManagers: webSocketManagers))
          );
        } else if (index == 2) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AttendanceDashboardPage(user: currentUser, webSocketManagers: webSocketManagers))
          );
        } else if (index == 3) {
          disconnectWS(webSocketManagers);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ViewPersonalProfilePage(user: currentUser, webSocketManagers: webSocketManagers))
          );
        }
      }
      // setState(() {
      //   selectedIndex = index;
      // });
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
          icon: Icon(Icons.discount_rounded),
          label: 'Voucher',
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
        type: BottomNavigationBarType.shifting,
        selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.inversePrimary),
        selectedItemColor: Theme.of(context).colorScheme.inversePrimary,
        currentIndex: selectedIndex, // Set the current selected index
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
  PreferredSizeWidget buildViewSupplierDetailsAppBar(BuildContext context, String title, final Map<String,WebSocketManager>? webSocketManagers) {

    return PreferredSize( //wrap with PreferredSize
      preferredSize: const Size.fromHeight(80),
      child: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 100,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            title,
            softWrap: true,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
              fontFamily: "BreeSerif"
              // fontStyle: FontStyle.italic,
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              icon: const Icon(
                Icons.close,
                size: 30,
              ), // Add your close button icon
              onPressed: () {
                disconnectWS(webSocketManagers);
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}