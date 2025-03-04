import 'package:flutter/material.dart';
import 'dart:convert'; // for decoding base64 images
import 'package:http/http.dart' as http;
import 'colors.dart';
import 'package:global/PatientRegistrationApp.dart';
class SlotSelectionBottomSheet extends StatefulWidget {
  final int doctorId;

  SlotSelectionBottomSheet({required this.doctorId});

  @override
  _SlotSelectionBottomSheetState createState() => _SlotSelectionBottomSheetState();
}

class _SlotSelectionBottomSheetState extends State<SlotSelectionBottomSheet> {
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  Map<String, dynamic> _selectedSlot = {};
  List<dynamic> _availableSlots = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSlots(); // Load slots for the default selected date
  }

  List<DateTime> _generateDates() {
    return List.generate(
      7,
          (index) => DateTime.now().add(Duration(days: index + 1)),
    );
  }

  void _fetchSlots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final formattedDate =
          "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}";
      final response = await http.get(Uri.parse(
          'http://192.168.1.188:8085/api/Patient/GetDoctorAvailableSlots?doctorId=${widget.doctorId}&appointmentDate=$formattedDate'));

      if (response.statusCode == 200) {
        setState(() {
          _availableSlots = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to load slots');
      }
    } catch (e) {
      print('Error fetching slots: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedSlot = {}; // Clear selected slot when date changes
    });
    SelectedAppointment().selectedDate = date; // Save date globally
    _fetchSlots();
  }

  void _onSlotSelected(Map<String, dynamic> slot) {
    setState(() {
      _selectedSlot = slot;
    });
    SelectedAppointment().selectedSlot = slot['slotStartTime']; // Save slot globally
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select Appointment Date and Time',
            style: TextStyle(
                fontSize: 18,
                // fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: "Poppins"
            ),
          ),
          SizedBox(height: 20),
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
                      border: Border.all(color: isSelected ? Colors.teal : Colors.grey),
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
          SizedBox(height: 20),
          Text(
            "Available slots",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'Poppins'
            ),
          ),
          SizedBox(height: 20),
          // Slot Display
          if (_isLoading)
            CircularProgressIndicator()
          else if (_availableSlots.isEmpty)
            Text("No slots available for the selected date.")
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableSlots.map((slot) => _buildSlotButton(slot, screenWidth)).toList(),
            ),

          SizedBox(height: 20),

          // Selected Date and Time
          if (_selectedSlot.isNotEmpty)
            Text(
              "Selected Date: ${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}\n"
                  "Selected Time: ${_selectedSlot['slotStartTime']}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),


          SizedBox(height: 20),

          // Confirm Button
          ElevatedButton(
            onPressed: _selectedSlot.isNotEmpty
                ? () {
              // Navigate to the PatientRegistrationForm screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PatientRegistrationForm(),
                ),
              );
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedSlot.isNotEmpty ? AppColors.primaryColor : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: Text(
              "Confirm",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: "Poppins",
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildSlotButton(Map<String, dynamic> slot, double screenWidth) {
    final isSelected = _selectedSlot == slot;
    return GestureDetector(
      onTap: () => _onSlotSelected(slot),
      child: Container(
        width: screenWidth * 0.25,
        padding: EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? Colors.green : Colors.grey),
        ),
        child: Text(
          slot['slotStartTime'],
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
