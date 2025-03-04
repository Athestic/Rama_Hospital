import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'package:global/pharmaorderlist.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';

class MedicinePage extends StatefulWidget
{
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
  String? patientId;
  File? prescriptionFile;
  bool _isButtonEnabled = true;
  final ImagePicker _imagePicker = ImagePicker();


  @override
  void initState() {
    super.initState();
    fetchMedicines();
    _getPatientId();
  }
  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }
  Future<void> _getPatientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    patientId = prefs.getString('patientId');
  }

  Future<void> fetchMedicines() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.144:8081/api/Pharma/GetPharmaItems'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        setState(() {
          medicines = data.map((item) {
            String fullName = item['item_name'];
            // Extract medicine name before the first occurrence of "1*" or similar pattern
            String medicineName = fullName.split(RegExp(r'\s\d+\*'))[0].trim();

            String cost = '';
            if (fullName.contains('\$') && fullName.contains('^')) {
              cost = fullName.split('\$')[1].split('^')[0].trim();
              // Round up the cost to the nearest whole number
              if (cost.isNotEmpty) {
                double costValue = double.parse(cost);
                cost = costValue.ceil().toString(); // Round up and convert back to string
              }
            }

            String expiryDate = '';
            if (fullName.contains('^') && fullName.contains(')')) {
              expiryDate = fullName.split('^')[1].split(')')[0].trim();
            }
            String itemCode = item['itemCode'];
            String itemGroupName = item['itemGroupName'];

            return {
              'name': medicineName,
              'cost': cost,
              'expiryDate': expiryDate,
              'itemCode': itemCode,
              'itemGroupName': itemGroupName,
            };
          }).toList();

          filteredMedicines = [];
        });
      } else {
        print('Failed to load medicines: ${response.statusCode}');
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

  void addMedicine(String name, String cost, String expiryDate, String itemCode,
      String itemGroupName) {
    setState(() {
      bool exists = selectedMedicines.any((medicine) =>
      medicine['name'] == name);

      if (!exists) {
        selectedMedicines.add({
          'name': name,
          'cost': cost,
          'expiryDate': expiryDate,
          'itemCode': itemCode,
          'itemGroupName': itemGroupName,
          'quantity': 1,
        });
      }

      searchController.clear();
      filteredMedicines = [];

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

  Future<void> pickPrescriptionFile() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Capture with Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image =
                await _imagePicker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    prescriptionFile = File(image.path);
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.file_copy),
              title: Text('Choose from Files'),
              onTap: () async {
                Navigator.pop(context);
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
                );
                if (result != null) {
                  setState(() {
                    prescriptionFile = File(result.files.single.path!);
                  });
                }
              },
            ),
          ],
        );
      },
    );
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

  Map<String, dynamic> generatePayload() {
    return {
      'patientId': patientId,
      'RequisitionDetails': selectedMedicines.map((medicine) {
        return {
          'ItemGroupName': medicine['itemGroupName'],
          'ItemCode': medicine['itemCode'],
          'ItemName': medicine['name'],
          'Qty': medicine['quantity'],
          'ServiceUnitPrice': double.tryParse(medicine['cost']) ?? 0.0,
          'ForDays': '10',
        };
      }).toList(),
    };
  }

  Future<void> postSelectedMedicines() async {
    final url = 'http://192.168.1.144:8081/Api/Pharma/AddPharmaItems';
    setState(() {
      _isButtonEnabled = false; // Disable the button
    });
    Map<String, dynamic> payload = generatePayload();

    print("Payload to be sent: ${jsonEncode(payload)}");

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['patientId'] = patientId ?? '';

      if (prescriptionFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'Precription',
            prescriptionFile!.path,
            filename: prescriptionFile!
                .path
                .split('/')
                .last,
          ),
        );
      } else {
        print("No prescription file selected.");
      }

      request.fields['RequisitionDetails'] =
          jsonEncode(payload['RequisitionDetails']);

      print("Request Fields: ${request.fields}");
      print("Request Files: ${request.files.map((file) => file.filename).toList()}");

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      print("Response status code: ${response.statusCode}");
      print("Response body: $responseBody");

      if (response.statusCode == 200) {
        print('Data posted successfully');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('You have successfully purchased the selected medicines.'),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedMedicines.clear();
                      prescriptionFile = null;  // Clear the prescription image
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PharmacyOrderList(patientId: patientId ?? 'default_patient_id'),
                      ),
                    );
                    setState(() {
                      selectedMedicines.clear();
                      prescriptionFile = null;  // Clear the prescription image
                    });
                  },
                  child: Text('Check Your Order? Click Here'),
                ),
              ],
            );
          },
        );
      } else {
        print('Failed to post data: ${response.reasonPhrase}');

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Failed'),
              content: Text('Sorry, failed to purchase medicines.'),
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
      print('Error occurred: $e');

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(
          'Medicine',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            // fontSize: screenWidth * 0.05,
            fontSize: 25


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
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Medicine',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Poppins'
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Enter service name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black,
                              width: 1.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black,
                              width: 1.0),
                        ),
                      ),
                      onChanged: filterMedicines,
                    ),
                    filteredMedicines.isNotEmpty
                        ? SizedBox(
                      height: 300,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: ClampingScrollPhysics(),

                              itemCount: filteredMedicines.length,
                              itemBuilder: (context, index) {
                                final medicine = filteredMedicines[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors.grey.shade300, width: 1),
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
                                      'Cost: ₹${medicine['cost']} | Expiry: ${medicine['expiryDate']}',
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ),

                                    onTap: () {
                                      addMedicine(
                                        medicine['name']!,
                                        medicine['cost']!,
                                        medicine['expiryDate']!,
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
                    ) :
                    SizedBox(height: screenHeight * 0.02),
                    // Prescription Upload Section
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.01,
                        horizontal: screenWidth * 0.03,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/icon/pres.jpg'),
                            radius: screenWidth * 0.05,
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: Text(
                              'Order By Prescription',
                              style: TextStyle(
                                fontSize: 15,
                                // fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: pickPrescriptionFile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              minimumSize: Size(0, 0),
                            ),

                            child: Text(
                              'Upload',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    selectedMedicines.isNotEmpty
                        ? Container(
                      padding: EdgeInsets.all(10),
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
                          Text(
                            'Your Medicine Order',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          ...selectedMedicines.map((medicine) {
                            return Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    padding: EdgeInsets.all(6),
                                    child: Image.asset(
                                      'assets/icon/tablet.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          medicine['name'],
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        Row(
                                          children: [
                                            // Decrease quantity button
                                            InkWell(
                                              onTap: () {
                                                if (medicine['quantity'] > 1) {
                                                  updateQuantity(
                                                    medicine['name'],
                                                    medicine['quantity'] - 1,
                                                  );
                                                }
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  Icons.remove,
                                                  size: 8,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 2),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${medicine['quantity']}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Poppins',
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            // Increase quantity button
                                            InkWell(
                                              onTap: () {
                                                updateQuantity(
                                                  medicine['name'],
                                                  medicine['quantity'] + 1,
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.grey),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  Icons.add,
                                                  size: 8,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Column(
                                    children: [
                                      Text(
                                        '₹${medicine['cost']}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green.shade800,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 24,
                                        ),
                                        onPressed: () {
                                          deleteMedicine(medicine['name']);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          SizedBox(height: screenHeight * 0.02),
                          GestureDetector(
                            onTap: () {
                              searchFocusNode.requestFocus();
                            },
                            child: Text(
                              'Add more items',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Prescription Upload Section
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: AssetImage('assets/icon/pres.jpg'),
                                      radius: 25,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Attached by Prescription',
                                        style: TextStyle(
                                          fontSize: 15,
                                          // fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: pickPrescriptionFile,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 8),
                                        minimumSize: Size(0, 0),
                                      ),
                                      child: Text(
                                        'Upload',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20,),
                          Row(
                            children: [
                              Text(
                                'Don\'t have prescription',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 50),
                              GestureDetector(
                                onTap: _callPhoneNumber,
                                child: Text(
                                  ' Call Now',
                                  style: TextStyle(
                                    color: AppColors.secondaryColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'Your Prescription Image',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (prescriptionFile != null)
                            Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.01),
                              child: Container(
                                width: double.infinity,
                                height: screenHeight * 0.25,
                                padding: EdgeInsets.all(screenWidth * 0.02),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      blurRadius: 5,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        File(prescriptionFile!.path),
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: -screenHeight * 0.01,
                                      left: 0,
                                      right: screenWidth * 0.4,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            prescriptionFile = null;
                                          });
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(screenWidth * 0.02),
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: screenWidth * 0.05,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),



                          SizedBox(height: screenHeight * 0.05),
                          Center(
                            child: ElevatedButton(
                              onPressed: selectedMedicines.isNotEmpty && _isButtonEnabled
                                  ? () => postSelectedMedicines()
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                ),
                              ),
                              child: Text(
                                'Book Medicine',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Container(),

                    SizedBox(height: screenHeight * 0.03),

                    // Text(
                    //   'Why Rama',
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.grey.shade700,
                    //     fontFamily: 'Poppins',
                    //   ),
                    // ),
                    // SizedBox(height: 12),
                    // Container(
                    //   padding: EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue.shade100,
                    //     borderRadius: BorderRadius.circular(12),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Colors.grey.withOpacity(0.2),
                    //         spreadRadius: 2,
                    //         blurRadius: 5,
                    //       ),
                    //     ],
                    //   ),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         'Top-Selling Medicines',
                    //         style: TextStyle(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.bold,
                    //           fontFamily: 'Poppins',
                    //         ),
                    //       ),
                    //       SizedBox(height: 8),
                    //       Text(
                    //         'Our most popular medicines trusted by thousands.',
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           color: Colors.grey.shade700,
                    //           fontFamily: 'Poppins',
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _callPhoneNumber() async {
  const phoneNumber = '8650960313';
  final Uri phoneUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  if (await canLaunch(phoneUri.toString())) {
    await launch(phoneUri.toString());
  } else {
    throw 'Could not dial the phone number $phoneNumber';
  }
}




