import 'package:flutter/material.dart';
import 'colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Text(
            'The Rama Hospital app goes beyond basic healthcare, offering a truly holistic approach to health management right from the user’s device. Along with core features like doctor appointment booking, lab test scheduling, and purchasing medicines, users can access personalized health packages suited to their specific needs, from wellness checkups to preventive care bundles.\n\n'
                'The app also empowers users to keep track of their healthcare journey by offering real-time status updates for every service—whether it’s lab test results, medication deliveries, or appointment confirmations. The ability to view, download, and manage health records and reports ensures that users have complete control and access to their health history, making follow-ups or second opinions hassle-free. Additionally, patients can take advantage of convenient appointment reminders and notifications, ensuring they never miss critical health engagements.\n\n'
                'Designed for ease and efficiency, the Rama Hospital app is a one-stop solution for quality healthcare at your fingertips. Whether managing routine check-ups or seeking urgent care, users can rely on a seamless experience backed by a comprehensive suite of services for optimal health and peace of mind.',
            style: TextStyle(
              fontSize: 16.0,
              fontFamily: 'Poppins',
              color: Colors.black, // Set the text color
              height: 1.5, // Line height for better readability
              letterSpacing: 0.5, // Adjust letter spacing
            ),
            textAlign: TextAlign.justify, // Justify alignment
          ),
        ),
      ),
    );
  }
}
