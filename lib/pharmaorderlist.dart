import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'app_config.dart';
import 'dart:typed_data';

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
        Uri.parse('${AppConfig.apiUrl1}${AppConfig.getRequisitionByPatientIdEndpoint}?PatientId=${widget.patientId}'),
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
        Uri.parse('${AppConfig.apiUrl1}${AppConfig.getRequisitionDetailsByIdEndpoint}?MedicineReqId=$orderId'),
      );


      if (response.statusCode == 200) {
        // Decode the response JSON
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          // Extract the prescription and details
          final prescription = data.first['precription'] as String?;
          final details = data.first['details'] as List<dynamic>?;

          // Display the details in the bottom sheet
          _showOrderDetailsDialog(details ?? [], prescription: prescription);
        } else {
          print('No data available for this order');
        }
      } else {
        print('Failed to load order details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
    }
  }
  void _showOrderDetailsDialog(List<dynamic> details, {String? prescription}) {
    // Decode the prescription image if available
    Uint8List? prescriptionImage;
    if (prescription != null) {
      try {
        prescriptionImage = base64Decode(prescription);
      } catch (e) {
        print('Error decoding prescription image: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: screenHeight * 0.5,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Order Details',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05, // Responsive font size
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                if (details.isEmpty)
                  Center(
                    child: Text(
                      'No items available.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: screenWidth * 0.04, // Responsive font size
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: details.length,
                      itemBuilder: (context, index) {
                        final item = details[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['item_name'] ?? 'N/A',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.045, // Responsive font size
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  'Quantity: ${item['qty'] ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04, // Responsive font size
                                  ),
                                ),
                                if (prescriptionImage != null)
                                  Padding(
                                    padding: EdgeInsets.only(top: screenHeight * 0.02),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.memory(
                                        prescriptionImage,
                                        fit: BoxFit.cover,
                                        height: screenHeight * 0.2, // Responsive height
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                              ],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pharmacy Orders',
          style: TextStyle(
            color: Colors.teal,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05, // Responsive font size
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
                margin: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
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
                    SizedBox(height: screenHeight * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order Id',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                        Text(
                          '${order['medicine_requisition_id']?.toString() ?? "N/A"}',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
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
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.02,
                            vertical: screenHeight * 0.010,
                          ),
                        ),
                        child: Text(
                          'View Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: screenHeight * 0.005,
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
