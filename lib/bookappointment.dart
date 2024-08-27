import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BookingAppointmentPage extends StatefulWidget {
  final String patientId;

  BookingAppointmentPage({required this.patientId});

  @override
  _BookingAppointmentPageState createState() => _BookingAppointmentPageState();
}

class _BookingAppointmentPageState extends State<BookingAppointmentPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  DateTime? _selectedDate;
  bool _showUpcomingAppointments = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.106:8081/api/Pharma/GetBillingByPatientId?PatientId=${widget.patientId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _orders = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        print('Failed to load Appointments');
      }
    } catch (e) {
      print('Error fetching Appointments: $e');
    }
  }

  void _filterOrdersByDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      _filterOrdersByDate(pickedDate);
    }
  }

  List<dynamic> get _filteredOrders {
    return _orders.where((order) {
      DateTime orderDate = DateTime.parse(order['bill_date']);
      bool isUpcoming = orderDate.isAfter(DateTime.now());
      return (_showUpcomingAppointments ? isUpcoming : !isUpcoming) &&
          order['itemFlag'] == 'CON';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Appointments',
          style: TextStyle(
              color: Colors.teal,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Bar and Filter Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40, // Adjust the height as needed
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search for appointment',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: EdgeInsets.symmetric(vertical: 10), // Adjust padding
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.filter_list_alt, color: AppColors.primaryColor),
                  onPressed: _pickDate,
                ),
              ],
            ),
          ),

          // Appointment Type Tabs
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _showUpcomingAppointments = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _showUpcomingAppointments
                          ? Colors.teal
                          : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Upcoming Appoint',
                      style: TextStyle(
                          fontSize: 13,
                          color: _showUpcomingAppointments
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        setState(() => _showUpcomingAppointments = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_showUpcomingAppointments
                          ? Colors.teal
                          : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'Past Appoint',
                      style: TextStyle(
                          fontSize: 13,
                          color: !_showUpcomingAppointments
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Appointment List
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                final order = _filteredOrders[index];
                var formattedDateTime =
                _formatDate(order['bill_date']?.toString() ?? '');
                String formattedDate =
                    formattedDateTime['date'] ?? 'N/A';
                String formattedTime =
                    formattedDateTime['time'] ?? 'N/A';

                return Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04, vertical: 5.0),
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. ${order['doctorName'] ?? "N/A"}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              Text(
                                '${order['dept_name'] ?? "N/A"}',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Text(
                                '${order['reference_reg_id'] ?? "N/A"}',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formattedDate,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              SizedBox(width: 8),
                              Text(
                                formattedTime,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${order['consultationType'] ?? "Hospital Visit"}',
                        style: TextStyle(
                            fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            child: Text('Cancel',
                                style: TextStyle(color: Colors.teal)),
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.teal)),
                          ),
                          SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () {},
                            child: Text('Confirm',
                                style: TextStyle(color: Colors.blue)),
                            style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.blue)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _formatDate(String dateStr) {
    try {
      DateTime dateTime = DateTime.parse(dateStr);
      String formattedDate = DateFormat('dd/MMM/yy').format(dateTime);
      String formattedTime = DateFormat('hh:mm a').format(dateTime);
      return {'date': formattedDate, 'time': formattedTime};
    } catch (e) {
      return {'date': 'N/A', 'time': 'N/A'};
    }
  }
}
