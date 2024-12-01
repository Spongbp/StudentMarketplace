import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // For making HTTP requests
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pages/home_page.dart';
import '../pages/profile_page.dart';

class AddItemPage extends StatefulWidget {
  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Dropdown selections
  String? _selectedLocation;
  String? _selectedCategory;
  String? _selectedCondition;

  // Image handling
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  bool _isPosting = false; // To manage loading state

  // Predefined lists
  final List<String> _locations = ["Abbotsford", "Mission", "Hope", "Chilliwack"];
  final List<String> _categories = ["Books", "Electronics", "Furniture", "Renting", "Other"];
  final List<String> _conditions = ["New", "Fairly New", "Used", "Heavily Used"];

  // Cloudinary Credentials
  final String cloudName = 'dyzcieqym';
  final String uploadPreset = 'flutter_preset';

  @override
  void dispose() {
    // Dispose controllers
    _productNameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Function to pick images
  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        if (_images.length + pickedFiles.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("You can only upload up to 5 images.")),
          );
          return;
        }
        setState(() {
          _images.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)));
        });
      }
    } catch (e) {
      print("Error picking images: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to pick images.")),
      );
    }
  }

  // Function to remove an image
  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // Function to upload images to Cloudinary and get their URLs
  Future<List<String>> _uploadImagesToCloudinary() async {
    List<String> imageUrls = [];
    for (var image in _images) {
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
        );
        request.fields['upload_preset'] = uploadPreset;
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            image.path,
            filename: fileName,
          ),
        );

        var response = await request.send();
        if (response.statusCode == 200) {
          var responseData = await response.stream.bytesToString();
          var jsonResponse = json.decode(responseData);
          imageUrls.add(jsonResponse['secure_url']);
        } else {
          print('Failed to upload image to Cloudinary. Status Code: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload some images.")),
          );
        }
      } catch (e) {
        print('Error uploading image to Cloudinary: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload some images.")),
        );
      }
    }
    return imageUrls;
  }

  // Function to post the listing
  Future<void> _postListing() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload at least one image.")),
      );
      return;
    }

    if (_selectedLocation == null || _selectedCategory == null || _selectedCondition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select all dropdown fields.")),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      List<String> imageUrls = await _uploadImagesToCloudinary();

      if (imageUrls.isEmpty) {
        setState(() {
          _isPosting = false;
        });
        return;
      }

      // Get current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not authenticated.")),
        );
        setState(() {
          _isPosting = false;
        });
        return;
      }

      // Create a new listing in Firestore
      await FirebaseFirestore.instance.collection('listings').add({
        'title': _productNameController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descriptionController.text.trim(),
        'location': _selectedLocation!,
        'category': _selectedCategory!,
        'condition': _selectedCondition!,
        'images': imageUrls,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Listing posted successfully!")),
      );

      // Navigate to Home Page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => UFVHomePage()),
            (route) => false,
      );
    } catch (e) {
      print("Error posting listing: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to post listing. Please try again.")),
      );
    } finally {
      setState(() {
        _isPosting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 33),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => UFVHomePage()),
                  (route) => false,
            );
          },
        ),
        title: Text('Add Item'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 33),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isPosting
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // Form key for validation
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: ImageUploader(
                    images: _images,
                    removeImage: _removeImage,
                    pickImages: _pickImages,
                  ),
                ),
                SizedBox(height: 10),
                ProductNameField(controller: _productNameController),
                SizedBox(height: 15),
                PriceField(controller: _priceController),
                SizedBox(height: 15),
                DescriptionField(controller: _descriptionController),
                SizedBox(height:10),
                LocationDropdown(
                  selectedLocation: _selectedLocation,
                  onChanged: (value) {
                    setState(() {
                      _selectedLocation = value;
                    });
                  },
                  locations: _locations,
                ),
                SizedBox(height: 10),
                CategoryDropdown(
                  selectedCategory: _selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  categories: _categories,
                ),
                SizedBox(height: 10),
                ConditionDropdown(
                  selectedCondition: _selectedCondition,
                  onChanged: (value) {
                    setState(() {
                      _selectedCondition = value;
                    });
                  },
                  conditions: _conditions,
                ),
                SizedBox(height: 40),
                Center(
                  child: ElevatedButton(
                    onPressed: _postListing,
                    child: Text(
                      'Post',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Widget for uploading multiple images with a restriction
class ImageUploader extends StatelessWidget {
  final List<File> images;
  final Function(int) removeImage;
  final VoidCallback pickImages;

  ImageUploader({required this.images, required this.removeImage, required this.pickImages});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: pickImages,
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(Icons.add, size: 40, color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          "You can only upload up to 5 images",
          style: TextStyle(color: Colors.red[300], fontSize: 14),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(images.length, (index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(images[index], width: 100, height: 100, fit: BoxFit.cover),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => removeImage(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.delete, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

// Widget for product name input
class ProductNameField extends StatelessWidget {
  final TextEditingController controller;

  ProductNameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Product Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter Product Name",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the product name';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// Widget for price input
class PriceField extends StatelessWidget {
  final TextEditingController controller;

  PriceField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Price (\CAD)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: "Enter Price in dollars",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the price';
            }
            if (double.tryParse(value.trim()) == null) {
              return 'Please enter a valid number';
            }
            if (double.parse(value.trim()) < 0) {
              return 'Price cannot be negative';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// Widget for description input
class DescriptionField extends StatelessWidget {
  final TextEditingController controller;

  DescriptionField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        TextFormField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Enter Description",
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter the product description';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// Dropdown for selecting location
class LocationDropdown extends StatelessWidget {
  final List<String> locations;
  final String? selectedLocation;
  final Function(String?) onChanged;

  LocationDropdown({required this.locations, required this.selectedLocation, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedLocation,
          decoration: InputDecoration(
            hintText: "Select Location",
            border: OutlineInputBorder(),
          ),
          items: locations.map((location) {
            return DropdownMenuItem<String>(
              value: location,
              child: Text(location),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select the location';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// Dropdown for selecting category
class CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onChanged;

  CategoryDropdown({required this.categories, required this.selectedCategory, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedCategory,
          decoration: InputDecoration(
            hintText: "Select Category",
            border: OutlineInputBorder(),
          ),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select the category';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// Dropdown for selecting item condition
class ConditionDropdown extends StatelessWidget {
  final List<String> conditions;
  final String? selectedCondition;
  final Function(String?) onChanged;

  ConditionDropdown({required this.conditions, required this.selectedCondition, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Condition", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: selectedCondition,
          decoration: InputDecoration(
            hintText: "Select Condition",
            border: OutlineInputBorder(),
          ),
          items: conditions.map((condition) {
            return DropdownMenuItem<String>(
              value: condition,
              child: Text(condition),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select the condition';
            }
            return null;
          },
        ),
      ],
    );
  }
}