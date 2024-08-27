import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'package:global/patient_registration.dart';
import 'dart:convert'; // for decoding base64 images
import 'doctor_list_screen.dart';

class DoctorDetailScreeninpersonvisit extends StatefulWidget {
  final Doctor doctor;


  DoctorDetailScreeninpersonvisit({required this.doctor});

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreeninpersonvisit> {

  bool _showQualifications = false;
  bool _showAchievements = false;

  List<Map<String, String>> locations = [
    {'title': 'Noida', 'image': 'assets/homeCon/hospital.png'},
    {'title': 'Hapur', 'image': 'assets/homeCon/hospital.png'},
    {'title': 'Lakhanpur', 'image': 'assets/homeCon/hospital.png'},
    {'title': 'Mandhana', 'image': 'assets/homeCon/hospital.png'},
    {'title': 'Kanpur', 'image': 'assets/homeCon/hospital.png'},
  ];



  void _toggleAchievements() {
    setState(() {
      _showAchievements = !_showAchievements;
      _showQualifications = true; // Collapse qualifications if open
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width and height
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dr. ${widget.doctor.doctorName}',
          style: TextStyle(
            color: Colors.teal,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05, // Adjust font size
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Image and Details
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.secondaryColor,
                        width: screenWidth * 0.01, // Dynamic border width
                      ),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      child: widget.doctor.doctorImg != null
                          ? Image.memory(
                        base64Decode(widget.doctor.doctorImg!),
                        height: screenHeight * 0.2,
                        width: screenWidth * 0.4,
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.person, size: screenWidth * 0.25),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // Dynamic spacing
                  Text(
                    'Dr. ${widget.doctor.doctorName}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06, // Dynamic font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor3,
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Exp - ${widget.doctor.experience} yrs',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04, // Dynamic font size
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.05), // Dynamic spacing
                        Row(
                          children: List.generate(
                            5,
                                (index) =>
                                Icon(
                                  index < 4 ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: screenWidth * 0.05, // Dynamic icon size
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // Dynamic spacing

            // Special Cases Button
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleAchievements,
                  child: Text(
                    'Special Cases',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: screenWidth * 0.04, // Dynamic font size
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showAchievements
                        ? AppColors.primaryColor
                        : AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.02,
                      vertical: screenHeight * 0.01,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02),

            // Achievements
            if (_showAchievements)
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                child: Text(
                  'Best Cardiologist Award by the Indian Medical Association, 2018 \n'
                      'Young Investigator Award at the European Society of Cardiology Congress, 2017',
                  style: TextStyle(
                      fontSize: screenWidth * 0.04), // Dynamic font size
                ),
              ),

            SizedBox(height: screenHeight * 0.02),

            // Availability Section
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: AppColors.cardColor3,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Availability',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045, // Dynamic font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  VerticalDivider(
                    width: screenWidth * 0.005,
                    color: Colors.grey,
                    thickness: screenWidth * 0.003,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Row(
                    children: ['Mon', 'Tue', 'Thu'].map((day) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.01),
                        child: Chip(
                          label: Text(day),
                          backgroundColor: Colors.teal.shade50,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.01,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // About Doctor Section
            Container(
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: AppColors.cardColor3,
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Doctor',
                    style: TextStyle(
                      fontSize: screenWidth * 0.045, // Dynamic font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.01,
                      horizontal: screenWidth * 0.04,
                    ),
                    width: double.infinity,
                    child: Text(
                      'Our doctor is a highly skilled and compassionate Cardiologist with over 15 years of experience...',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),

            // Book Appointment Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PatientRegistrationForm()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.02,
                    vertical: screenHeight * 0.01,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                ),
                child: Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04, // Dynamic font size
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