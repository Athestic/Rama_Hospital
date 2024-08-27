import 'package:bottom_navigation/patient_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:bottom_navigation/PatientLogin.dart';
import 'Homepage.dart';
import 'PatientRegistrationApp.dart';
import 'app_config.dart';
class PatientLogin extends StatefulWidget {
  @override
  _PatientLoginState createState() => _PatientLoginState();
}

class _PatientLoginState extends State<PatientLogin> {
  bool _obscureText = true;
  final TextEditingController _patientidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _loginPatient() async {
    final String patient_id = _patientidController.text;
    final String password = _passwordController.text;

    final Map<String, dynamic> payload = {
      'patient_id':patient_id,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl1}${AppConfig.patientLoginEndpoint}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final patientId = responseData['patientId'] ?? ''; // Correct key name
        final message = responseData['message'] ?? ''; // Provide default value if null

        if (patientId.isEmpty) {
          // Handle the error if patientId is empty
          print('Error: patientId is empty');
          return;
        }

        // Save the patient ID and message to shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('patientId', patientId);
        await prefs.setString('message', message);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PatientProfileScreen(patientId: patientId)),
        );
      } else {
        _showErrorDialog('Login failed', 'Incorrect phone number or password.');
        print('Login failed: ${response.body}');
      }
    } catch (error) {
      _showErrorDialog('Error', 'An error occurred. Please try again.');
      print('Error occurred: $error');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Patient Login',
          style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true, // This ensures the back icon is displayed
      ),
      body: Container(
        color: Colors.grey[200], // Set the background color
        padding: const EdgeInsets.all(26.0),
        child: Column(
          children: <Widget>[
            Spacer(),
            Text(
              'Welcome to Rama',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0), // Adjust the top padding value as needed
              child: Image.asset(
                'assets/Ramalogobgr.png', // Update the path to your logo asset
                height: 130,
              ),
            ),
            TextField(
              controller: _patientidController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
              obscureText: _obscureText,
            ),
            SizedBox(height: 14.0),
            Container(
              width: double.infinity, // Make the button full width
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Add padding for alignment
              child: ElevatedButton(
                onPressed: _loginPatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Curved sides
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0), // Vertical padding
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(fontSize: 16), // Text style
                ),
              ),
            ),
            SizedBox(height: 10.0),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PatientRegistrationForm()),
                );
              },
              child: Text('Register as a new Patient'),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}