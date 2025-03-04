import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:global/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy & Terms',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,

          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth > 600 ? 40.0 : 20.0,
          vertical: 26.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Information We Collect',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.secondaryColor,
              ),
            ),
            Text(
              'When you use Rama Hospital, we may collect the following types of information:\n\n'
                  '- User Information: Employee Code or other identification provided during registration.\n'
                  '- Usage Data: Interaction data such as feature usage and frequency of use.\n'
                  '- Feedback and Communication: Any data provided during customer support interactions.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '2. How We Use Your Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.secondaryColor,
              ),
            ),
            Text(
              'The information collected is used for:\n\n'
                  '- Delivering and improving the application’s services, such as online appointment booking, medicine purchases, lab test bookings, and other hospital-related services.\n'
                  '- Providing personalized recommendations.\n'
                  '- Ensuring security and preventing misuse.\n'
                  '- Communicating updates, offers, or policy changes.\n'
                  '- Analyzing usage trends to enhance features.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.secondaryColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '1. Acceptance of Terms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.secondaryColor,
              ),
            ),
            Text(
              'By downloading, installing, or using Rama Hospital’s application, you agree to these Terms and Conditions. If you do not agree, discontinue using the application immediately.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
            Text(
              '2. License to Use',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.secondaryColor,
              ),
            ),
            Text(
              'We grant you a limited, non-exclusive, non-transferable license to use Rama Hospital for personal, non-commercial purposes. You may not:\n\n'
                  '- Reverse-engineer, modify, or reproduce the application.\n'
                  '- Exploit the application for unauthorized or illegal activities.',
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: Colors.black,
              ),
            ),
            // ... Remaining sections continue as they are, with "MediClean" replaced with "Rama Hospital"
            // Ensure the email section is updated correctly:
            SizedBox(height: 10),
            Text(
              '10. Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: AppColors.secondaryColor,
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'If You Have any Query Please Contact Us \'ramahospital@gmail.com\'',
                style: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () async {
                    final Uri emailUri = Uri(
                      scheme: 'mailto',
                      path: 'ramahospital@gmail.com',
                    );
                    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
                      print('Could not launch $emailUri');
                    }
                  },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
