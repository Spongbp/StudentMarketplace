import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ufv_app_state.dart';
import 'ufv_page.dart';

class SavedItemsPage extends UFVPage {
  @override
  Widget buildContent(BuildContext context) {
    var appState = context.watch<UFVAppState>();
    return appState.savedItems.isEmpty
        ? Text('No saved items yet.')
        : ListView.builder(
            itemCount: appState.savedItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.bookmark),
                title: Text(appState.savedItems[index]),
              );
            },
          );
  }
}
