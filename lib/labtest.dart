import 'package:flutter/material.dart';
import 'package:global/colors.dart'; // Ensure this path is correct for your app
import 'package:global/laborderlist.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_config.dart';
import 'package:global/Homepage.dart';

class LabTestBooking extends StatefulWidget {

  @override
  _LabTestBookingState createState() => _LabTestBookingState();
}

class _LabTestBookingState extends State<LabTestBooking> {
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> filteredServices = [];
  List<Map<String, dynamic>> selectedServices = [];
  DateTime selectedDate = DateTime.now();

  List<Map<String, dynamic>> doctors = [];
  Map<String, dynamic>? selectedDoctor;

  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String? patientId;
  int? selectedDoctorId;


  @override
  void initState() {
    super.initState();
    fetchDoctors();
    _getPatientId(); // Fetch patientId on initialization
  }
  Future<void> _getPatientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    patientId = prefs.getString('patientId'); // Get the saved patientId
  }

  Future<void> fetchServices(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl1}${AppConfig.getServiceInvestigationEndpoint}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body)['value'];

        setState(() {
          services = data.map((item) {
            // Extracting serviceName after the first hyphen
            String fullName = item['serviceName'];
            String serviceName = '';

            // Split by hyphen and take the part after the first hyphen
            List<String> parts = fullName.split('-');
            if (parts.length > 1) {
              serviceName = parts[1].trim(); // Get the name after the first hyphen and trim whitespace
            }

            return {
              'serviceName': serviceName,
              'serviceCategoryMapId': item['serviceCategoryMapId'],
              'serviceUnitPrice': item['serviceUnitPrice'],
            };
          }).toList();

          // Filtering services based on the query
          filteredServices = services.where((service) {
            return service['serviceName']
                .toLowerCase()
                .contains(query.toLowerCase());
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching services: $e');
    }
  }

  Future<void> fetchDoctors() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiUrl1}${AppConfig.getDoctorDataEndpoint}'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        Set<int> doctorIds = {};

        setState(() {
          doctors = data.where((doctor) {
            if (!doctorIds.contains(doctor['doctor_id'])) {
              doctorIds.add(doctor['doctor_id']);
              return true;
            }
            return false;
          }).map((doctor) {
            return {
              'doctor_id': doctor['doctor_id'],
              'doctor_name': doctor['doctor_name'],
              'doctor_category': doctor['doctor_category'],
            };
          }).toList();
        });
      }
    } catch (e) {
      print('Error fetching doctors: $e');
    }
  }

  void filterServices(String query) {
    setState(() {
      filteredServices = services.where((service) {
        return service['serviceName']
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }


  void addService(Map<String, dynamic> service) {
    setState(() {
      bool exists = selectedServices.any(
            (selectedService) => selectedService['serviceName'] == service['serviceName'],
      );

      if (!exists) {
        selectedServices.add({
          'serviceName': service['serviceName'],
          'serviceCategoryMapId': service['serviceCategoryMapId'],
          'serviceUnitPrice': service['serviceUnitPrice'],
        });
      }

      searchController.clear();
      filteredServices = [];

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  double calculateTotalPrice() {
    return selectedServices.fold(0.0, (total, service) {
      return total + service['serviceUnitPrice'];
    });
  }

  void removeService(String serviceName) {
    setState(() {
      selectedServices.removeWhere((service) => service['serviceName'] == serviceName);
    });
  }

// ✅ Generate POST payload with doctor_id
  Map<String, dynamic> generatePayload() {
    return {
      "ObjOpd": {
        "patient_id": patientId,
        "registration_date": selectedDate.toString().split(' ')[0], // 🛠️ Updated to use selectedDate
      },
      "ObjOpdDetail": {
        "doctor_id": selectedDoctorId,
      },
      "ObjBill": {
        "patient_id": patientId,
      },
      "ObjBillDetail": selectedServices.map((service) {
        return {
          "service_category_map_id": service['serviceCategoryMapId'],
        };
      }).toList(),
      "ObjPayment": {
        "paid_amount": calculateTotalPrice().toInt(),
      },
      "ObjReport": [{}],
    };
  }

  Future<void> postSelectedServices() async {
    if (selectedDoctorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a doctor before submitting.')),
      );
      return;
    }

    final url = '${AppConfig.apiUrl1}${AppConfig.addInvestigationEndpoint}';
    Map<String, dynamic> payload = generatePayload();

    print('Payload to be sent:');
    print(jsonEncode(payload));

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        print('Data posted successfully');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('You have successfully booked a Lab Test.'),
              actions: [
                TextButton(
                  onPressed: () {

                    setState(() {
                      selectedServices.clear();

                    });
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                          (route) => false, // Remove all previous routes
                    );

                  },
                  child: Text('OK'),
                ),
                TextButton(
                  onPressed: () {

                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Laborderlist(patientId: patientId ?? 'default_patient_id'),
                      ),
                    );
                    setState(() {
                      selectedServices.clear();
                      doctors.clear();

                    });
                  },
                  child: Text('Check Your Order? Click Here'),
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to post data');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed'),
              content: Text('Sorry, failed to book the lab test.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Failed'),
            content: Text('Sorry, an error occurred while booking the test.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.cardColor3,
      appBar: AppBar(
        title: Text(
          'Book Your Lab Test',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Styled Dropdown for Doctors
              Text(
                'Reffered Doctor',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black),
                ),
                child: DropdownButton<int>(
                  value: selectedDoctorId,
                  hint: Text('Select Doctor'),
                  isExpanded: true,
                  items: doctors.map<DropdownMenuItem<int>>((doctor) {
                    return DropdownMenuItem<int>(
                      value: doctor['doctor_id'],
                      child: Text(doctor['doctor_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDoctorId = value;
                    });
                  },
                ),

              ),
              SizedBox(height: 16),

              // Service Search Bar
              Text(
                'Search Services',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              // Service Search Bar
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Enter service name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black), // Set the border color
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 1.0), // Color when the field is enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 1.0), // Color when focused
                  ),
                ),
                onChanged: (value) {
                  filterServices(value);
                  fetchServices(value); // Call API when user types
                },
              ),

              SizedBox(height: 8),
              filteredServices.isNotEmpty
                  ? SizedBox(
                height: 300, // Set a fixed height for the dropdown list
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(), // Prevents scrolling the whole screen
                        itemCount: filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = filteredServices[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                service['serviceName'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Cost: ₹${service['serviceUnitPrice']}',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                              onTap: () {
                                addService(service);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
                  : Text(
                'No Services Found',
                style: TextStyle(color: Colors.grey),
              ),


              SizedBox(height: 16),

              // Selected Services Container with Wrap
              selectedServices.isNotEmpty
                  ? SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
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
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(), // You can allow only future dates
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                              SizedBox(width: 6),
                              Text(
                                'Date: ${selectedDate.toString().split(' ')[0]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600, // Optional: make it look clickable
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 8),
                      Text(
                        'Selected Services:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0, // Space between items
                        runSpacing: 4.0, // Space between rows
                        children: selectedServices.map((service) {
                          return Container(
                            width: MediaQuery.of(context).size.width * 0.85, // Adjust width based on screen size
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: service['serviceName'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' - ₹${service['serviceUnitPrice']}',
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.remove_circle),
                                  onPressed: () {
                                    removeService(service['serviceName']);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Total Price: ₹${calculateTotalPrice()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  : SizedBox.shrink(),


              // Book Lab Test Button
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: selectedServices.isNotEmpty
                      ? postSelectedServices// Only enable if there are selected medicines
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Book Lab Test',
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
      ),
    );
  }
}
