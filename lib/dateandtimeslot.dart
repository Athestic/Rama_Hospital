import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'patient_registration.dart';
import 'review.dart';

class SlotSelectionBottomSheet extends StatefulWidget {
  final String? specializationName;

  SlotSelectionBottomSheet({this.specializationName});

  @override
  _SlotSelectionBottomSheetState createState() =>
      _SlotSelectionBottomSheetState();
}

class _SlotSelectionBottomSheetState extends State<SlotSelectionBottomSheet> {
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  String? _patientId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientId();
  }

  Future<void> _fetchPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _patientId = prefs.getString('patientId'); // Fetch patientId from SharedPreferences
      isLoading = false; // Loading complete
    });
  }

  bool get isLoggedIn => _patientId != null && _patientId!.isNotEmpty;

  List<DateTime> _generateDates() {
    return List.generate(
      14,
          (index) => DateTime.now().add(Duration(days: index + 1)),
    );
  }

  final List<String> _morningSlots = [
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
  ];
  final List<String> _eveningSlots = [
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
  ];

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTimeSlot = null;
      SelectedAppointment().selectedDate = date;
      SelectedAppointment().selectedSlot = null;
    });
  }

  void _onTimeSlotSelected(String slot) {
    setState(() {
      _selectedTimeSlot = slot;
      SelectedAppointment().selectedSlot = slot;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.teal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while fetching patientId
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Appointment Date and Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 65,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _generateDates().map((date) {
                  final isSelected = _selectedDate == date;
                  return GestureDetector(
                    onTap: () => _onDateSelected(date),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border:
                        Border.all(color: isSelected ? Colors.teal : Colors.grey),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${date.day}",
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${date.month}-${date.year}",
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 16),
            if (_selectedDate != null) ...[
              Text(
                'Morning Slots (10 AM - 1 PM):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _morningSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return GestureDetector(
                    onTap: () => _onTimeSlotSelected(slot),
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border:
                        Border.all(color: isSelected ? Colors.teal : Colors.grey),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
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
                spacing: 8,
                runSpacing: 8,
                children: _eveningSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot;
                  return GestureDetector(
                    onTap: () => _onTimeSlotSelected(slot),
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal : Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border:
                        Border.all(color: isSelected ? Colors.teal : Colors.grey),
                      ),
                      child: Text(
                        slot,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: 16),
            if (_selectedDate != null && _selectedTimeSlot != null)
              Text(
                "Selected Date: ${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}\n"
                    "Selected Time: $_selectedTimeSlot",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: (_selectedDate != null && _selectedTimeSlot != null)
                  ? () {
                if (isLoggedIn) {
                  // If patient is logged in, navigate to the ReviewScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReviewScreen(
                        patientId: _patientId,
                        specializationName: widget.specializationName,
                      ),
                    ),
                  );
                } else {
                  // If patient is not logged in, navigate to the PatientRegistrationForm
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientRegistrationForm(),
                    ),
                  );
                }
              }
                  : null, // Disable button if no date or time is selected
              style: ElevatedButton.styleFrom(
                backgroundColor: (_selectedDate != null && _selectedTimeSlot != null)
                    ? Colors.teal
                    : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: "Poppins",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedAppointment {
  static final SelectedAppointment _instance = SelectedAppointment._internal();

  DateTime? selectedDate;
  String? selectedSlot;

  factory SelectedAppointment() {
    return _instance;
  }

  SelectedAppointment._internal();
}
