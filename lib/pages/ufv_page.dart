import 'package:flutter/material.dart';

abstract class UFVPage extends StatelessWidget {
  const UFVPage({super.key});

  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Center(child: buildContent(context));
  }
}
