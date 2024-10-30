import 'package:flutter/material.dart';
import 'ufv_page.dart';

class AddItemPage extends UFVPage {
  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Add Item",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ImageUploadSection(),
            SizedBox(height: 20),
            ItemFormFields(),
            SizedBox(height: 20),
            Center(
              child: PostButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageUploadSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8.0,
        children: List.generate(5, (index) => ImageBox()),
      ),
    );
  }
}

class ImageBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(child: Icon(Icons.add, color: Colors.grey)),
    );
  }
}

class ItemFormFields extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(label: "Product name:"),
        CustomTextField(label: "Price:"),
        CustomTextField(label: "Description:"),
        CustomTextField(label: "Location:"),
        CustomTextField(label: "Category:"),
        ConditionOptions(),
      ],
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  const CustomTextField({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label),
        SizedBox(width: 10),
        Expanded(child: TextField()),
      ],
    );
  }
}

class ConditionOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Condition:"),
        SizedBox(width: 10),
        Expanded(
          child: Wrap(
            spacing: 8.0,
            children: [
              ChoiceChip(label: Text("Excellent"), selected: false),
              ChoiceChip(label: Text("Very Good"), selected: false),
              ChoiceChip(label: Text("Good"), selected: false),
            ],
          ),
        ),
      ],
    );
  }
}

class PostButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Implement post functionality
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      ),
      child: Text('Post'),
    );
  }
}
