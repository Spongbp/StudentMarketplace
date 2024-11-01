import 'package:flutter/material.dart';
import '../pages/home_page.dart';

class SignInPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>(); // Form key for validation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow in case of smaller screens
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Large Logo at the top, centered
                Center(
                  child: Image.asset(
                    'assets/Student MarketPlace.png', // Path to your logo image asset
                    height: 300, // Increased height
                    width: 300, // Increased width
                  ),
                ),
                SizedBox(height: 10), // Space below the logo to separate it from the form
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => UFVHomePage()),
                      );
                    }
                  },
                  child: Text('Login'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup'); // Navigate to SignUpPage
                  },
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.green
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
