import 'package:flutter/material.dart';
import 'ufv_page.dart';

class BuyPage extends UFVPage {
  @override
  Widget buildContent(BuildContext context) {
    return Center(
      child: Text(
        'Buy Page',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
