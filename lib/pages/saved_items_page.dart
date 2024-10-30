import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ufv_app_state.dart';
import 'ufv_page.dart';

class SavedItemsPage extends StatelessWidget {
  final List<Map<String, String>> savedItems;

  SavedItemsPage({required this.savedItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Items'),
      ),
      body: savedItems.isEmpty
          ? Center(child: Text('No items saved'))
          : ListView.builder(
        itemCount: savedItems.length,
        itemBuilder: (context, index) {
          final item = savedItems[index];
          return ListTile(
            leading: Image.network(item['image']!, width: 50, height: 50),
            title: Text(item['name']!),
            subtitle: Text(item['price']!),
          );
        },
      ),
    );
  }
}