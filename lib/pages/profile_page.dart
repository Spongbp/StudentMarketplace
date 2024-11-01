// profile_page.dart

import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Initialize the TabController
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Example data for Listings, Saved Items, and Recently Viewed
  List<String> listings = ["Listing 1", "Listing 2", "Listing 3"];
  List<String> savedItems = ["Saved Item 1", "Saved Item 2"];
  List<String> recentlyViewed = ["Recently Viewed 1"];

  void openSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Opening Settings...")),
    );
  }

  void editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Edit Profile...")),
    );
  }

  void signOut(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signing Out...")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Returns to the homepage or previous screen
          },
        ),
        title: const Center(child: Text("Profile")),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => openSettings(context),
          ),
          const SizedBox(width: 16), // Adds spacing after settings icon
        ],
      ),
      body: Column(
        children: [
          // Profile picture, user info, and edit button section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: AssetImage('assets/user_profile.jpg'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("UFV Student Name",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const Text("student@ufv.ca",
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          const Text("UFV Campus"),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.green),
                  onPressed: () => editProfile(context),
                ),
              ],
            ),
          ),

          // TabBar and TabBarView section for Listings, Saved, and Recently Viewed
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Listings"),
              Tab(text: "Saved"),
              Tab(text: "Recently Viewed"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Listings Tab
                Center(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(listings[index]),
                        leading: const Icon(Icons.list_alt, color: Colors.green),
                      );
                    },
                  ),
                ),
                // Saved Items Tab
                Center(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: savedItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(savedItems[index]),
                        leading: const Icon(Icons.favorite, color: Colors.green),
                      );
                    },
                  ),
                ),
                // Recently Viewed Tab
                Center(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recentlyViewed.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(recentlyViewed[index]),
                        leading: const Icon(Icons.history, color: Colors.green),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Sign Out button at the bottom of the screen
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => signOut(context),
              child: const Text("Sign Out"),
            ),
          ),
        ],
      ),
    );
  }
}
