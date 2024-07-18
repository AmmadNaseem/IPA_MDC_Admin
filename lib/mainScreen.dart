import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:moderndrycleanersadmin/customPainter.dart';
import 'package:moderndrycleanersadmin/themeConstants.dart';

import 'Pages/home.dart';
import 'Pages/items.dart';
import 'Pages/newItem.dart';

class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int tabIndex = 1;
  late TabController tabController =
      TabController(length: 3, vsync: this, initialIndex: tabIndex);
  List<Widget> pages = [const Items(), const Home(), const NewItem()];
  List<String> appBarTitles = ["Items", "Home", "Add Item"];
  List<int> appBackgrounds = [1, 1, 2];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: ColorScheme.fromSeed(seedColor: Colors.white).primary),
        useMaterial3: false,
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      home: Stack(children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              appBarTitles[tabIndex],
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            backgroundColor: kPrimaryAppColor,
          ),
          body: Stack(
            children: [
              SizedBox.expand(
                  child: CustomPaint(
                painter: MyCustomPainter(appBackgrounds[tabIndex]),
              )),
              pages[tabIndex],
            ],
          ),
          bottomNavigationBar: CircleNavBar(
            shadowColor: const Color(0xFF1CA8F3),
            initIndex: tabIndex,
            onChanged: (v) {
              tabIndex = v;
              tabController.animateTo(v);
              setState(() {});
            },
            activeIcons: const [
              Icon(Icons.person, color: Color(0xFF1CA8F3)),
              Icon(Icons.home, color: Color(0xFF1CA8F3)),
              Icon(Icons.account_tree_outlined, color: Color(0xFF1CA8F3)),
            ],
            inactiveIcons: const [
              Text(
                "Items",
              ),
              Text(
                "Home",
              ),
              Text(
                "Add Item",
              ),
            ],
            color: Colors.white,
            height: 50,
            circleWidth: 50,
          ),
        ),
      ]),
    );
  }
}
