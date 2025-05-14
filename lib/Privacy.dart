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
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        // iconTheme: IconThemeData(color: AppColors.primaryColor),
        title: Text(
          'Privacy Policy & Terms',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionTitle('1. Information We Collect'),
                  sectionBody(
                    '- User Information: Employee Code or other identification provided during registration.\n'
                        '- Usage Data: Interaction data such as feature usage and frequency of use.\n'
                        '- Feedback and Communication: Any data provided during customer support interactions.',
                  ),
                  SizedBox(height: 16),
                  sectionTitle('2. How We Use Your Information'),
                  sectionBody(
                    '- Delivering and improving the application’s services, such as online appointment booking, medicine purchases, lab test bookings, and other hospital-related services.\n'
                        '- Providing personalized recommendations.\n'
                        '- Ensuring security and preventing misuse.\n'
                        '- Communicating updates, offers, or policy changes.\n'
                        '- Analyzing usage trends to enhance features.',
                  ),
                  SizedBox(height: 24),
                  sectionHeader('Terms and Conditions'),
                  SizedBox(height: 12),
                  sectionTitle('1. Acceptance of Terms'),
                  sectionBody(
                    'By downloading, installing, or using Rama Hospital’s application, you agree to these Terms and Conditions. If you do not agree, discontinue using the application immediately.',
                  ),
                  SizedBox(height: 16),
                  sectionTitle('2. License to Use'),
                  sectionBody(
                    'We grant you a limited, non-exclusive, non-transferable license to use Rama Hospital for personal, non-commercial purposes. You may not:\n\n'
                        '- Reverse-engineer, modify, or reproduce the application.\n'
                        '- Exploit the application for unauthorized or illegal activities.',
                  ),
                  SizedBox(height: 16),
                  sectionTitle('10. Contact Information'),
                  RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      text: 'If You Have any Query Please Contact Us ',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                      children: [
                        TextSpan(
                          text: 'ramahospital@gmail.com',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              final Uri emailUri = Uri(
                                scheme: 'mailto',
                                path: 'ramahospital@gmail.com',
                              );
                              if (!await launchUrl(
                                emailUri,
                                mode: LaunchMode.externalApplication,
                              )) {
                                print('Could not launch $emailUri');
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget sectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget sectionBody(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontFamily: 'Poppins',
        color: Colors.black,
      ),
    );
  }
}