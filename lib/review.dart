import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'patient_registration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String? gender;
  final String? state;
  final String age;
  final String phoneNumber;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final String guardian;
  final String aadhaarNumber;
  final String address;
  final String password;
  final String? unitId;
  final String? doctorId;
  final String? experience;
  final String? doctorImg;
  final String? doctorName;
  final double? consultationFee;
  final String? patientId;
  final double serviceCharge = 50;

  ReviewScreen({
    required this.firstName,
    required this.lastName,
    this.gender,
    this.state,
    required this.age,
    required this.phoneNumber,
    this.selectedDate,
    this.selectedTimeSlot,
    required this.guardian,
    required this.aadhaarNumber,
    required this.address,
    required this.password,
    this.unitId,
    this.doctorId,
    this.experience,
    this.doctorImg,
    this.doctorName,
    this.consultationFee,
    this.patientId,
  });

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late String firstName;
  late String lastName;
  late String gender;
  late String guardian;
  late String aadhaarNumber;
  late String phoneNumber;
  late String age;

  @override
  void initState() {
    super.initState();


    // Initialize with provided values
    firstName = widget.firstName;
    lastName = widget.lastName;
    gender = widget.gender ?? 'Male';
    guardian = widget.guardian;
    aadhaarNumber = widget.aadhaarNumber;
    phoneNumber = widget.phoneNumber;
    age = widget.age;

    // Fetch details if patientId is provided
    if (widget.patientId != null) {
      fetchPatientDetails();
    }
  }

  Future<void> fetchPatientDetails() async {
    final String apiUrl = 'http://192.168.1.106:8081/api/HospitalApp/GetPatientById?PatientId=${widget.patientId}';
    try {
      final response = await http.get(Uri.parse(apiUrl)); // Removed the redundant query parameter
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          firstName = responseData['first_name'] ?? firstName;
          lastName = responseData['last_name'] ?? lastName;
          gender = responseData['gender'] ?? gender;
          guardian = responseData['father_spouse_name'] ?? guardian;
          aadhaarNumber = responseData['adharNo'] ?? aadhaarNumber;
          phoneNumber = responseData['phone_no'] ?? phoneNumber;
          age = responseData['age']?.toString() ?? age;
        });
      } else {
        print('Failed to fetch patient details. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching patient details: $e");
    }
  }

  double get totalCharges {
    return (widget.consultationFee ?? 0.0) + widget.serviceCharge;
  }

  Future<void> registerPatient(BuildContext context) async {
    if (widget.patientId != null) {
      await _registerOpd(context, widget.patientId!, widget.unitId!, widget.doctorId!, widget.consultationFee!);
      return;
    }

    final String apiUrl = 'http://192.168.1.106:8081/api/HospitalApp/PatientRegistrationApp';
    String genderCode = (gender.toLowerCase() == 'female') ? 'F' : 'M';

    final Map<String, dynamic> postData = {
      'first_name': firstName,
      'last_name': lastName,
      'gender': genderCode,
      'age': int.tryParse(age) ?? 0,
      'phone_no': phoneNumber,
      'father_spouse_name': guardian,
      'address': widget.address,
      'state_id': int.tryParse(widget.state ?? "0") ?? 0,
      'AdharNo': aadhaarNumber,
      'Password': widget.password,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final registeredPatientId = responseData['message'];
        if (registeredPatientId != null) {
          await _registerOpd(context, registeredPatientId, widget.unitId!, widget.doctorId!, widget.consultationFee!);
        }
      } else {
        print('Failed to register patient. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred while registering patient: $e');
    }
  }

  Future<void> _registerOpd(BuildContext context, String patientId, String unitId, String doctorId, double consultationFee) async {
    if (widget.selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid date')),
      );
      return;
    }

    final String formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate!);
    // Construct the OPD registration payload
    final opdPayload = {
      "ObjOpd": {
        "patient_id": patientId,
        "registration_date": formattedDate,
      },
      "ObjOpdDetail": {
        "unit_id": unitId,
        "doctor_id": doctorId,
      },
      "ObjBill": {
        "patient_id": patientId, // Use patientId directly
      },
      "ObjBillDetail": {
        "service_unit_price": consultationFee,
        // Use the consultationFee parameter
        "doctor_id": doctorId,
      },
      "ObjPayment": {
        "paid_amount": consultationFee,
        // Use the consultationFee for paid_amount
        "payment_mode": "Cash",
        "transaction_id": "",
        // If you have a transaction ID, include it
      },
    };
    // Print the payload to the terminal to check its structure
    print("OPD Payload: ${jsonEncode(
        opdPayload)}"); // Using jsonEncode for better readability
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.106:8081/api/HospitalApp/OpdRegistration'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(opdPayload),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OPD registration successful')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QRCodeScreen(
              message: "Your Appointment is confirmed with Patient ID: $patientId",
            ),
          ),
        );
      } else {
        print('Failed to register OPD. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error registering OPD: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build UI (unchanged)
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        // Navigate back to the PatientRegistration screen on back press
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PatientRegistrationForm(),
          ),
        );
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientRegistrationForm(),
                ),
              );
            },
          ),
          title: Text('Review Booking', style: TextStyle(color: AppColors.primaryColor, fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
          centerTitle: true,
        ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Display doctor image and details
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: widget.doctorImg != null  ? Image.memory(
                            base64Decode(widget.doctorImg!),
                            height: screenHeight * 0.2,
                            width: screenWidth * 0.4,
                            fit: BoxFit.cover,
                          ) : Icon(Icons.person, size: screenHeight * 0.15),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.doctorName ?? 'Dr. Kavita Mehta', style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold)),
                              Text('General Medicine', style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black,fontFamily:"Poppins")),
                              Text(widget.experience ?? '3+yrs', style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.blue)),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(border: Border.all(color: Colors.black26), borderRadius: BorderRadius.circular(4)),
                                child: Text('₹${widget.consultationFee?.toStringAsFixed(2) ?? '0.00'}', style: TextStyle(fontSize: screenWidth * 0.045)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04), // Dynamic spacing

                    // Appointment Type and Date/Time Info
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'In Person Visit',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: screenWidth *
                                      0.035, // Dynamic font size
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04), // Dynamic spacing
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey,
                                  size: screenWidth * 0.05),
                              SizedBox(width: 4),
                              Text(
                                DateFormat('d MMM yyyy').format(
                                  widget.selectedDate ?? DateTime.now(),
                                ),
                                style: TextStyle(color: Colors.black87,
                                    fontSize: screenWidth * 0.035),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Row(
                          children: [
                            Icon(Icons.access_time, color: Colors.grey,
                                size: screenWidth * 0.05),
                            SizedBox(width: 4),
                            Text(
                              widget.selectedTimeSlot ?? 'Time not selected',
                              style: TextStyle(color: Colors.black87,
                                  fontSize: screenWidth * 0.035),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04), // Dynamic spacing

                    // Patient Info Section
                    // Patient Info Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Patient Info',
                          style: TextStyle(
                            // fontSize: isWideScreen ? 18 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to change patient info
                          },
                          child: Text(
                            'Change',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$firstName $lastName',
                            style: TextStyle(
                              // fontSize: isWideScreen ? 16 : 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          gender ?? 'Male',
                          style: TextStyle(
                            // fontSize: isWideScreen ? 16 : 14,
                          ),
                        ),

                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02), // Dynamic spacing

                    // Charges Information
                    Text(
                      'Total Charges',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045, // Dynamic font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      // Dynamic padding
                      margin: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.secondaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChargesRow(
                            'Consultation Fees',
                            '₹${widget.consultationFee?.toStringAsFixed(2) ?? '0.00'}',
                            screenWidth,
                          ),
                          _buildChargesRow(
                            'Service Charges',
                            '₹${widget.serviceCharge.toStringAsFixed(2)}',
                            screenWidth,
                          ),
                          Divider(),
                          _buildChargesRow(
                            'Pay Now',
                            '₹${totalCharges.toStringAsFixed(2)}',
                            screenWidth,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.04), // Dynamic spacing
                  ],
                ),
              ),
            ),
          ),
          // Payment Buttons
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${totalCharges.toStringAsFixed(2)} ',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045, // Dynamic font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        if (widget.patientId != null) {
                          // Skip patient registration and directly register OPD
                          await _registerOpd(context, widget.patientId!, widget.unitId!, widget.doctorId!, widget.consultationFee!);
                        } else {
                          // Register patient and then OPD
                          await registerPatient(context);
                        }
                      },

                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenHeight * 0.01,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: AppColors.secondaryColor),
                        ),
                      ),
                      child: Text(
                        'Pay Later',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // Dynamic font size
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02), // Dynamic spacing
                    ElevatedButton(
                      onPressed: () async {
                        // Handle payment and confirmation
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                          vertical: screenHeight * 0.01,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        'Pay & Confirm',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04, // Dynamic font size
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
Widget _buildChargesRow(String label, String amount, double screenWidth,
    {bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: screenWidth * 0.04, // Dynamic font size
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontSize: screenWidth * 0.04, // Dynamic font size
          ),
        ),
      ],
    ),
  );
}
}
