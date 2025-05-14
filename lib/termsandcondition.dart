import 'package:flutter/material.dart';
import 'colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Terms and Conditions',
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
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black87,
                    height: 1.6,
                    letterSpacing: 0.4,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    TextSpan(
                      text: 'What this Privacy Policy Covers\n\n',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'You agree to indemnify, defend and hold us and our partners, attorneys, staff, and affiliates (collectively, "Affiliated Parties") harmless from any liability, loss, claim, and expense, including reasonable attorney\'s fees, related to your violation of this Agreement or use of the Site.\n\n',
                    ),
                    TextSpan(
                      text: 'Non-Transferable\n\n',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'Your right to use the Site is not transferable. Any password or right given to you to obtain information or documents is not transferable.\n\n',
                    ),
                    TextSpan(
                      text: 'Disclaimer\n\n',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'The information and services may contain bugs, errors, problems, or other limitations. We and our affiliated parties have no liability whatsoever for your use of any information or service... (continued)\n\n',
                    ),
                    TextSpan(
                      text: 'Use of Information\n\n',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'We reserve the right, and you authorize us, to the use and assignment of all information regarding Site uses by you and all information provided by you in any manner consistent with our Privacy Policy.\n\n',
                    ),
                    TextSpan(
                      text: 'Privacy Policy\n\n',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'Our Privacy Policy, as it may change from time to time, is a part of this Agreement.\n\n',
                    ),
                    TextSpan(
                      text: 'Information and Press Releases\n\n',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text:
                      'The Site may contain information and press releases about us... should not be relied upon as being provided or endorsed by us.',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}