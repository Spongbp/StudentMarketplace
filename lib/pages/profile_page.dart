// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../pages/add_item_page.dart';
import '../pages/signin_page.dart';
import '../pages/home_page.dart';
import 'product_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

enum Campus {
  campusA,
  campusB,
  campusC,
  campusD,
}

const Map<Campus, String> campusNames = {
  Campus.campusA: 'Abbotsford',
  Campus.campusB: 'Chilliwack',
  Campus.campusC: 'Mission',
  Campus.campusD: 'Hope',
};

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // User profile fields
  String profilePictureUrl = '';
  String userName = "UFV Student Name";
  String userEmail = "student@ufv.ca";
  String userLocation = "Campus A";

  List<String> savedItemsIds = []; // List to hold saved item IDs

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Upload profile picture to Cloudinary
  Future<String?> _uploadProfilePicture(String filePath) async {
    final cloudName = 'dyzcieqym';
    final uploadPreset = 'flutter_preset';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      return data['secure_url'];
    } else {
      print('Failed to upload to Cloudinary');
      return null;
    }
  }

  // Open the profile edit modal
  void _editProfile(BuildContext context, Map<String, dynamic> currentData) {
    final TextEditingController nameController =
    TextEditingController(text: currentData['name'] ?? userName);

    // Determine selected campus enum based on current location
    Campus? selectedCampus;
    campusNames.forEach((campus, name) {
      if (name == currentData['location']) {
        selectedCampus = campus;
      }
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Campus? _editingSelectedCampus = selectedCampus;

        return AlertDialog(
          title: const Text("Edit Profile"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      final uploadedUrl = await _uploadProfilePicture(image.path);
                      Navigator.pop(context); // Remove loading indicator

                      if (uploadedUrl != null) {
                        setState(() {
                          profilePictureUrl = uploadedUrl;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to upload profile picture.')),
                        );
                      }
                    }
                  },
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: profilePictureUrl.isNotEmpty && profilePictureUrl.startsWith('http')
                        ? NetworkImage(profilePictureUrl)
                        : null,
                    child: profilePictureUrl.isEmpty
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),
                SizedBox(height: 16),
                // Name Input
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Name"),
                ),
                SizedBox(height: 20),
                // Campus Dropdown
                DropdownButtonFormField<Campus>(
                  decoration: InputDecoration(
                    labelText: 'Select Campus',
                    border: OutlineInputBorder(),
                  ),
                  value: _editingSelectedCampus,
                  items: Campus.values.map((Campus campus) {
                    return DropdownMenuItem<Campus>(
                      value: campus,
                      child: Text(campusNames[campus]!),
                    );
                  }).toList(),
                  onChanged: (Campus? newValue) {
                    setState(() {
                      _editingSelectedCampus = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your campus';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String updatedName = nameController.text.trim();
                String updatedCampus = campusNames[_editingSelectedCampus!]!;

                if (updatedName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Name cannot be empty.')),
                  );
                  return;
                }

                // Update Firestore
                final userId = FirebaseAuth.instance.currentUser?.uid;
                if (userId != null) {
                  try {
                    await FirebaseFirestore.instance.collection('users').doc(userId).set({
                      'name': updatedName,
                      'location': updatedCampus,
                      'profilePictureUrl': profilePictureUrl,
                    }, SetOptions(merge: true));

                    // Update local state
                    setState(() {
                      userName = updatedName;
                      userLocation = updatedCampus;
                    });

                    Navigator.pop(context); // Close the dialog

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile updated successfully.')),
                    );
                  } catch (e) {
                    print('Error updating profile: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update profile. Please try again.')),
                    );
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Sign Out Function
  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SignInPage()),
            (route) => false,
      );
    } catch (e) {
      print("Error signing out: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to sign out. Please try again.")),
      );
    }
  }

  // Function to toggle the sold status of a product
  Future<void> toggleSoldStatus(String listingId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('listings').doc(listingId).update({
        'isSold': !currentStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentStatus ? 'Product marked as available.' : 'Product marked as sold.',
          ),
        ),
      );
    } catch (e) {
      print('Error toggling product sold status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update product status. Please try again.')),
      );
    }
  }

  // Function to remove an item from favorites
  Future<void> removeFromFavorites(String productId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([productId])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item removed from favorites.')),
      );

      setState(() {
        savedItemsIds.remove(productId);
      });
    } catch (e) {
      print("Error removing from favorites: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove item from favorites.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 33),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => UFVHomePage()),
                  (route) => false,
            );
          },
        ),
        title: const Center(child: Text("Profile")),

        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 33),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddItemPage()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: userId == null
          ? Center(child: Text('No user is currently signed in.'))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User data not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          // Update state variables if data changes
          if (data != null) {
            profilePictureUrl = data['profilePictureUrl'] ?? '';
            userName = data['name'] ?? 'UFV Student Name';
            userEmail = data['email'] ?? 'student@ufv.ca';
            userLocation = data['location'] ?? 'Campus A';
            savedItemsIds = data['favorites'] != null ? List<String>.from(data['favorites']) : [];
          }

          return Column(
            children: [
              // Profile section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: profilePictureUrl.isNotEmpty && profilePictureUrl.startsWith('http')
                          ? NetworkImage(profilePictureUrl)
                          : const AssetImage('') as ImageProvider,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(userEmail, style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on, color: Colors.green, size: 16),
                              const SizedBox(width: 4),
                              Text(userLocation),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      onPressed: () => _editProfile(context, data!),
                    ),
                  ],
                ),
              ),

              // Tab section
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.green,
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: "Listings"),
                  Tab(text: "Saved"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Listings Tab
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('listings')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No Listings Available.'));
                        }
                        final userlistings = snapshot.data!.docs;

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: userlistings.length,
                          itemBuilder: (context, index) {
                            final doc = userlistings[index];
                            final listingData = doc.data() as Map<String, dynamic>;
                            listingData['id'] = doc.id;

                            bool isSold = listingData['isSold'] ?? false;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: listingData['images'] != null &&
                                    listingData['images'].isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: listingData['images'][0],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.broken_image),
                                )
                                    : Icon(Icons.image, size: 50),
                                title: Text(listingData['title'] ?? 'No Title'),
                                subtitle: Text(
                                    '\$${listingData['price']?.toStringAsFixed(2) ?? '0.00'}'),
                                trailing: ElevatedButton(
                                  onPressed: () => toggleSoldStatus(listingData['id'], isSold),
                                  child: Text(isSold ? 'SOLD' : 'AVAILABLE'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSold ? Colors.white60 : Colors.white60,
                                  ),
                                ),
                                onTap: () {
                                  // Navigate to product details page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductPage(
                                        listing: listingData,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    // Saved Items Tab
                    savedItemsIds.isEmpty
                        ? Center(child: Text('No Saved Items.'))
                        : FutureBuilder<List<Map<String, dynamic>>>(
                      future: fetchSavedItems(savedItemsIds),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(child: Text('No Saved Items.'));
                        }
                        final savedListings = snapshot.data!;

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: savedListings.length,
                          itemBuilder: (context, index) {
                            final listingData = savedListings[index];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              child: ListTile(
                                leading: listingData['images'] != null &&
                                    listingData['images'].isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: listingData['images'][0],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.broken_image),
                                )
                                    : Icon(Icons.image, size: 50),
                                title: Text(listingData['title'] ?? 'No Title'),
                                subtitle: Text(
                                    '\$${listingData['price']?.toStringAsFixed(2) ?? '0.00'}'),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Confirm before removing
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Remove Favorite'),
                                        content: Text(
                                            'Are you sure you want to remove this item from favorites?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              removeFromFavorites(listingData['id']);
                                            },
                                            child: Text('Remove',
                                                style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                onTap: () {
                                  // Navigate to product details page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductPage(
                                        listing: listingData,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Sign Out button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => signOut(context),
                  child: const Text("Sign Out"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Fetch saved items based on IDs
  Future<List<Map<String, dynamic>>> fetchSavedItems(List<String> favorites) async {
    try {
      List<QuerySnapshot> listingsSnapshots = [];
      int batchSize = 10;
      for (var i = 0; i < favorites.length; i += batchSize) {
        var batchFavorites = favorites.sublist(
          i,
          i + batchSize > favorites.length ? favorites.length : i + batchSize,
        );

        QuerySnapshot listingsSnapshot = await FirebaseFirestore.instance
            .collection('listings')
            .where(FieldPath.documentId, whereIn: batchFavorites)
            .get();

        listingsSnapshots.add(listingsSnapshot);
      }

      List<Map<String, dynamic>> items = [];
      for (var snapshot in listingsSnapshots) {
        items.addAll(snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList());
      }
      return items;
    } catch (e) {
      print("Error fetching saved items: $e");
      return [];
    }
  }
}