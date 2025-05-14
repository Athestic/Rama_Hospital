import 'package:flutter/material.dart';
import 'package:global/Homepage.dart';
import 'package:global/colors.dart';
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
    specializationName =
        prefs.getString('specializationName'); // Fetch specializationName


    if (patientId != null && patientId!.isNotEmpty) {
      setState(() {
        isPatientLoggedIn = true;
      });
      print('Patient already logged in with ID: $patientId');
    }
  }

  Future<void> _registerPatient() async {
    final url = Uri.parse(
        '${AppConfig.apiUrl1}${AppConfig.patientRegistrationAppEndpoint}');
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
        "state_id": _selectedState != null ? int.tryParse(
            _selectedState!.trim()) : null,
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
          _navigateToReviewScreen(patientId); // Navigate to the next screen
        } else {
          _showErrorDialog('Unexpected server response. Please try again.');
        }
      } else {
        _showErrorDialog(
            'Failed to register patient. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorDialog(
          'An error occurred while connecting to the server. Please check your connection and try again.\n\nError: $error');
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
        builder: (context) =>
            ReviewScreen(

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
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final labelStyle = TextStyle(
      color: Colors.grey[800],
      fontSize: 15,
      fontWeight: FontWeight.w500,
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      labelStyle: labelStyle,
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(
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
        // elevation: 0,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.pop(context),
        // ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () {
                // Handle tap on the custom icon
                print("Custom icon tapped");
              },
              child: Image.asset(
                'assets/Reg_Patient.png',
                width: 28,
                height: 28,
              ),
            ),
          ),
        ],
      ),


      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: inputDecoration.copyWith(
                          labelText: 'First Name',
                          hintText: 'Enter first name'),
                      validator: (value) =>
                      value!.isEmpty
                          ? 'Please enter your first name'
                          : null,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: inputDecoration.copyWith(
                          labelText: 'Last Name', hintText: 'Enter last name'),
                      validator: (value) =>
                      value!.isEmpty
                          ? 'Please enter your last name'
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _guardianNameController,
                      decoration: inputDecoration.copyWith(
                          labelText: 'Guardian Name',
                          hintText: 'Enter guardian name'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: inputDecoration.copyWith(
                          labelText: 'Age', hintText: 'Enter age'),
                      validator: (value) =>
                      value!.isEmpty
                          ? 'Please enter your age'
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: inputDecoration.copyWith(
                    labelText: 'Phone Number', hintText: 'Enter phone number'),
                validator: (value) =>
                value!.isEmpty
                    ? 'Please enter phone number'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _aadhaarNumberController,
                decoration: inputDecoration.copyWith(
                    labelText: 'Aadhaar Number',
                    hintText: 'Enter Aadhaar number'),
                validator: (value) =>
                value!.isEmpty
                    ? 'Please enter Aadhaar number'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: inputDecoration.copyWith(
                    labelText: 'Address', hintText: 'Enter address'),
                validator: (value) =>
                value!.isEmpty
                    ? 'Please enter address'
                    : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: inputDecoration.copyWith(labelText: 'Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((gender) =>
                    DropdownMenuItem(value: gender, child: Text(gender)))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value),
                validator: (value) =>
                value == null
                    ? 'Please select your gender'
                    : null,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedState,
                decoration: inputDecoration.copyWith(labelText: 'State'),
                items: _states.map((state) {
                  return DropdownMenuItem(
                    value: state['stateId'].toString(),
                    child: Text(state['stateName']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedState = value),
                validator: (value) =>
                value == null
                    ? 'Please select your state'
                    : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _PasswordController,
                obscureText: _isObscure,
                decoration: inputDecoration.copyWith(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isObscure = !_isObscure),
                  ),
                ),
                validator: (value) =>
                value!.isEmpty
                    ? 'Please enter password'
                    : null,
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isButtonEnabled
                      ? () {
                    if (_formKey.currentState!.validate()) {
                      setState(() => _isButtonEnabled = false);
                      _registerPatient();
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QRCodeScreen extends StatelessWidget {
  final String message;
  DateTime? selectedDate = SelectedAppointment().selectedDate;
  String? selectedSlot = SelectedAppointment().selectedSlot;

  QRCodeScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    // Format the date to `YYYY-MM-DD`
    String? formattedDate = selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(selectedDate!)
        : null;

    String jsonPayload = json.encode({
      "Message": message,
      "Date": formattedDate,
      "Time": selectedSlot,
    });

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => RegistrationNavigation()),
              (Route<dynamic> route) => false,
        );
        return false;
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
                data: jsonPayload,
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
              SizedBox(height: 20),


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