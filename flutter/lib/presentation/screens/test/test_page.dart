import 'package:flutter_demo/presentation/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../routes/routers.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.appBarBackgroundColor,
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light
          ),
          leading: IconButton(
            icon: const Column(
              children: [
                Icon(Icons.menu),
                Text("Menu", style: TextStyle(color: AppColors.white, fontSize: 8), overflow: TextOverflow.ellipsis,)
              ],
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
              // scaffoldKey.currentState!.openDrawer();
            },
          ),
        ),
        body: const Center(
          child: Text("Demo drawer"),
        )
    );
  }
}

class BottomTabPage extends StatefulWidget {
  @override
  _BottomTabPageState createState() => _BottomTabPageState();
}

class _BottomTabPageState extends State<BottomTabPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    Center(child: Text('Home')),
    Center(child: Text('Search')),
    Center(child: Text('Profile')),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 20,
              color: isSelected ? Colors.blue : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // Android
        statusBarBrightness: Brightness.light,     // iOS
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery
        .of(context)
        .padding
        .bottom;

    return Scaffold(
      body: _pages[_currentIndex],
      // resizeToAvoidBottomInset: false,

      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: bottomInset),
        height: kBottomNavigationBarHeight + bottomInset,
        decoration: BoxDecoration(
          color: Colors.yellow,
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black12),
          ],
        ),
        child: Row(
          children: [
            _buildItem(Icons.home, 0),
            _buildItem(Icons.search, 1),
            _buildItem(Icons.person, 2),
          ],
        ),
      ),

      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   onTap: _onTap,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.search),
      //       label: 'Search',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Profile',
      //     ),
      //   ],
      // ),
    );
  }
}

class TabBarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tabbed Page'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home)),
              Tab(icon: Icon(Icons.search)),
              Tab(icon: Icon(Icons.person)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: const Text('Home')),
            Center(child: Text('Search')),
            Center(child: TextButton(
              child: Text('Go to Test Page'),
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  AppRouter.loginRoute,
                  arguments: {"Test": "ABC"}
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

class DrawerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawer Example'),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Menu'),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {},
            ),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {},
            ),
          ],
        ),
      ),

      body: const Center(
        child: Text('Content'),
      ),
    );
  }
}

class DrawerNavigationPage extends StatefulWidget {
  const DrawerNavigationPage({super.key});

  @override
  State<DrawerNavigationPage> createState() =>
      _DrawerNavigationPageState();
}

class _DrawerNavigationPageState
    extends State<DrawerNavigationPage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    Center(child: Text('Home')),
    Center(child: Text('Settings')),
    Center(child: TextButton(
      child: Text('About'),
      onPressed: () {},
    )),
  ];
  final titles = const [
    'Home',
    'Settings',
    'About',
  ];
  void onSelectPage(int index) {
    Navigator.pop(context); // close drawer
    // _updateStatusBar(index);
    setState(() {
      selectedIndex = index;
    });
  }

  void _updateStatusBar(int index) {
    if (index == 0) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Android
          statusBarBrightness: Brightness.light,     // iOS
        ),
      );
    } else {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, // Android
          statusBarBrightness: Brightness.dark,      // iOS
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              selected: selectedIndex == 0,
              onTap: () => onSelectPage(0),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              selected: selectedIndex == 1,
              onTap: () => onSelectPage(1),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              selected: selectedIndex == 2,
              onTap: () => onSelectPage(2),
            ),
          ],
        ),
      ),
      body: pages[selectedIndex],
    );
  }
}
