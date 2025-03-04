import 'package:flutter/material.dart';
import 'package:global/Homepage.dart';
import 'package:global/Medicine.dart';
import 'package:global/colors.dart';
import 'package:global/labtest.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'review.dart';
import 'app_config.dart';
import 'dateandtimeslot.dart';

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
              MaterialPageRoute(builder: (context) => PatientRegistrationForm2()),
            );
          },
          child: Text('Book Appointment'),
        ),
      ),
    );
  }
}

class PatientRegistrationForm2 extends StatefulWidget {
  @override
  _PatientRegistrationFormState createState() =>
      _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<PatientRegistrationForm2> {
  final _formKey = GlobalKey<FormState>();
  bool isPatientLoggedIn = false;
  late PageController _pageController;
  List<Map<String, dynamic>> _states = [];
  String? _selectedState;
  String? _gender;
  int? unitId;
  int? doctorId;
  String? doctorName;
  double? consultationFee;
  String? patientId;
  bool _isButtonEnabled = true;
  String? doctorImg;
  String? experience;
  String? specializationName;
  final selectedDate = SelectedAppointment().selectedDate;
  final selectedSlot = SelectedAppointment().selectedSlot;



  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _aadhaarNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _PasswordController = TextEditingController();
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchStates();
    _getUnitId();
    _getDoctorId();
    _getConsultationFee();
    _checkLoginStatus();
    print("Selected Date: $selectedDate");
    print("Selected Slot: $selectedSlot");
  }

  Future<void> _getUnitId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      unitId = prefs.getInt('unitId');
    });
  }

  Future<void> _getDoctorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      doctorId = prefs.getInt('doctorId');
    });
  }

  Future<void> _getConsultationFee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      consultationFee = prefs.getDouble('consultationFee') ?? 50.0;
    });
  }



  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchStates() async {
    try {
      var uri = Uri.parse('${AppConfig.apiUrl1}${AppConfig.getStateEndpoint}');
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> statesData = json.decode(response.body);
        setState(() {
          _states = statesData.map((state) {
            return {
              'stateId': state['stateId'],
              'stateName': state['stateName'],
            };
          }).toList();
        });
      } else {
        print('Failed to load states: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    patientId = prefs.getString('patientId');
    doctorName = prefs.getString('doctorName');
    doctorImg = prefs.getString('doctorImg');
    experience = prefs.getString('experience');
    specializationName = prefs.getString('specializationName'); // Fetch specializationName


    if (patientId != null && patientId!.isNotEmpty) {
      setState(() {
        isPatientLoggedIn = true;
      });
      print('Patient already logged in with ID: $patientId');

    }
  }

  Future<void> _registerPatient() async {
    final url = Uri.parse('http://192.168.1.144:8081/api/HospitalApp/PatientRegistrationApp');

    // Disable the button by setting the state
    setState(() {
      _isButtonEnabled = false;
    });

    try {
      // Preparing request body
      final requestBody = jsonEncode({
        "first_name": _firstNameController.text.trim(),
        "last_name": _lastNameController.text.trim(),
        "gender": _gender == "Male"
            ? "M"
            : _gender == "Female"
            ? "F"
            : "O",
        "age": int.tryParse(_ageController.text.trim()) ?? 0,
        "phone_no": _phoneNumberController.text.trim(),
        "father_spouse_name": _guardianNameController.text.trim(),
        "address": _addressController.text.trim(),
        "state_id": _selectedState != null ? int.tryParse(_selectedState!.trim()) : null,
        "AdharNo": _aadhaarNumberController.text.trim(),
        "Password": _PasswordController.text.trim(),
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData.containsKey('message')) {
          final patientId = responseData['message'];
          // _navigateToReviewScreen(patientId); // Navigate to the next screen
        } else {
          _showErrorDialog('Unexpected server response. Please try again.');
        }
      } else {
        _showErrorDialog('Failed to register patient. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorDialog('An error occurred while connecting to the server. Please check your connection and try again.\n\nError: $error');
    } finally {
      // Re-enable the button regardless of the outcome
      setState(() {
        _isButtonEnabled = true;
      });
    }
  }



  void _navigateToReviewScreen(String patientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewScreen(

          patientId: patientId,
          specializationName: specializationName,
        ),
      ),
    );
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isPatientLoggedIn) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Patient Registration',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            hintText: 'Enter your first name',
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 16.0), // Space between the fields
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            hintText: 'Enter your last name',
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      // Guardian Name Field
                      Expanded(
                        flex: 2,  // Adjust flex to control how much space each takes
                        child: TextFormField(
                          controller: _guardianNameController,
                          decoration: InputDecoration(
                            labelText: 'Guardian Name',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            hintText: 'Enter guardian name',
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0),  // Add space between the two fields

                      // Age Field
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Age',
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize: 16.0,
                            ),
                            hintText: 'Enter your age',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),


                  TextFormField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      hintText: 'Enter phone number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller:  _aadhaarNumberController,
                    decoration: InputDecoration(
                      labelText: 'Aadhaar Number',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      hintText: 'Enter Aadhaar number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Aadhaar number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      hintText: 'Enter address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 16.0),
                      border: OutlineInputBorder(),
                    ),
                    items: ['Male', 'Female', 'Other']
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
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: InputDecoration(
                      labelText: 'State',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 16.0),
                      border: OutlineInputBorder(),
                    ),
                    items: _states
                        .map((state) => DropdownMenuItem<String>(
                      value: state['stateId'].toString(),
                      child: Text(state['stateName']),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select your state';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _PasswordController,
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black, fontSize: 16.0),
                      hintText: 'Enter password',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _isObscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: _isButtonEnabled
                        ? () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isButtonEnabled = false; // Disable button
                        });
                        _registerPatient();

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LabTestBooking()),
                        );
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ),
        ));
  }
}
// class QRCodeScreen extends StatelessWidget {
//   final String message;
//
//   QRCodeScreen({required this.message});
//
//   @override
//   Widget build(BuildContext context) {
//
//     String jsonPayload = json.encode({
//       "message": message,
//     });
//
//     return WillPopScope(
//       onWillPop: () async {
//
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => RegistrationNavigation()),
//               (Route<dynamic> route) => false,
//         );
//         return false;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'QR Code',
//             style: TextStyle(
//               color: Colors.teal,
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           centerTitle: true,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.black),
//             onPressed: () {
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => HomeScreen()),
//                     (Route<dynamic> route) => false,
//               );
//             },
//           ),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Your Appointment is successful!',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.primaryColor,
//                 ),
//               ),
//               SizedBox(height: 20),
//               QrImageView(
//                 data: jsonPayload,
//                 version: QrVersions.auto,
//                 size: 200.0,
//               ),
//               SizedBox(height: 20),
//               Text(
//                 'Scan the QR code to view details.',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height - 50);

    var firstControlPoint = Offset(size.width / 2, size.height);
    var firstEndPoint = Offset(size.width, size.height - 50);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}