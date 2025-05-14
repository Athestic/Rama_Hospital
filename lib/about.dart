import 'package:flutter/material.dart';
import 'colors.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.backgroundColor, // Light background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'About',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.primaryColor),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Rama Hospital ',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'The Rama Hospital app goes beyond basic healthcare, offering a truly holistic approach to health management right from the user’s device. Along with core features like doctor appointment booking, lab test scheduling, and purchasing medicines, users can access personalized health packages suited to their specific needs, from wellness checkups to preventive care bundles.\n\n'
                        'The app also empowers users to keep track of their healthcare journey by offering real-time status updates for every service—whether it’s lab test results, medication deliveries, or appointment confirmations. The ability to view, download, and manage health records and reports ensures that users have complete control and access to their health history, making follow-ups or second opinions hassle-free.\n\n'
                        'Additionally, patients can take advantage of convenient appointment reminders and notifications, ensuring they never miss critical health engagements.\n\n'
                        'Designed for ease and efficiency, the Rama Hospital app is a one-stop solution for quality healthcare at your fingertips. Whether managing routine check-ups or seeking urgent care, users can rely on a seamless experience backed by a comprehensive suite of services for optimal health and peace of mind.',
                    style: TextStyle(
                      fontSize: 16.0,
                      height: 1.6,
                      letterSpacing: 0.4,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
