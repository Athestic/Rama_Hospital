import 'package:flutter/material.dart';
import 'package:global/PatientRegistrationApp.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert'; // for decoding base64 images
import 'patient_registration.dart';
import 'colors.dart';
import 'doctor_list_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final Doctor doctor;

  DoctorDetailScreen({required this.doctor});

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  List<String> timeSlots = ['11:40 AM', '11:45 AM', '11:50 AM'];
  String? _selectedTimeSlot;
  bool _showQualifications = false;
  bool _showAchievements = false;

  void _showDateTimePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date picker (TableCalendar)
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(Duration(days: 30)),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.tealAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.teal,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Select Time Slot',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 10),
                // Time slots
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: timeSlots.map((timeSlot) {
                    return ChoiceChip(
                      label: Text(timeSlot),
                      selected: _selectedTimeSlot == timeSlot,
                      onSelected: (isSelected) {
                        setState(() {
                          _selectedTimeSlot = isSelected ? timeSlot : null;
                        });
                      },
                      selectedColor: Colors.teal,
                      backgroundColor: Colors.teal.shade50,
                      labelStyle: TextStyle(
                        color: _selectedTimeSlot == timeSlot
                            ? Colors.white
                            : Colors.teal,
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                // Confirm button
                ElevatedButton(
                  onPressed: () {
                    if (_selectedTimeSlot != null) {
                      // Proceed with the registration or other actions
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientRegistrationApp(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a time slot'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:AppColors.secondaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _toggleQualifications() {
    setState(() {
      _showQualifications = !_showQualifications;
      _showAchievements = false; // Collapse achievements if open
    });
  }

  void _toggleAchievements() {
    setState(() {
      _showAchievements = !_showAchievements;
      _showQualifications = false; // Collapse qualifications if open
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dr. ${widget.doctor.doctorName}',
          style: TextStyle(
            color: Colors.teal,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
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
                        color: AppColors.secondaryColor,  // Adjust to match your border color
                        width: 4.0, // Border thickness
                      ),
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: widget.doctor.doctorImg != null
                          ? Image.memory(
                        base64Decode(widget.doctor.doctorImg!),
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.person, size: 100),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Dr. ${widget.doctor.doctorName}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Text(
                  //   '${widget.doctor.specializationId}',
                  //   style: TextStyle(
                  //     color: Colors.blue,
                  //     fontFamily: 'Poppins',
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  SizedBox(height: 8),
                  // Container for Experience & Rating
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor3,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Total Exp - ${widget.doctor.experience} yrs',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(width: 20),
                        Row(
                          children: List.generate(
                            5,
                                (index) => Icon(
                              index < 4 ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleQualifications,
                  child: Text('Qualifications',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                        color: Colors.white,
                    ),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showQualifications
                        ? AppColors.primaryColor
                        : AppColors.primaryColorShades.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _toggleAchievements,
                  child: Text('Achievements',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showAchievements
                        ? AppColors.secondaryColor
                        : AppColors.secondaryColorShades.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Display Qualifications if expanded
            if (_showQualifications)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'MBBS: All India Institute of Medical Sciences (AIIMS), New Delhi, 2005  \n'
                      'MD : Maulana Azad Medical College, New Delhi, 2009'
                  ,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            // Display Achievements if expanded
            if (_showAchievements)
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Best Cardiologist Award by the Indian Medical Association, 2018 \n'
                      'Young Investigator Award at the European Society of Cardiology Congress, 2017',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            SizedBox(height: 20),
            // Availability Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 10),
                VerticalDivider(
                  width: 1,
                  color: Colors.grey, // Divider color
                  thickness: 1,
                ),
                SizedBox(width: 10),
                Row(
                  children: ['Mon', 'Tue', 'Thu'].map((day) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Chip(
                        label: Text(day),
                        backgroundColor: Colors.teal.shade50,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            SizedBox(height: 20),
            // About Doctor
            Text(
              'About Doctor',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10),
    Container(
    padding: const EdgeInsets.all(12.0),
    decoration: BoxDecoration(
    color: AppColors.cardColor3,
    borderRadius: BorderRadius.circular(10),
    ),
    // About Doctor
    child:
            Text(
              'Dr. Rohit Gupta is a highly skilled and compassionate Cardiologist with over 15 years of experience...',
              style: TextStyle(fontSize: 16),
            ),
    ),
            SizedBox(height: 20),
            // Choose Slot Button
            Center(
              child: ElevatedButton(
                onPressed: _showDateTimePickerDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Choose Slot',
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
    );
  }
}
