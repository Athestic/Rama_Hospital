import 'package:bottom_navigation/Homepage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'PatientRegistrationApp.dart';

class PatientLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Patient Login',
          style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true, // This ensures the back icon is displayed
      ),
      body: Container(
        color: Colors.grey[200], // Set the background color
        padding: const EdgeInsets.all(26.0),
        child: Column(
          children: <Widget>[
            Spacer(),
            Text(
              'Welcome to Rama',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            // SizedBox(height: 16.0), // Add some space between the text and the logo
            Padding(
              padding: const EdgeInsets.only(top: 10.0), // Adjust the top padding value as needed
              child: Image.asset(
                'assets/Ramalogobgr.png', // Update the path to your logo asset
                height: 130,
              ),
            ),
            // Spacer(),
            TextField(
              decoration: InputDecoration(
                labelText: 'UHID',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 14.0),
            Container(
              width: double.infinity, // Make the button full width
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Add padding for alignment
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PatientRegistrationForm()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Curved sides
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0), // Vertical padding
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(fontSize: 16), // Text style
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PatientRegistrationForm()),
                );
              },
              child: Text('Register as a new Patient'),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
