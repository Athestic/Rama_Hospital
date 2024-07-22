import 'package:flutter/material.dart';

class PatientRegistrationForm extends StatefulWidget {
  @override
  _PatientRegistrationFormState createState() => _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<PatientRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String uhid = '';
  String password = '';
  String confirmPassword = '';
  String mobileNumber = '';
  bool termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Registration',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: SizedBox(
              width: 34,
              height: 34,
              child: Image.asset('assets/Reg_Patient.png'),
            ),
            onPressed: () {
              // Handle button press
            },
          ),
        ],
      ),

      body:
      // Center(child:
      Padding(
          padding: const EdgeInsets.all(26.0),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true, // This prevents the ListView from taking up the entire available space
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  onSaved: (value) => name = value!,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'UHID',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your UHID';
                    }
                    return null;
                  },
                  onSaved: (value) => uhid = value!,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) => password = value!,
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != password) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    return null;
                  },
                  onSaved: (value) => mobileNumber = value!,
                ),
                SizedBox(height: 16.0),
                CheckboxListTile(
                  title: Text("By checking the box you agree to our Terms and Conditions."),
                  value: termsAccepted,
                  onChanged: (bool? value) {
                    setState(() {
                      termsAccepted = value ?? false;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() && termsAccepted) {
                      _formKey.currentState!.save();
                      // Implement registration functionality here
                    } else if (!termsAccepted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('You must accept the terms and conditions')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Curved sides
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0), // Vertical padding
                  ),
                  child: Text('Register'),
                ),
              ],
            ),
          ),
        ),
      // ),
    );
  }
}
