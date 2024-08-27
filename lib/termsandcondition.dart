import 'package:flutter/material.dart';
import 'colors.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),),
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
                height: 1.5, // Line spacing
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
                  'You agree to indemnify, defend and hold us and our partners, attorneys, staff, and affiliates (collectively, "Affiliated Parties") harmless from any liability, loss, claim, and expense, including reasonable attorney\'s fees, related to your violation of this Agreement or use of the Site.\n\n',
                ),
                TextSpan(
                  text: 'Non-Transferable\n\n',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontFamily: 'Poppins',
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
                    color: AppColors.secondaryColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                  'The information and services may contain bugs, errors, problems, or other limitations. We and our affiliated parties have no liability whatsoever for your use of any information or service. In particular, but not as a limitation thereof, we and our affiliated parties are not liable for any indirect, special, incidental, or consequential damages (including damages for loss of business, loss of profits, litigation, or the like), whether based on breach of contract, breach of warranty, tort (including negligence), product liability, or otherwise, even if advised of the possibility of such damages. The negation of damages set forth above are fundamental elements of the basis of the bargain between us and you. This site and the information would not be provided without such limitations. No advice or information, whether oral or written, obtained by you from us through the site shall create any warranty, representation, or guarantee not expressly stated in this agreement.\n\n',
                ),
                TextSpan(
                  text: 'Use of Information\n\n',
                  style: TextStyle(
                    color: AppColors.secondaryColor,
                    fontFamily: 'Poppins',
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
                    color: AppColors.secondaryColor,
                    fontFamily: 'Poppins',
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
                    color: AppColors.secondaryColor,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                  'The Site may contain information and press releases about us. While this information was believed to be accurate as of the date prepared, we disclaim any duty or obligation to update this information or any press releases. Information about companies other than ours contained in the press release or otherwise should not be relied upon as being provided or endorsed by us.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
