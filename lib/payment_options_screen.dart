import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'colors.dart';

class PaymentOptionsScreen extends StatefulWidget {
  final double amount;

  PaymentOptionsScreen({required this.amount});

  @override
  _PaymentOptionsScreenState createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  bool _isPaymentProcessing = false;  // Flag to check payment status

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Options',
            style: TextStyle(color: AppColors.primaryColor, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isPaymentProcessing
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Lottie.asset('assets/icon/paymentdone.json', width: 200, height: 200),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Your appointment is booked!',
              style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Payment options list
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              children: [
                Text(
                  'Credit/ Debit Card',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                    fontFamily: "Poppins",
                  ),
                ),
                ListTile(
                  title: Text(
                    'Add New Card',
                    style: TextStyle(fontSize: screenWidth * 0.040),
                  ),
                  trailing: Text(
                    'Add',
                    style: TextStyle(
                      color: AppColors.secondaryColor,
                      fontSize: screenWidth * 0.040,
                    ),
                  ),
                  onTap: () {
                    // Navigate to card details entry screen
                  },
                ),
                Divider(),
                Text(
                  'By UPI',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                    fontFamily: "Poppins",
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/icon/googlepay.png',
                    width: screenWidth * 0.07,
                  ),
                  title: Text('Google Pay', style: TextStyle(fontSize: screenWidth * 0.040)),
                  onTap: () {
                    // Handle Google Pay integration
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/icon/phoonepe.png',
                    width: screenWidth * 0.07,
                  ),
                  title: Text('PhonePe', style: TextStyle(fontSize: screenWidth * 0.040)),
                  onTap: () {
                    // Handle PhonePe integration
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/icon/paytm.png',
                    width: screenWidth * 0.07,
                  ),
                  title: Text('Paytm', style: TextStyle(fontSize: screenWidth * 0.040)),
                  onTap: () {
                    // Handle Paytm integration
                  },
                ),
                ListTile(
                  title: Text(
                    'Pay with UPI ID',
                    style: TextStyle(fontSize: screenWidth * 0.040),
                  ),
                  trailing: Text(
                    'Add UPI ID',
                    style: TextStyle(color: AppColors.secondaryColor, fontSize: screenWidth * 0.040),
                  ),
                  onTap: () {
                    // Navigate to UPI ID entry screen
                  },
                ),
                Divider(),
                Text(
                  'Other Payment Methods',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    'assets/icon/Bank.png',
                    width: screenWidth * 0.07,
                  ),
                  title: Text('Net Banking', style: TextStyle(fontSize: screenWidth * 0.040)),
                  trailing: Text(
                    'Pay Now',
                    style: TextStyle(color: AppColors.secondaryColor, fontSize: screenWidth * 0.045, fontFamily: "Poppins"),
                  ),
                  onTap: () {
                    // Handle Net Banking integration
                  },
                ),
              ],
            ),
          ),
          // Bottom amount and button
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.02,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${widget.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.06,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isPaymentProcessing = true;  // Start payment animation
                    });

                    // Simulate a delay for payment processing
                    Future.delayed(Duration(seconds: 3), () {
                      setState(() {
                        // After delay, you can navigate or show confirmation
                      });
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.03,
                      vertical: screenHeight * 0.01,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: AppColors.secondaryColor,
                  ),
                  child: Text(
                    'Pay & Confirm',
                    style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white, fontFamily: "Poppins"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
