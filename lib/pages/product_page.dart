import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';


class ProductPage extends StatelessWidget {
  final Map<String, String> product;

  ProductPage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child:Text('${product['name']}')), // Centered title with product name
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel Slider for multiple images
            CarouselSlider(
              options: CarouselOptions(
                height: 280,
                enlargeCenterPage: false,
                autoPlay: true,
              ),
              items: [
                product['image']!,
                'https://via.placeholder.com/150',
                'https://via.placeholder.com/150',
              ].map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 30),

            // Product title, price, description, and condition section
             Text(
                product['name']!,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

            SizedBox(height: 0),

              Text(
                product['price']!,
                style: TextStyle(fontSize: 24, color: Colors.grey[700]),
              ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "Description",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
                "This is a sample description of the product.",
                style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Condition",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "New",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Divider(thickness: 5),

            // Seller details section with title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                "Seller Details",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage('https://via.placeholder.com/150'),
              ),
              title: Text('Username'),
              subtitle: Text('Location: City, Country'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Add message seller action here
                },
                child: Text('Message Seller'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen, // updated attribute
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
