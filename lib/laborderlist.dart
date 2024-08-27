import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Laborderlist extends StatefulWidget {
  final String patientId;

  Laborderlist({required this.patientId});

  @override
  _LaborderlistState createState() => _LaborderlistState();
}

class _LaborderlistState extends State<Laborderlist> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchLabOrders();
  }

  // Fetch lab orders
  Future<void> _fetchLabOrders() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.106:8081/api/Pharma/GetBillingByPatientId?PatientId=${widget.patientId}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> fetchedOrders = json.decode(response.body);

        // Group orders by bill_no
        Map<String, List<Map<String, dynamic>>> groupedOrders = {};
        for (var order in fetchedOrders) {
          String billNo = order['bill_no'];
          if (!groupedOrders.containsKey(billNo)) {
            groupedOrders[billNo] = [];
          }
          groupedOrders[billNo]!.add(order);
        }

        // Transform the grouped orders into a list
        setState(() {
          _orders = groupedOrders.entries.map((entry) {
            String billNo = entry.key;
            List<Map<String, dynamic>> orderList = entry.value;

            // For simplicity, you can combine the reference_reg_id and the latest bill_date
            String latestDate = orderList.map((o) => o['bill_date']).reduce((a, b) => DateTime.parse(a).isAfter(DateTime.parse(b)) ? a : b);
            return {
              'bill_no': billNo,
              'reference_reg_id': orderList.map((o) => o['reference_reg_id']).toList(),
              'latest_bill_date': latestDate
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load pharmacy orders');
      }
    } catch (e) {
      print('Error fetching pharmacy orders: $e');
    }
  }

  void _filterOrdersByDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  List<dynamic> get _filteredOrders {
    if (_selectedDate == null) return _orders;
    return _orders.where((order) {
      DateTime orderDate = DateTime.parse(order['latest_bill_date']);
      return orderDate.isAtSameMomentAs(_selectedDate!) || orderDate.isAfter(_selectedDate!);
    }).toList();
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

  // Fetch service details for a bill_no
  Future<List<dynamic>> _fetchServicesByBillNo(String billNo) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.106:8081/api/Pharma/GetServiceByBillNo?BillNo=$billNo'),
      );

      if (response.statusCode == 200) {
        List<dynamic> services = json.decode(response.body);
        return services;
      } else {
        print('Failed to fetch services for bill no: $billNo');
        return [];
      }
    } catch (e) {
      print('Error fetching services for bill no: $e');
      return [];
    }
  }

  // Format the date from API
  String _formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return 'Invalid date'; // Handle potential invalid date
    }
  }

  // Show the bottom sheet when "View Details" is clicked
  void _showOrderDetailsBottomSheet(BuildContext context, String billNo, List<dynamic> referenceRegIds) async {
    List<dynamic> services = await _fetchServicesByBillNo(billNo);

    // Determine the height of the bottom sheet dynamically based on the number of services
    double sheetHeight = services.length <= 3
        ? 150 + services.length * 100.0 // Calculate dynamic height for up to 3 items
        : 300.0; // Limit the height for larger lists (you can adjust this as needed)

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Text('Bill No: $billNo'),
                SizedBox(height: 20),
                Text(
                  'Services:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                services.isEmpty
                    ? Center(
                  child: Text(
                    'No items available.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final item = services[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          title: Text(
                            item['service_name'] ?? 'N/A',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lab Orders',
          style: TextStyle(
              color: AppColors.primaryColor,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_alt, color: AppColors.primaryColor),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          final order = _filteredOrders[index]; // Use filtered orders here
          String formattedDate =
          _formatDate(order['latest_bill_date'] ?? '');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Id and Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order id',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          order['bill_no'] ?? "N/A",
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Date Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // View Details Button
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          _showOrderDetailsBottomSheet(
                            context,
                            order['bill_no'],
                            order['reference_reg_id'],
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),

                          ),
                        ),
                        child: Text('View Details',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.white,
                          ),),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}