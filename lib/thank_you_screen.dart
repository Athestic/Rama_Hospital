import 'PatientLogin.dart';
import 'colors.dart';
import 'package:flutter/material.dart';

class ThankYouScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/thankyou.png'), // Replace with your image path
            SizedBox(height: 20),
            Text(
              'Thank You!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Your registration was successful.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => PatientLogin()),
                      (Route<dynamic> route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:Colors.white,
               // The background color to match the uploaded image
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // Curved sides
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0), // Vertical and horizontal padding
              ),
              child: Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Adjusted font size to be more readable
                  color: Colors.black,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
