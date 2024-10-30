import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ufv_app_state.dart';
import '../pages/home_page.dart';
import '../pages/saved_items_page.dart';
import '../pages/campus_page.dart';
import '../pages/add_item_page.dart';
import '../pages/profile_page.dart';


void main() {
  runApp(UFVApp());
}

class UFVApp extends StatelessWidget {
  const UFVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UFVAppState(),
      child: MaterialApp(
        title: 'UFV Student Marketplace',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: UFVHomePage(),
      ),
    );
  }
}

