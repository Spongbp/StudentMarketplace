import 'package:flutter/material.dart';
import 'ufv_page.dart';

class ProfilePage extends UFVPage {
  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/profile_placeholder.png'), // Replace with a valid image if needed
          ),
          SizedBox(height: 20),
          Text(
            'Profile Page',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'User Name', // Placeholder for the user’s name
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            'user@example.com', // Placeholder for the user’s email
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
