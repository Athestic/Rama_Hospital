import 'package:flutter/material.dart';
import 'package:global/colors.dart'; // Ensure this path is correct for your app
import 'package:global/pharmaorderlist.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MedicinePage extends StatefulWidget {
  @override
  _MedicinePageState createState() => _MedicinePageState();
}

class _MedicinePageState extends State<MedicinePage> {
  List<Map<String, String>> medicines = [];
  List<Map<String, dynamic>> selectedMedicines = [];
  List<Map<String, dynamic>> filteredMedicines = [];
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  ScrollController scrollController = ScrollController();
  String? patientId; // Variable to hold patientId

  @override
  void initState() {
    super.initState();
    fetchMedicines();
    _getPatientId(); // Fetch patientId on initialization
  }

  Future<void> _getPatientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    patientId = prefs.getString('patientId'); // Get the saved patientId
  }

  Future<void> fetchMedicines() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.106:8081/api/Pharma/GetPharmaItems'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          medicines = data.map((item) {
            String fullName = item['item_name'];

            // Extract the medicine name (text before ' - ')
            String medicineName = fullName.split(' - ')[0];

            // Extract the cost (text after '$' and before '^')
            String cost = '';
            if (fullName.contains('\$') && fullName.contains('^')) {
              cost = fullName.split('\$')[1].split('^')[0].trim();
            }

            // Get the itemCode and itemGroupName
            String itemCode = item['itemCode'];
            String itemGroupName = item['itemGroupName'];

            return {
              'name': medicineName,
              'cost': cost,
              'itemCode': itemCode,
              'itemGroupName': itemGroupName, // Include itemGroupName
            };
          }).toList();

          // Initially keep filteredMedicines empty
          filteredMedicines = [];
        });
      }
    } catch (e) {
      print('Error fetching medicines: $e');
    }
  }

  void filterMedicines(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMedicines = [];
      } else {
        filteredMedicines = medicines
            .where((medicine) =>
            medicine['name']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void addMedicine(String name, String cost, String itemCode,
      String itemGroupName) {
    setState(() {
      bool exists = selectedMedicines.any((medicine) =>
      medicine['name'] == name);

      if (!exists) {
        selectedMedicines.add({
          'name': name,
          'cost': cost,
          'itemCode': itemCode,
          // Store itemCode in selected medicines
          'itemGroupName': itemGroupName,
          // Store itemGroupName in selected medicines
          'quantity': 1,
        });
      }

      searchController.clear();
      filteredMedicines = []; // Clear the filtered list

      FocusScope.of(context).unfocus();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    });
  }

  void updateQuantity(String name, int newQuantity) {
    setState(() {
      selectedMedicines = selectedMedicines.map((medicine) {
        if (medicine['name'] == name) {
          medicine['quantity'] = newQuantity;
        }
        return medicine;
      }).toList();
    });
  }

  void deleteAllMedicines() {
    setState(() {
      selectedMedicines.clear();
    });
  }

  void deleteMedicine(String name) {
    setState(() {
      selectedMedicines.removeWhere((medicine) => medicine['name'] == name);
    });
  }


  double calculateTotalPrice() {
    double total = 0.0;
    for (var medicine in selectedMedicines) {
      double cost = double.tryParse(medicine['cost']) ?? 0.0;
      int quantity = medicine['quantity'];
      total += cost * quantity;
    }
    return total;
  }

  // Function to generate payload for POST request
  Map<String, dynamic> generatePayload() {
    return {
      'patientId': patientId, // Include patientId in the payload
      'requisitionDetails': selectedMedicines.map((medicine) {
        return {
          'ItemGroupName': medicine['itemGroupName'],
          'ItemCode': medicine['itemCode'],
          'ItemName': medicine['name'],
          'Qty': medicine['quantity'],
          'ServiceUnitPrice': double.tryParse(medicine['cost']) ?? 0.0,
        };
      }).toList(),
    };
  }

// Function to make POST request
  Future<void> postSelectedMedicines() async {
    final url = 'http://192.168.1.106:8081/api/Pharma/AddPharmaItems';
    Map<String, dynamic> payload = generatePayload();

    // Print the payload to the console
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
        // Show success dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text(
                  'You have successfully purchased the selected medicines.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PharmacyOrderList(patientId: patientId ?? 'default_patient_id'),
                      ),
                    );(() {
                      selectedMedicines
                          .clear(); // Clear the selected medicines list after successful purchase
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
        // Show failure dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed'),
              content: Text('Sorry, failed to purchase medicines.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
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
      // Show error dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
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
      backgroundColor: AppColors.cardColor3,
      appBar: AppBar(
        title: Text(
          'Book Your Medicine',
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
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Medicine',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
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
                      onChanged: filterMedicines,
                    ),
                    filteredMedicines.isNotEmpty
                        ? SizedBox(
                      height: 300, // Set a fixed height for the dropdown list
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(), // Prevents scrolling the whole screen
                              itemCount: filteredMedicines.length,
                              itemBuilder: (context, index) {
                                final medicine = filteredMedicines[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade300, width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    title: Text(
                                      medicine['name']!,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Cost: ₹${medicine['cost']}',
                                      style: TextStyle(color: Colors.grey.shade700),
                                    ),
                                    onTap: () {
                                      addMedicine(
                                        medicine['name']!,
                                        medicine['cost']!,
                                        medicine['itemCode']!,
                                        medicine['itemGroupName']!,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ):
                        // : Text('No medicines found', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 10),
                  selectedMedicines.isNotEmpty
                      ? Container(
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
                          child: Text(
                            'Date: ${DateTime.now().toString().split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                    Column(
                      children: selectedMedicines.map((medicine) {
                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Medicine Name
                                  Text(
                                    '${medicine['name']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  // Delete button
                                  IconButton(
                                    icon: Icon(Icons.remove_circle),
                                    onPressed: () {
                                      deleteMedicine(medicine['name']);
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              // Price and Quantity in a row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text('Price/tab', style: TextStyle(fontSize: 14)),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '₹${medicine['cost']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Text('Quantity', style: TextStyle(fontSize: 14)),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove_circle, color: Colors.red),
                                            onPressed: () {
                                              if (medicine['quantity'] > 1) {
                                                updateQuantity(medicine['name'], medicine['quantity'] - 1);
                                              }
                                            },
                                          ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey.shade300),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${medicine['quantity']}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.add_circle, color: Colors.green),
                                            onPressed: () {
                                              updateQuantity(medicine['name'], medicine['quantity'] + 1);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                        SizedBox(height: 16),
                        // Delete and Submit buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                deleteAllMedicines();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondaryColor,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Delete All', style: TextStyle(color: Colors.white,fontFamily: "Poppins")),
                            ),
                            ElevatedButton(
                              onPressed: selectedMedicines.isNotEmpty
                                  ? postSelectedMedicines
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Submit', style: TextStyle(color: Colors.white,fontFamily: "Poppins")),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ):
                  SizedBox(height: 20),
              // Center(
              //   child: ElevatedButton(
              //     onPressed: selectedMedicines.isNotEmpty
              //         ? postSelectedMedicines
              //         : null,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: AppColors.primaryColor,
              //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       ),
              //     ),
              //     child: Text(
              //       'Book Medicines',
              //       style: TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ],
    ),
        ),),
    );
  }
}
