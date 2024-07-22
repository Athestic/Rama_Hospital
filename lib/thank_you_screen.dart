import 'package:bottom_navigation/PatientLogin.dart';
import 'package:bottom_navigation/colors.dart';
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
                backgroundColor: Colors.white,
                foregroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Curved sides
                ),
                padding: EdgeInsets.symmetric(vertical: 16.0), // Vertical padding
              ),
              child: Text('Login to Proceed',
                style: TextStyle(
                fontWeight: FontWeight.bold,
                  fontSize: 15,
                  fontFamily: 'Poppins'
              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}