import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'patient_profile.dart';
import 'Homepage.dart';
import 'colors.dart';

class PatientLogin extends StatefulWidget {
  @override
  _PatientLoginState createState() => _PatientLoginState();
}

class _PatientLoginState extends State<PatientLogin> {
  bool _obscureText = true;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getString('patientId');
    final token = prefs.getString('jwtToken');

    if (patientId != null && token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => PatientProfileScreen(patientId: patientId)),
      );
    }
  }

  Future<void> _loginPatient() async {
    final String phoneNo = _phoneController.text;
    final String password = _passwordController.text;

    final Map<String, dynamic> payload = {
      'phone_no': phoneNo,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.106:8081/api/HospitalApp/PatientLogin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['message'] ?? '';
        final patientId = responseData['patientId'] ?? '';

        if (patientId.isNotEmpty && token.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('patientId', patientId);
          await prefs.setString('jwtToken', token);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => PatientProfileScreen(patientId: patientId)),
          );
        } else {
          _showErrorDialog('Login failed', 'Incorrect phone number or password.');
        }
      } else {
        _showErrorDialog('Login failed', 'Incorrect phone number or password.');
      }
    } catch (error) {
      _showErrorDialog('Error', 'An error occurred. Please try again.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              "Account Login",
              style: TextStyle(
                color: AppColors.primaryColor,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, size: 24.sp),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                      (Route<dynamic> route) => false,
                );
              },
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 90.w), // Set a max width for large screens
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: orientation == Orientation.portrait ? 0.h : 4.h),
                      Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Image.asset(
                          'assets/logo/mainlogo.png',
                          height: orientation == Orientation.portrait ? 15.h : 10.h,
                          width: orientation == Orientation.portrait ? 75.w : 60.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone, size: 18.sp),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock, size: 18.sp),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility : Icons.visibility_off,
                              size: 18.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(),
                        ),
                        obscureText: _obscureText,
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loginPatient,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                          ),
                          child: Text('Log In', style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
