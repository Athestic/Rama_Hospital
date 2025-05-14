import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'colors.dart';


class PaymentOptionsScreen extends StatefulWidget {
  final double amount;

  PaymentOptionsScreen({required this.amount});

  @override
  _PaymentOptionsScreenState createState() => _PaymentOptionsScreenState();
}

class _PaymentOptionsScreenState extends State<PaymentOptionsScreen> {
  late Razorpay _razorpay;
  bool _isPaymentProcessing = false;  // Flag to check payment status

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startPayment() {
    setState(() {
      _isPaymentProcessing = true;
    });

    var options = {
      'key': 'PHXbP0J6w2FK0L', // Replace with your Razorpay Key
      'amount': 100, // Amount in paisa
      'name': 'Rama Hospital',
      'description': 'Appointment Payment',
      'prefill': {
        'contact': '9876543210', // User's phone number
        'email': 'user@example.com' // User's email
      },
      'theme': {
        'color': '#FF6F00' // Change color to match your theme
      }
    };
    // (widget.amount * 100).toInt()
    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() {
        _isPaymentProcessing = false;
      });
      print("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _isPaymentProcessing = false;
    });

    // Show success animation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Payment Successful"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/icon/paymentdone.json', width: 150, height: 150),
            SizedBox(height: 10),
            Text("Transaction ID: ${response.paymentId}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Return to previous screen
            },
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() {
      _isPaymentProcessing = false;
    });

    // Show error message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Payment Failed"),
        content: Text("Error: ${response.message}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Retry"),
          )
        ],
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() {
      _isPaymentProcessing = false;
    });

    // Handle external wallet selection
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("External Wallet Selected"),
        content: Text("Wallet: ${response.walletName}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Options',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isPaymentProcessing
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('assets/icon/paymentdone.json', width: 200, height: 200),
            SizedBox(height: screenHeight * 0.03),
            Text(
              'Processing Payment...',
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.02,
              ),
              children: [
                Text(
                  'By Razorpay',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.04,
                    fontFamily: "Poppins",
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.payment, color: AppColors.secondaryColor),
                  title: Text('Pay with Razorpay', style: TextStyle(fontSize: screenWidth * 0.040)),
                  onTap: _startPayment,
                ),
              ],
            ),
          ),
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
                  onPressed: _startPayment,
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
                    'Pay Now',
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
