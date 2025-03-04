import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'patient_registration.dart';
import 'app_config.dart';
import 'dateandtimeslot.dart';
import 'doctor_list_screen.dart';
import 'payment_options_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewScreen extends StatefulWidget {
  final String? patientId;
  final String? specializationName;

  ReviewScreen({
    this.patientId,
    required this.specializationName,
  });

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String? firstName;
  String? lastName;
  String? gender;
  String? guardian;
  String? aadhaarNumber;
  String? phoneNumber;
  String? age;
  String? _specialization;
  final double serviceCharge = 50.0;
  DateTime? selectedDate = SelectedAppointment().selectedDate;
  String? selectedSlot = SelectedAppointment().selectedSlot;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchspecialization();
    if (widget.patientId != null) {
      fetchPatientDetails();
      print("Selected Slot: $widget.specializationName");
    }
  }
  Future<void> _fetchspecialization()async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _specialization = prefs.getString('specializationName'); // Fetch patientId from SharedPreferences
      isLoading = false; // Loading complete
    });
  }

  Future<void> fetchPatientDetails() async {
    final String apiUrl =
        'http://192.168.1.109:8081/api/HospitalApp/GetPatientById?PatientId=${widget
        .patientId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          firstName = responseData['first_name'];
          lastName = responseData['last_name'];
          gender = responseData['gender'];
          guardian = responseData['father_spouse_name'];
          aadhaarNumber = responseData['adharNo'];
          phoneNumber = responseData['phone_no'];
          age = responseData['age']?.toString();
        });
      } else {
        debugPrint('Failed to fetch patient details. Status Code: ${response
            .statusCode}');
      }
    } catch (e) {
      debugPrint("Error fetching patient details: $e");
    }
  }

  double get totalCharges {
    final consultationFee = GlobalDoctorData().consultationFee ?? 0.0;
    return consultationFee + serviceCharge;
  }

  Future<void> _registerOpd(BuildContext context) async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid date')),
      );
      return;
    }

    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    final globalData = GlobalDoctorData();
    final opdPayload = {
      "ObjOpd": {
        "patient_id": widget.patientId,
        "registration_date": formattedDate
      },
      "ObjOpdDetail": {
        "unit_id": globalData.unitId,
        "doctor_id": globalData.doctorId,
      },
      "ObjBill": {
        "patient_id": widget.patientId,
      },
      "ObjBillDetail": {
        "service_unit_price": globalData.consultationFee,
        "doctor_id": globalData.doctorId,
      },
      "ObjPayment": {
        "paid_amount": globalData.consultationFee,
      }
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl1}${AppConfig.opdRegistrationEndpoint}'),
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
            builder: (context) =>
                QRCodeScreen(
                  message: "Your Appointment is confirmed with Patient ID: ${widget
                      .patientId}",
                ),
          ),
        );
      } else {
        debugPrint(
            'Failed to register OPD. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error registering OPD: $e');
    }
  }

  Widget _buildDoctorImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return Icon(Icons.person, size: MediaQuery
          .of(context)
          .size
          .height * 0.15);
    }
    try {
      return Image.memory(
        base64Decode(base64String),
        height: MediaQuery
            .of(context)
            .size
            .height * 0.2,
        width: MediaQuery
            .of(context)
            .size
            .width * 0.4,
        fit: BoxFit.cover,
      );
    } catch (e) {
      debugPrint('Invalid image data: $e');
      return Icon(Icons.person, size: MediaQuery
          .of(context)
          .size
          .height * 0.15);
    }
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
              fontSize: screenWidth * 0.04,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: screenWidth * 0.04,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(selectedDate);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;



    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
    Navigator.pop(context); // Navigates back to the previous screen
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
                    // Doctor and Patient Info
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: _buildDoctorImage(GlobalDoctorData().doctorImg),
                        ),
                        SizedBox(width: screenWidth * 0.04),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                GlobalDoctorData().doctorName ?? 'Dr. Unknown',
                                style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                _specialization ?? 'Specialization not available',
                                style: TextStyle(fontSize: screenWidth * 0.04),
                              ),
                              SizedBox(height: screenHeight * 0.005),
                              Text(
                                'Experience: ${GlobalDoctorData().experience ?? 'N/A'} years',
                                style: TextStyle(fontSize: screenWidth * 0.04),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black26),
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text('₹${GlobalDoctorData().consultationFee?.toStringAsFixed(2) ?? '0.00'}',
                                    style: TextStyle(fontSize: screenWidth * 0.045)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.04),

                    // Patient Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Patient Info', style: TextStyle(fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            // Navigate to change patient info
                          },
                          child: Text('Change', style: TextStyle(color: Colors.blue)),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('$firstName $lastName', overflow: TextOverflow.ellipsis)),
                        SizedBox(width: 10),
                        Text(gender ?? 'Male'),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // Charges Information
                    Text(
                      'Total Charges',
                      style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      margin: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.secondaryColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChargesRow(
                            'Consultation Fees',
                            '₹${GlobalDoctorData().consultationFee?.toStringAsFixed(2) ?? '0.00'}',
                            screenWidth,
                          ),
                          _buildChargesRow(
                            'Service Charges',
                            '₹${serviceCharge.toStringAsFixed(2)}',
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
                    SizedBox(height: screenHeight * 0.04),
                  ],
                ),
              ),
            ),
          ),
          // Payment Buttons
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${totalCharges.toStringAsFixed(2)} ',
                  style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    // Pay Now Button
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentOptionsScreen(amount: totalCharges),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.01,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: Text(
                        'Pay Now',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.03),

                    // Pay Later Button
                    TextButton(
                      onPressed: () {
                        _registerOpd(context); // Call OPD registration for Pay Later
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
                        'Pay Later',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}
