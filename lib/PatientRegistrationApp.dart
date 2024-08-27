import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'colors.dart';

void main() {
  runApp(MaterialApp(
    home: RegistrationNavigation(),
  ));
}

class RegistrationNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Registration Navigation'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PatientRegistrationApp()),
            );
          },
          child: Text('Go to Registration Form'),
        ),
      ),
    );
  }
}

class PatientRegistrationApp extends StatefulWidget {
  @override
  _PatientRegistrationFormState createState() => _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<PatientRegistrationApp> {
  final _formKey = GlobalKey<FormState>();
  String? _gender;
  DateTime? _dob;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _aadhaarController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _registerPatient(Map<String, dynamic> patientData) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.106:8083/api/Patient/PatientRegistration'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(patientData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient registered successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register patient: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registering patient: $e')),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formattedDob = DateFormat('dd/MM/yyyy').format(_dob!);

      Map<String, dynamic> patientData = {
        'patientName': _nameController.text,
        'gender': _gender == 'Male' ? 'M' : 'F',
        'phoneNo': _phoneController.text,
        'address': _addressController.text,
        'adharNo': _aadhaarController.text,
        'dob': formattedDob,
      };

      _registerPatient(patientData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text(
        'Patient Registration',
        style: TextStyle(
        color: AppColors.primaryColor,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold),
    ),
        ),
      body: Stack(
        children: [
          // Curved Background
          ClipPath(
            clipper: CurvedClipper(),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.primaryColorShades.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Form Area
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    "R",
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Registration',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 40),
                // Form fields here
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_nameController, "Full Name"),
                      SizedBox(height: 16.0),
                      _buildTextField(_phoneController, "Phone Number"),
                      SizedBox(height: 16.0),
                      _buildTextField(_aadhaarController, "Aadhaar Number"),
                      SizedBox(height: 16.0),
                      _buildTextField(_addressController, "Address"),
                      SizedBox(height: 16.0),
                      _buildDropdownField(),
                      SizedBox(height: 16.0),
                      _buildDateField(),
                      SizedBox(height: 16.0),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(),
        fillColor: Colors.white,
        filled: true,
      ),
      items: ['Male', 'Female']
          .map((gender) => DropdownMenuItem<String>(
        value: gender,
        child: Text(gender),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _gender = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select your gender';
        }
        return null;
      },
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            _dob = pickedDate;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black38),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dob == null ? 'Select Date of Birth' : DateFormat('dd/MM/yyyy').format(_dob!),
              style: TextStyle(color: Colors.black87),
            ),
            Icon(Icons.calendar_today, color: Colors.black87),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Submit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.7);
    var firstControlPoint = Offset(size.width * 0.5, size.height);
    var firstEndPoint = Offset(size.width, size.height * 0.7);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
