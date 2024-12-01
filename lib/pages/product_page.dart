// lib/pages/product_page.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pages/chat_screen.dart';

class ProductPage extends StatefulWidget {
  final Map<String, dynamic> listing;

  ProductPage({required this.listing});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Seller details
  Map<String, dynamic>? sellerData;
  bool isLoadingSeller = true;
  bool sellerError = false;

  // Favorite state
  bool isFavorited = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    fetchSellerData();
    checkIfFavorited();
  }

  // Fetch seller data from Firestore
  Future<void> fetchSellerData() async {
    try {
      String userId = widget.listing['userId'] ?? '';
      if (userId.isEmpty) {
        setState(() {
          isLoadingSeller = false;
          sellerError = true;
        });
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          sellerData = userDoc.data() as Map<String, dynamic>;
          isLoadingSeller = false;
        });
      } else {
        setState(() {
          isLoadingSeller = false;
          sellerError = true;
        });
      }
    } catch (e) {
      print("Error fetching seller data: $e");
      setState(() {
        isLoadingSeller = false;
        sellerError = true;
      });
    }
  }

  // Check if the current user has favorited this product
  Future<void> checkIfFavorited() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      currentUserId = user.uid;
    });

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    if (userDoc.exists) {
      List<dynamic> favorites = userDoc.get('favorites') ?? [];
      setState(() {
        isFavorited = favorites.contains(widget.listing['id']);
      });
    }
  }

  // Toggle favorite status
  Future<void> toggleFavorite() async {
    if (currentUserId == null) {
      // Prompt user to log in or handle unauthenticated state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please log in to favorite items.")),
      );
      return;
    }

    DocumentReference userRef =
    FirebaseFirestore.instance.collection('users').doc(currentUserId);

    if (isFavorited) {
      // Remove from favorites
      await userRef.update({
        'favorites': FieldValue.arrayRemove([widget.listing['id']])
      });
    } else {
      // Add to favorites
      await userRef.update({
        'favorites': FieldValue.arrayUnion([widget.listing['id']])
      });
    }

    setState(() {
      isFavorited = !isFavorited;
    });
  }

  // Method to Get or Create Conversation
  Future<String> _getOrCreateConversation(
      String buyerId, String sellerId) async {
    // Check if a conversation already exists
    QuerySnapshot conversationSnapshot = await FirebaseFirestore.instance
        .collection('conversations')
        .where('participants', arrayContains: buyerId)
        .get();

    for (var doc in conversationSnapshot.docs) {
      List<dynamic> participants = doc['participants'];
      if (participants.contains(sellerId)) {
        // Conversation exists
        return doc.id;
      }
    }

    // Conversation doesn't exist, create a new one
    DocumentReference newConversationRef =
    await FirebaseFirestore.instance.collection('conversations').add({
      'participants': [buyerId, sellerId],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    return newConversationRef.id;
  }

  @override
  Widget build(BuildContext context) {
    // Extract product fields with default values
    String title = widget.listing['title'] ?? 'Unnamed Product';
    double price = widget.listing['price']?.toDouble() ?? 0.00;
    String description =
        widget.listing['description'] ?? 'No description available';
    String condition = widget.listing['condition'] ?? 'Unknown';
    String location = widget.listing['location'] ?? 'Unknown Location';
    List<dynamic> imagesDynamic = widget.listing['images'] ?? [];
    List<String> images = imagesDynamic.cast<String>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                '$title',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                color: isFavorited ? Colors.red : Colors.white,
              ),
              onPressed: toggleFavorite,
            ),
          ],
        ),
        backgroundColor: Colors.lightGreen,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carousel Slider for multiple images
                if (images.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 280,
                      enlargeCenterPage: true,
                      autoPlay: true,
                    ),
                    items: images.map((imageUrl) {
                      return Builder(
                        builder: (BuildContext context) {
                          return CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            placeholder: (context, url) =>
                                Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.broken_image, size: 100),
                          );
                        },
                      );
                    }).toList(),
                  )
                else
                  Container(
                    height: 280,
                    color: Colors.grey[300],
                    child: Center(
                      child:
                      Icon(Icons.image, size: 100, color: Colors.grey[700]),
                    ),
                  ),
                SizedBox(height: 30),

                // Product title
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 10),

                // Product price
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, color: Colors.grey[700]),
                ),
                Divider(),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    "Description",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 18),
                ),

                SizedBox(height: 10),

                // Location
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Location",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(fontSize: 18),
                ),

                SizedBox(height: 10),

                // Condition
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Condition",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  condition,
                  style: TextStyle(fontSize: 18),
                ),

                SizedBox(height: 20),

                SizedBox(height: 110), // Space for pinned seller section
              ],
            ),
          ),

          // Pinned Seller Details
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10.0),
              child: isLoadingSeller
                  ? Center(child: CircularProgressIndicator())
                  : sellerError
                  ? Text('Failed to load seller details.')
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Seller Avatar
                  sellerData != null &&
                      sellerData!['profileImage'] != null &&
                      sellerData!['profileImage'].isNotEmpty
                      ? CircleAvatar(
                    backgroundImage:
                    NetworkImage(sellerData!['profileImage']),
                    radius: 25,
                  )
                      : CircleAvatar(
                    child: Icon(Icons.person),
                    radius: 25,
                  ),
                  SizedBox(width: 10),

                  // Seller Information
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sellerData!['name'] ?? 'Unknown User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Location: ${sellerData!['location'] ?? 'Unknown'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Message Seller Button
                  Flexible(
                    flex: 2,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          User? currentUser =
                              FirebaseAuth.instance.currentUser;
                          if (currentUser == null) {
                            // Prompt user to log in
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Please log in to message the seller.")),
                            );
                            return;
                          }

                          String buyerId = currentUser.uid;
                          String sellerId = widget.listing['userId'];

                          // Avoid messaging oneself
                          if (buyerId == sellerId) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "You cannot message yourself.")),
                            );
                            return;
                          }

                          // Get or create conversation
                          String conversationId =
                          await _getOrCreateConversation(
                              buyerId, sellerId);

                          String otherUserName =
                              sellerData?['name'] ?? 'Seller';
                          String? otherUserProfilePic =
                          sellerData?['profileImage'];

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                conversationId: conversationId,
                                otherUserId: sellerId,
                                otherUserName: otherUserName,
                                otherUserProfilePic:
                                otherUserProfilePic,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Message Seller',
                          textAlign: TextAlign.center,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}