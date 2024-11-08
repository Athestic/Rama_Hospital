import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'colors.dart';

class Privacy extends StatelessWidget {
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
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: 'What this Privacy Policy Covers\n\n',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                  'This Privacy Policy covers our treatment of personally identifiable information that we collect when you are on our site, and when you use our services. This policy also covers our treatment of any personally identifiable information that third parties share with us.\n\n This policy does not apply to the practices of organizations that we do not own or control or to people that we do not employ or manage.\n\n',
                ),
                TextSpan(
                  text: 'Information Collection and Use\n\n',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                  'We collect personally identifiable information when you register on our website, when you use our services, and when you visit our pages. We may also receive personally identifiable information from third parties.\n\nWhen you register with us, we ask for your name, email address, zip code, occupation, industry, and personal interests. Once you register with us and sign in to our services, you are not anonymous to us.\n\nWe use this information for three general purposes: to customize the content you see, to fulfill your requests for certain services, and to contact you about services.\n\n',
                ),
                TextSpan(
                  text: 'Information Sharing and Disclosure\n\n',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                  'We will not sell or rent your personally identifiable information to anyone. \n\n We will send personally identifiable information about you to other companies or people when.\n\n We have your consent to share the information.\n\n We respond to subpoenas, court orders or legal process.\n\n',
                ),
                TextSpan(
                  text: 'Changes to this Privacy Policy\n\n',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                  'The privacy policy is subject to modification from time to time. If we decide to change our privacy policy, we will post those changes here so that you will always know what information we gather, how we might use that information and whether we will disclose it to anyone. Any significant changes to our privacy policy will be announced on our home page. If you do not agree with the changes in our policy you can simply discontinue to visit our website.\n\n',
                ),
                TextSpan(
                  text: 'Questions or Suggestions\n\n',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: 'If you have questions or suggestions complete the enquiry form or send an email to us at ',
                ),
                TextSpan(
                  text: 'rtg00112@gmail.com\n\n',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'rtg00112@gmail.com',
                      );

                      try {
                        if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
                          throw 'Could not launch $emailUri';
                        }
                      } catch (e) {
                        print(e);
                      }
                    },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
