import 'package:flutter/material.dart';
import 'package:global/Homepage.dart';
import 'package:global/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Add this import for date formatting
import 'review.dart';

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
              MaterialPageRoute(builder: (context) => PatientRegistrationForm()),
            );
          },
          child: Text('Book Appointment'),
        ),
      ),
    );
  }
}

class PatientRegistrationForm extends StatefulWidget {
  @override
  _PatientRegistrationFormState createState() =>
      _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<PatientRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  bool isPatientLoggedIn = false;
  late PageController _pageController;
  List<Map<String, dynamic>> _states = [];
  String? _selectedState;
  String? _gender;
  String? unitId;
  String? doctorId;
  String? doctorName;
  double? consultationFee;
  String? patientId; // For storing patient ID if already logged in
  DateTime? _selectedDate; // Store the selected date
  String? doctorImg;
  String? experience; // For storing doctor image URL or path
  String? _selectedTimeSlot;

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
    _getunitId();
    _getdoctorId();
    _getdoctorName();
    _getconsultationfee();
    _checkLoginStatus(); // Check if the user is already logged in
  }

  Future<void> _getunitId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    unitId = prefs.getString('unitId') ?? '0';
  }

  Future<void> _getdoctorId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    doctorId = prefs.getString('doctorId') ?? '0';
  }

  Future<void> _getdoctorName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    doctorName = prefs.getString('doctorName') ?? '0';
  }

  Future<void> _getconsultationfee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    consultationFee = prefs.getDouble('consultationFee') ?? 0.0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchStates() async {
    try {
      var uri = Uri.parse(
          'http://192.168.1.106:8081/api/HospitalApp/GetState');
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

    if (patientId != null && patientId!.isNotEmpty) {
      setState(() {
        isPatientLoggedIn = true; // Set flag to true if patient is logged in
      });
      print('Patient already logged in with ID: $patientId');
      // Fetch required data and show the date/time picker immediately
      await _getunitId();
      await _getdoctorId();
      await _getdoctorName();
      await _getconsultationfee();
      _showDateTimePickerBottomSheet();
    }
  }

  Future<void> _showDateTimePickerBottomSheet() async {
    DateTime now = DateTime.now();
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 0);
    List<DateTime> availableDates = [];

    for (DateTime date = now; date.isBefore(endOfMonth.add(Duration(days: 1))); date = date.add(Duration(days: 1))) {
      availableDates.add(date);
    }

    List<String> morningSlots = [];
    for (int hour = 10; hour <= 12; hour++) {
      morningSlots.add('${hour % 12 == 0 ? 12 : hour % 12}:00 AM');
      morningSlots.add('${hour % 12 == 0 ? 12 : hour % 12}:30 AM');
    }

    List<String> eveningSlots = [];
    for (int hour = 14; hour <= 17; hour++) {
      eveningSlots.add('${hour % 12 == 0 ? 12 : hour % 12}:00 PM');
      eveningSlots.add('${hour % 12 == 0 ? 12 : hour % 12}:30 PM');
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      isScrollControlled: true,
      isDismissible: true, // Allows closing when clicking outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return GestureDetector(
              onTap: () {
                // When the user taps outside the modal, pop the modal and go back
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Appointment Date and Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: availableDates.length,
                          itemBuilder: (context, index) {
                            DateTime date = availableDates[index];
                            bool isSelectedDate = _selectedDate == date;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  _selectedDate = date;
                                  _selectedTimeSlot = null;
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 8.0),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelectedDate ? AppColors.primaryColor : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: isSelectedDate
                                      ? Border.all(color: Colors.blueAccent, width: 2)
                                      : null,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isSelectedDate ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('MMM').format(date),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelectedDate ? Colors.white : Colors.black,
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Morning Slots (10 AM - 1 PM):',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: morningSlots.map((slot) {
                          bool isSelectedTimeSlot = _selectedTimeSlot == slot && _selectedDate != null;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _selectedTimeSlot = slot;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelectedTimeSlot ? AppColors.primaryColor : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.0),
                                border: isSelectedTimeSlot
                                    ? Border.all(color: Colors.blueAccent, width: 2)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    slot,
                                    style: TextStyle(
                                      color: isSelectedTimeSlot ? Colors.white : Colors.black,
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Evening Slots (2 PM - 6 PM):',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: eveningSlots.map((slot) {
                          bool isSelectedTimeSlot = _selectedTimeSlot == slot && _selectedDate != null;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _selectedTimeSlot = slot;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelectedTimeSlot ? AppColors.primaryColor : Colors.grey[200],
                                borderRadius: BorderRadius.circular(8.0),
                                border: isSelectedTimeSlot
                                    ? Border.all(color: Colors.blueAccent, width: 2)
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    slot,
                                    style: TextStyle(
                                      color: isSelectedTimeSlot ? Colors.white : Colors.black,
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Selected Date and Time:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      // Display the selected date and time dynamically
                      Text(
                        _selectedDate != null && _selectedTimeSlot != null
                            ? 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}\nTime: $_selectedTimeSlot'
                            : _selectedDate != null
                            ? 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}\nTime: None'
                            : 'None',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor:  AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          onPressed: () {
                            // Check if both date and time are selected
                            if (_selectedDate != null && _selectedTimeSlot != null) {
                              Navigator.pop(context); // Close the bottom sheet
                              _showReviewScreen(); // Show the review screen
                            } else {
                              // Display a message if either date or time is not selected
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please select both a date and a time.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Text('Confirm'),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  // Create an instance of the ReviewScreen with the required parameters
    void _showReviewScreen() async {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            gender: _gender,
            state: _selectedState,
            age: _ageController.text,
            phoneNumber: _phoneNumberController.text,
            selectedDate: _selectedDate,
            selectedTimeSlot: _selectedTimeSlot,
            guardian: _guardianNameController.text,
            aadhaarNumber: _aadhaarNumberController.text,
            address: _addressController.text,
            password: _PasswordController.text,
            unitId: unitId,
            doctorId: doctorId,
            experience: experience,
            doctorImg: doctorImg,
            doctorName: doctorName,
            consultationFee: consultationFee,
            patientId: patientId, // Pass patientId to ReviewScreen
          ),
        ),
      );
    }


  @override
  Widget build(BuildContext context) {
    // If the patient is already logged in, show a loader while waiting for the date/time picker
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
              // Add other form fields like age, gender, etc.
              SizedBox(height: 20),
      Container(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _showDateTimePickerBottomSheet();
            }
          },
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
              color: Colors.white,)

      ),
        ),)],
          ),
        ),
      ),
    ));
  }
}
class QRCodeScreen extends StatelessWidget {
  final String message;

  QRCodeScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    // Create a JSON object with the required message format
    String jsonPayload = json.encode({
      "message": message, // Encode the message from the API response (hidden patient ID)
    });

    return WillPopScope(
      onWillPop: () async {
        // Navigate to homepage (RegistrationNavigation) when back is pressed
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => RegistrationNavigation()),
              (Route<dynamic> route) => false, // Removes all previous routes
        );
        return false; // Prevent default back action
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'QR Code',
            style: TextStyle(
              color: Colors.teal,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Your Appointment is successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 20),
              QrImageView(
                data: jsonPayload,  // Data to be encoded in the QR code (hidden patient ID)
                version: QrVersions.auto,
                size: 200.0,
              ),
              SizedBox(height: 20),
              Text(
                'Scan the QR code to view details.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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