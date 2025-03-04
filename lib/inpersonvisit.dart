import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:global/colors.dart';
import 'doctor_list_screen.dart';
import 'dateandtimeslot.dart';

class DoctorDetailScreeninpersonvisit extends StatefulWidget {
  final Doctor doctor;

  DoctorDetailScreeninpersonvisit({required this.doctor}) {
  }

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreeninpersonvisit> {
  Map<String, dynamic>? availability;

  @override
  void initState() {
    super.initState();
    loadAvailability();
  }

  void loadAvailability() async {
    try {
      final data = await fetchDoctorAvailability(widget.doctor.doctorId);
      setState(() {
        availability = data;
      });
    } catch (e) {
      print('Error fetching availability: $e');
    }
  }

  Future<Map<String, dynamic>> fetchDoctorAvailability(int doctorId) async {
    final response = await http.get(
      Uri.parse('http://192.168.1.188:8083/api/Patient/GetDoctorAvailability'),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse is List && jsonResponse.isNotEmpty) {
        return jsonResponse[0];
      } else {
        throw Exception('Doctor availability data is empty');
      }
    } else {
      throw Exception('Failed to load doctor availability');
    }
  }

  void _showSlotSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SlotSelectionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Doctor's Information",
          style: TextStyle(
            color: Colors.teal,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.secondaryColor,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: widget.doctor.doctorImg != null &&
                          widget.doctor.doctorImg!.isNotEmpty
                          ? Image.memory(
                        base64Decode(widget.doctor.doctorImg!),
                        height: 150.0,
                        width: 150.0,
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.person, size: 80.0),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Dr. ${widget.doctor.doctorName}',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Container(
                    padding: EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor3,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Exp - ${widget.doctor.experience} yrs',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        Container(
                          height: 20.0,
                          width: 1.5,
                          color: Colors.grey,
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        Row(
                          children: List.generate(
                            5,
                                (index) => Icon(
                              index < 4 ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 16.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Colors.teal,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    'Consultation Fee - ₹${widget.doctor.consultationFee}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.cardColor3,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Special Cases',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 4.0,
                      horizontal: 16.0,
                    ),
                    width: double.infinity,
                    child: Text(
                      'Best Cardiologist Award by the Indian Medical Association, 2018\n'
                          'Young Investigator Award at the European Society of Cardiology Congress, 2017',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.cardColor3,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'About Doctor',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    width: double.infinity,
                    child: Text(
                      'Our doctor is a highly skilled and compassionate Cardiologist with over 15 years of experience...',
                      style: TextStyle(
                        fontSize: 16.0,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showSlotSelectionBottomSheet(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
