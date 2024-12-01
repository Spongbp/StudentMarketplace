// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/add_item_page.dart';
import '../pages/profile_page.dart';
import '../pages/messages_page.dart';
import '../pages/signin_page.dart';
import '../pages/product_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UFVHomePage extends StatefulWidget {
  @override
  State<UFVHomePage> createState() => _UFVHomePageState();
}

class _UFVHomePageState extends State<UFVHomePage> {
  int selectedIndex = 0; // Default index is 0 to show ProductListings
  bool isSearching = false;
  String searchQuery = ""; // Track the search query
  String selectedCampus = "Abbotsford";

  // Filters
  double minPrice = 0.0;
  double maxPrice = 10000.0;
  String selectedCondition = 'Any';
  List<String> selectedLocations = [];

  final List<String> campuses = ["Abbotsford", "Chilliwack", "Mission", "Hope"];
  final List<String> conditions = ['Any', 'New', 'Used'];

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
  }

  void toggleSaveItem(String itemId) async {
    if (currentUser == null) return;

    DocumentReference userDoc =
    FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    DocumentSnapshot userSnapshot = await userDoc.get();
    List<dynamic> favorites = userSnapshot.get('favorites') ?? [];

    if (favorites.contains(itemId)) {
      // Remove from favorites
      await userDoc.update({
        'favorites': FieldValue.arrayRemove([itemId])
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Item removed from favorites.")),
      );
    } else {
      // Add to favorites
      await userDoc.update({
        'favorites': FieldValue.arrayUnion([itemId])
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Item added to favorites.")),
      );
    }

    setState(() {}); // Refresh the UI
  }

  Future<void> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to log out. Please try again.")),
      );
    }
  }

  // Function to fetch listings from 'listings' collection
  Stream<List<Map<String, dynamic>>> fetchListingsStream() {
    Query query = FirebaseFirestore.instance
        .collection('listings')
        .orderBy('createdAt', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'title': data['title'] ?? 'Unnamed Product',
          'price': data['price']?.toDouble() ?? 0.00,
          'description': data['description'] ?? 'No description available',
          'location': data['location'] ?? 'Unknown campus',
          'category': data['category'] ?? 'Uncategorized',
          'condition': data['condition'] ?? 'Unknown',
          'images': List<String>.from(data['images'] ?? []),
          'userId': data['userId'] ?? '',
          'isSold': data['isSold'] ?? false,
        };
      }).toList();
    });
  }

  Widget _getSelectedPage() {
    switch (selectedIndex) {
      case 0:
      // Home Page Content
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: fetchListingsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading listings.'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No listings available.'));
            }

            final allListings = snapshot.data!;
            final filteredListings = allListings.where((listing) {
              // Exclude sold items
              if (listing['isSold'] == true) {
                return false;
              }

              // Apply search filter
              final titleMatch = listing['title']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
              final categoryMatch = listing['category']
                  .toString()
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());

              // Apply price filter
              final price = listing['price'] as double;
              final priceMatch = price >= minPrice && price <= maxPrice;

              // Apply condition filter
              final condition = listing['condition'] as String;
              final conditionMatch = selectedCondition == 'Any' ||
                  condition.toLowerCase() == selectedCondition.toLowerCase();

              // Apply location filter
              final location = listing['location'] as String;
              final locationMatch = selectedLocations.isEmpty ||
                  selectedLocations.contains(location);

              return (titleMatch || categoryMatch) &&
                  priceMatch &&
                  conditionMatch &&
                  locationMatch;
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredListings.length,
                itemBuilder: (context, index) {
                  final listing = filteredListings[index];
                  final imageUrl =
                  (listing['images'] as List<String>).isNotEmpty
                      ? listing['images'][0]
                      : '';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser?.uid)
                        .get(),
                    builder: (context, userSnapshot) {
                      bool isSaved = false;
                      if (userSnapshot.hasData && userSnapshot.data != null) {
                        List<dynamic> favorites =
                            userSnapshot.data!.get('favorites') ?? [];
                        isSaved = favorites.contains(listing['id']);
                      }
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductPage(listing: listing),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: imageUrl.isNotEmpty
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                        child:
                                        CircularProgressIndicator()),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.broken_image, size: 50),
                                  ),
                                )
                                    : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                  ),
                                  child: Icon(Icons.image,
                                      size: 50, color: Colors.grey[700]),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Product Title and Price
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            listing['title'],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            '\$${listing['price'].toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700]),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Favorite Button
                                    IconButton(
                                      icon: Icon(
                                        isSaved
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                        isSaved ? Colors.red : Colors.black,
                                      ),
                                      onPressed: () =>
                                          toggleSaveItem(listing['id']),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      case 1:
        return MessagesPage();
      case 2:
        return AddItemPage();
      case 3:
        return ProfilePage();
      default:
        return Center(child: Text('Page not found'));
    }
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  // Build the Bottom Navigation Bar
  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTabTapped,
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sell),
          label: 'Sell',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  AppBar buildAppBar() {
    return AppBar(
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
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              isSearching = !isSearching;
              if (!isSearching) searchQuery = ""; // Reset search query if search is closed
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.filter_list), // Changed to filter icon
          onPressed: () {
            // Open filter dialog
            openFilterDialog();
          },
        ),
      ],
      backgroundColor: Colors.lightGreen,
    );
  }

  // Open the filter dialog
  void openFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double tempMinPrice = minPrice;
        double tempMaxPrice = maxPrice;
        String tempSelectedCondition = selectedCondition;
        List<String> tempSelectedLocations = List.from(selectedLocations);

        return AlertDialog(
          title: Text('Filter Listings'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Price Range
                Text('Price Range'),
                RangeSlider(
                  values: RangeValues(tempMinPrice, tempMaxPrice),
                  min: 0.0,
                  max: 10000.0,
                  divisions: 20,
                  labels: RangeLabels(
                    '\$${tempMinPrice.toStringAsFixed(0)}',
                    '\$${tempMaxPrice.toStringAsFixed(0)}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      tempMinPrice = values.start;
                      tempMaxPrice = values.end;
                    });
                  },
                ),
                SizedBox(height: 10),
                // Condition
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Condition',
                    border: OutlineInputBorder(),
                  ),
                  value: tempSelectedCondition,
                  items: conditions.map((String condition) {
                    return DropdownMenuItem<String>(
                      value: condition,
                      child: Text(condition),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      tempSelectedCondition = newValue!;
                    });
                  },
                ),
                SizedBox(height: 10),
                // Locations
                Text('Locations'),
                Wrap(
                  spacing: 5.0,
                  children: campuses.map((String campus) {
                    return FilterChip(
                      label: Text(campus),
                      selected: tempSelectedLocations.contains(campus),
                      onSelected: (bool selected) {
                        setState(() {
                          if (selected) {
                            tempSelectedLocations.add(campus);
                          } else {
                            tempSelectedLocations.remove(campus);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close without applying filters
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  minPrice = tempMinPrice;
                  maxPrice = tempMaxPrice;
                  selectedCondition = tempSelectedCondition;
                  selectedLocations = tempSelectedLocations;
                });
                Navigator.pop(context); // Close after applying filters
              },
              child: Text('Apply Filters'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: selectedIndex == 0 ? buildAppBar() : null,
      body: _getSelectedPage(),
      bottomNavigationBar: buildBottomNavigationBar(),
    );
  }
}