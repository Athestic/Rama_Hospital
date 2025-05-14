import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
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
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final dialogWidth = screenWidth * 0.9;
        final padding = screenWidth * 0.04;
        final fontSize = screenWidth * 0.035;
        final buttonPadding = screenHeight * 0.015;

        DateTime selectedDay = _selectedDay;
        DateTime focusedDay = _focusedDay;
        String? selectedSlot = _selectedTimeSlot;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Container(
                width: dialogWidth,
                padding: EdgeInsets.all(padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TableCalendar(
                      focusedDay: focusedDay,
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(Duration(days: 30)),
                      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                      onDaySelected: (newSelectedDay, newFocusedDay) {
                        setStateDialog(() {
                          selectedDay = newSelectedDay;
                          focusedDay = newFocusedDay;
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
                        markersAlignment: Alignment.bottomCenter,
                        cellMargin: EdgeInsets.all(screenWidth * 0.01),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    Text(
                      'Select Time Slot',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Wrap(
                      spacing: screenWidth * 0.02,
                      runSpacing: screenHeight * 0.01,
                      children: timeSlots.map((timeSlot) {
                        return ChoiceChip(
                          label: Text(
                            timeSlot,
                            style: TextStyle(fontSize: fontSize),
                          ),
                          selected: selectedSlot == timeSlot,
                          onSelected: (isSelected) {
                            setStateDialog(() {
                              selectedSlot = isSelected ? timeSlot : null;
                            });
                          },
                          selectedColor: Colors.teal,
                          backgroundColor: Colors.teal.shade50,
                          labelStyle: TextStyle(
                            color: selectedSlot == timeSlot
                                ? Colors.white
                                : Colors.teal,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Coming Soon"),
                              content: Text("This feature will be available soon!"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text("OK"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05,
                          vertical: buttonPadding,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )

                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  void _toggleQualifications() {
    setState(() {
      _showQualifications = !_showQualifications;
      _showAchievements = false;
    });
  }

  void _toggleAchievements() {
    setState(() {
      _showAchievements = !_showAchievements;
      _showQualifications = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.05;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Dr. ${widget.doctor.doctorName}',
          style: TextStyle(
            color: Colors.teal,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 16.0),
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
                        width: 4.0,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: widget.doctor.doctorImg != null
                          ? Image.memory(
                        base64Decode(widget.doctor.doctorImg!),
                        height: screenWidth * 0.4,
                        width: screenWidth * 0.4,
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.person, size: screenWidth * 0.25),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Dr. ${widget.doctor.doctorName}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.all(12.0),
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
                            fontSize: screenWidth * 0.045,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 20),
                        Row(
                          children: List.generate(
                            5,
                                (index) => Icon(
                              index < 4 ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: screenWidth * 0.05,
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
                  child: Text(
                    'Qualifications',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
                  child: Text(
                    'Achievements',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
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
            if (_showQualifications)
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'MBBS: All India Institute of Medical Sciences (AIIMS), New Delhi, 2005\n'
                      'MD: Maulana Azad Medical College, New Delhi, 2009',
                  style: TextStyle(fontSize: screenWidth * 0.04),
                ),
              ),
            if (_showAchievements)
              Container(
                padding: EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Awarded the prestigious Padma Shri for exceptional service in medicine.\n'
                      'Published over 50 research papers in international journals.',
                  style: TextStyle(fontSize: screenWidth * 0.04),
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
            // Choose Slot Button
            Center(
              child: ElevatedButton(
                onPressed: _showDateTimePickerDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.1,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Choose Slot',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
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

