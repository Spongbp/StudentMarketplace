import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/home_page.dart';



// Define Campus Enum
enum Campus {
  campusA,
  campusB,
  campusC,
  campusD,
}

const Map<Campus, String> campusNames = {
  Campus.campusA: 'Abbotsford',
  Campus.campusB: 'Chilliwack',
  Campus.campusC: 'Mission',
  Campus.campusD: 'Hope',
};

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Selected Campus
  Campus? _selectedCampus;

  Future<void> signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCampus == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select your campus.')),
        );
        return;
      }
      try {
        // Create User
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          // Send Email Verification
          await user.sendEmailVerification();

          // Write to Firestore
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'name': _usernameController.text.trim(),
            'email': _emailController.text.trim(),
            'location': campusNames[_selectedCampus!],
            'profilePictureUrl': 'assets/Juvenile_Ragdoll.jpg',
            'favorites': [],
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Navigate or Show Success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification email sent. Please verify your email.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UFVHomePage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle Errors
        String message;
        switch (e.code) {
          case 'weak-password':
            message = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            message = 'An account already exists for that email.';
            break;
          case 'invalid-email':
            message = 'The email address is not valid.';
            break;
          case 'operation-not-allowed':
            message = 'Email/password accounts are not enabled.';
            break;
          default:
            message = 'Verification email sent. Please verify your email.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        print('Error during sign-up: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred.')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose Controllers
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // App Logo
                Center(
                  child: Image.asset(
                    'assets/Student MarketPlace.png',
                    height: 300,
                    width: 300,
                  ),
                ),
                SizedBox(height: 20),
                // Username Input
                TextFormField(
                  controller: _usernameController,
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
                // Email Input
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Password Input
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Confirm Password Input
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Campus Dropdown
                DropdownButtonFormField<Campus>(
                  decoration: InputDecoration(
                    labelText: 'Select Campus',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCampus,
                  items: Campus.values.map((Campus campus) {
                    return DropdownMenuItem<Campus>(
                      value: campus,
                      child: Text(campusNames[campus]!),
                    );
                  }).toList(),
                  onChanged: (Campus? newValue) {
                    setState(() {
                      _selectedCampus = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select your campus';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                // Sign Up Button
                ElevatedButton(
                  onPressed: signUp,
                  child: Text('Sign Up'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    textStyle: TextStyle(fontSize: 18),
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