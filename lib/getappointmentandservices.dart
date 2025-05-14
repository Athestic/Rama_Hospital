import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'app_config.dart';

class BookingAppointmentPage extends StatefulWidget {
  final String patientId;

  BookingAppointmentPage({required this.patientId});

  @override
  _BookingAppointmentPageState createState() =>
      _BookingAppointmentPageState();
}

class _BookingAppointmentPageState extends State<BookingAppointmentPage> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  bool _showUpcomingAppointments = true;
  DateTime? _selectedDate;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final url = Uri.parse(
        '${AppConfig.apiUrl1}${AppConfig.getBillingByPatientIdEndpoint}?PatientId=${widget.patientId}',
      );

      final response = await http.get(url);

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

  Future<void> _refreshAppointments() async {
    setState(() {
      _selectedDate = null;
      _searchController.clear();
      _isLoading = true;
    });
    await _fetchAppointments();
  }

  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    DateTime firstDate = _showUpcomingAppointments ? now : DateTime(2000);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<dynamic> get _filteredOrders {
    DateTime now = DateTime.now();

    return _orders.where((order) {
      DateTime orderDate = DateTime.tryParse(order['bill_date']) ?? now;
      bool isUpcoming = !orderDate.isBefore(DateTime(now.year, now.month, now.day)); // today or future
      bool matchesAppointmentType =
      _showUpcomingAppointments ? isUpcoming : orderDate.isBefore(now);

      bool matchesDate = _selectedDate == null
          ? true
          : _isSameDay(orderDate, _selectedDate!);

      String searchText = _searchController.text.toLowerCase();
      bool matchesSearch = (order['doctorName'] ?? '')
          .toLowerCase()
          .contains(searchText) ||
          (order['dept_name'] ?? '').toLowerCase().contains(searchText);

      return matchesAppointmentType &&
          matchesDate &&
          matchesSearch &&
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
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search for doctor or department',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                          BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.primaryColor, width: 2),
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.filter_list_alt,
                      color: AppColors.primaryColor),
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
                    onPressed: () => setState(() {
                      _showUpcomingAppointments = true;
                    }),
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
                    onPressed: () => setState(() {
                      _showUpcomingAppointments = false;
                    }),
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
                : RefreshIndicator(
              onRefresh: _refreshAppointments,
              child: _filteredOrders.isEmpty
                  ? ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                        child: Text('No Appointments Found')),
                  )
                ],
              )
                  : ListView.builder(
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  var formattedDateTime = _formatDate(
                      order['bill_date']?.toString() ?? '');
                  String formattedDate =
                      formattedDateTime['date'] ?? 'N/A';

                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: 5.0),
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
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dr. ${order['doctorName'] ?? "N/A"}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                Text(
                                  '${order['dept_name'] ?? "N/A"}',
                                  style: TextStyle(
                                      color: Colors.grey),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'OPD No :  ',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                        '${order['reference_reg_id'] ?? "N/A"}',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formattedDate,
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
                              fontSize: 14,
                              color: Colors.black54),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
