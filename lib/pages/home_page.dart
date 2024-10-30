import 'package:flutter/material.dart';
import '../pages/saved_items_page.dart';
import '../pages/campus_page.dart';
import '../pages/add_item_page.dart';
import '../pages/profile_page.dart';
import '../pages/chat_page.dart';

class UFVHomePage extends StatefulWidget {
  @override
  State<UFVHomePage> createState() => _UFVHomePageState();
}

class _UFVHomePageState extends State<UFVHomePage> {
  int selectedIndex = 0;
  final List<Map<String, String>> savedItems = [];
  final Set<String> savedItemNames = {}; // Track saved items by their names
  bool isSearching = false;

  void saveItem(Map<String, String> item) {
    setState(() {
      if (!savedItemNames.contains(item['name']!)) {
        savedItems.add(item);
        savedItemNames.add(item['name']!); // Add item name to the saved set
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = ProductListings(onSave: saveItem, savedItemNames: savedItemNames);
        break;
      case 1:
        page = SavedItemsPage(savedItems: savedItems);
        break;
      case 2:
        page = CampusPage();
        break;
      case 3:
        page = AddItemPage();
        break;
      case 5:
        page = ProfilePage();
        break;
      default:
        page = Center(child: Text('Page not found'));
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: !isSearching
            ? Text('Student Marketplace')
            : Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              hintText: 'Search...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatPage()),
              );
            },
          ),
        ],
        backgroundColor: Colors.lightGreen,
      ),
      body: page,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SizedBox(
              height: 120,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Navigation',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, size: 28),
              title: Text('Home'),
              onTap: () {
                setState(() {
                  selectedIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.sell, size: 28),
              title: Text('Sell'),
              onTap: () {
                setState(() {
                  selectedIndex = 3;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.bookmark, size: 28),
              title: Text('Saved'),
              onTap: () {
                setState(() {
                  selectedIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on, size: 28),
              title: Text('Campus'),
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person, size: 28),
              title: Text('Profile'),
              onTap: () {
                setState(() {
                  selectedIndex = 5;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProductListings extends StatelessWidget {
  final List<Map<String, String>> products = [
    {'name': 'Product 1', 'price': '\$10', 'image': 'https://via.placeholder.com/150'},
    {'name': 'Product 2', 'price': '\$15', 'image': 'https://via.placeholder.com/150'},
    {'name': 'Product 3', 'price': '\$20', 'image': 'https://via.placeholder.com/150'},
    {'name': 'Product 4', 'price': '\$25', 'image': 'https://via.placeholder.com/150'},
    {'name': 'Product 5', 'price': '\$30', 'image': 'https://via.placeholder.com/150'},
    {'name': 'Product 6', 'price': '\$35', 'image': 'https://via.placeholder.com/150'},
  ];

  final Function(Map<String, String>) onSave;
  final Set<String> savedItemNames;

  ProductListings({required this.onSave, required this.savedItemNames});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final isSaved = savedItemNames.contains(product['name']!); // Check if saved
          return Card(
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    product['image']!,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name']!,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        product['price']!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.red : Colors.black,
                    ),
                    onPressed: isSaved
                        ? null // Disable button if already saved
                        : () => onSave(product),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
