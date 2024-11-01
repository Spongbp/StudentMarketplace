import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddItemPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigates back to the previous screen
          },
        ),
        title: Text('Add Item'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Profile navigation logic here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: ImageUploader()),  // Centered Image upload widget
              SizedBox(height: 10),
              ProductNameField(),              // Product name input field
              SizedBox(height: 15),
              PriceField(),                    // Price input field
              SizedBox(height: 15),
              DescriptionField(),              // Description input field
              SizedBox(height:10),
              LocationDropdown(),              // Location dropdown
              SizedBox(height: 10),
              CategoryDropdown(),              // Category dropdown
              SizedBox(height: 10),
              ConditionDropdown(),             // Condition dropdown
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Submit or post item logic
                  },
                  child: Text(
                    'Post',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget for uploading multiple images with a restriction and a large plus button
class ImageUploader extends StatefulWidget {
  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final List<File> images = []; // Store image files
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker

  Future<void> addImage() async {
    if (images.length >= 5) {
      // Show alert if more than 5 images are attempted
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You can only upload up to 5 images."))
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        images.add(File(pickedFile.path));
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: addImage,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.add, size: 40, color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 50),
        Text(
          "You can only upload up to 5 images",
          style: TextStyle(color: Colors.red[300], fontSize: 14),
        ),
        SizedBox(height: 0),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: images.map((image) {
            int index = images.indexOf(image);
            return Stack(
              children: [
                Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => removeImage(index),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Widget for product name input
class ProductNameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Product Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(decoration: InputDecoration(hintText: "Enter Product Name"),),
      ],
    );
  }
}

// Widget for price input
class PriceField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Price (\$)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: "Enter Price in dollars"),
        ),
      ],
    );
  }
}

// Widget for description input
class DescriptionField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextField(
          maxLines: 3,
          decoration: InputDecoration(hintText: "Enter Description"),
        ),
      ],
    );
  }
}

// Dropdown for selecting location
class LocationDropdown extends StatelessWidget {
  final List<String> locations = ["Abbotsford", "Mission", "Hope", "Chilliwack"];
  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: "Location"),
      items: locations.map((location) {
        return DropdownMenuItem(
          value: location,
          child: Text(location),
        );
      }).toList(),
      onChanged: (newValue) {
        selectedLocation = newValue!;
      },
    );
  }
}

// Dropdown for selecting category
class CategoryDropdown extends StatelessWidget {
  final List<String> categories = ["Books", "Electronics", "Furniture", "Renting"];
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: "Category"),
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (newValue) {
        selectedCategory = newValue!;
      },
    );
  }
}

// Dropdown for selecting item condition
class ConditionDropdown extends StatelessWidget {
  final List<String> conditions = ["New", "Fairly New", "Used", "Heavily Used"];
  String? selectedCondition;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: "Condition"),
      items: conditions.map((condition) {
        return DropdownMenuItem(
          value: condition,
          child: Text(condition),
        );
      }).toList(),
      onChanged: (newValue) {
        selectedCondition = newValue!;
      },
    );
  }
}
