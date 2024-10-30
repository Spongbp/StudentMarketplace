import 'package:flutter/material.dart';
import 'ufv_page.dart';
import '../pages/saved_items_page.dart';
import '../pages/campus_page.dart';
import '../pages/add_item_page.dart';
import '../pages/buy_page.dart';
import '../pages/profile_page.dart';

class HomePage extends UFVPage {
  @override
  Widget buildContent(BuildContext context) {
    return Text('Welcome to UFV Marketplace');
  }
}
class UFVHomePage extends StatefulWidget {
  @override
  State<UFVHomePage> createState() => _UFVHomePageState();
}

class _UFVHomePageState extends State<UFVHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = HomePage();
      case 1:
        page = SavedItemsPage();
      case 2:
        page = CampusPage();
      case 3:
        page = AddItemPage();
      case 4:
        page = BuyPage();
      case 5:
        page = ProfilePage();
      default:
        throw UnimplementedError('No widget for $selectedIndex');
    }

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'UFV Student Marketplace',
          ),
        ),
      ),
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on), label: 'Campus'),
          BottomNavigationBarItem(icon: Icon(Icons.sell), label: 'Sell'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Buy'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}