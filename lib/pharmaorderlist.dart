import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PharmacyOrderList extends StatefulWidget {
  final String patientId;

  PharmacyOrderList({required this.patientId});

  @override
  _PharmacyOrderListState createState() => _PharmacyOrderListState();
}

class _PharmacyOrderListState extends State<PharmacyOrderList> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchPharmacyOrders();
  }

  Future<void> _fetchPharmacyOrders() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.106:8081/api/Pharma/GetRequisitionByPatientId?PatientId=${widget.patientId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _orders = json.decode(response.body);
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
      DateTime orderDate = DateTime.parse(order['requisition_date']);
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

  Future<void> _fetchOrderDetails(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.106:8081/api/Pharma/GetRequisitionDetailsById?MedicineReqId=$orderId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> details = json.decode(response.body);
        _showOrderDetailsDialog(details);
      } else {
        print('Failed to load order details');
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }

  void _showOrderDetailsDialog(List<dynamic> details) {
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
                SizedBox(height: 16.0),
                details.isEmpty
                    ? Center(
                  child: Text(
                    'No items available.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
                    : Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: details.length,
                    itemBuilder: (context, index) {
                      final item = details[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ListTile(
                          title: Text(
                            item['item_name'] ?? 'N/A',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Quantity: ${item['qty'] ?? 'N/A'}'),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getStatusWidget(String? status) {
    Color statusColor;
    String statusText;

    if (status == 'P') {
      statusColor = AppColors.cardColor4;
      statusText = 'Pending';
    } else if (status == 'CL') {
      statusColor = Colors.blue[300]!;
      statusText = 'Close';
    } else {
      statusColor = Colors.grey;
      statusText = 'Unknown';
    }

    return Container(
      width: 100,
      padding: EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: statusColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(40),
        ),
      ),
      child: Center(
        child: Text(
          statusText,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pharmacy Orders',
          style: TextStyle(
            color: Colors.teal,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
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
          final order = _filteredOrders[index];
          String formattedDate = _formatDate(order['requisition_date']?.toString() ?? '');

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
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
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Id',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${order['medicine_requisition_id']?.toString() ?? "N/A"}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
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
                    SizedBox(height: 12.0),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _fetchOrderDetails(order['medicine_requisition_id']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                right: 0,
                child: Center(
                  child: _getStatusWidget(order['status']?.toString()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }
}

