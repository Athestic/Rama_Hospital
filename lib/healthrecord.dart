import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'Reports.dart'; // Make sure to have this screen to display the report
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'app_config.dart';

class HealthRecordsScreen extends StatefulWidget {
  final String patientId;

  HealthRecordsScreen({required this.patientId});

  @override
  _HealthRecordsScreenState createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  bool isLoading = true;
  Map<String, dynamic> ipdData = {};
  Map<String, dynamic> opdData = {};
  Uint8List? patientImage;
  String? first_name;

  // Variables for filtering
  String selectedFilter = 'Show All'; // Default filter option
  List<String> filterOptions = ['Show All', 'IPD', 'OPD']; // Filter options

  @override
  void initState() {
    super.initState();
    fetchIPDDetails();
    fetchOPDDetails();

    _getPatientname();
  }

  Future<void> _getPatientname() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    first_name = prefs.getString('first_name'); // Get the saved patient name
  }

  Future<void> fetchIPDDetails() async {
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.apiUrl1}${AppConfig.getIpidWithImageEndpoint}?patientId=${widget.patientId}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['patientImage'] != null) {
          patientImage = base64Decode(data['patientImage']);
        }

        setState(() {
          ipdData = data;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load IPD details');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error occurred: $error');
    }
  }

  Future<void> fetchOPDDetails() async {
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.apiUrl1}${AppConfig.getOpdByPatientIdEndpoint}?PatientId=${widget.patientId}'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          opdData = {
            'opdRecords': data,
          };
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load OPD details');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error occurred: $error');
    }
  }


  Future<void> fetchPatientReport(String ipid) async {
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.apiUrl1}${AppConfig.getPatientReportByIPIDEndpoint}?IPID=$ipid'));

      if (response.statusCode == 200) {
        final List<dynamic> reportData = jsonDecode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(
              reportData: reportData,
              ipid: ipid,
              patientId: widget.patientId,
            ),
          ),
        );
      } else {
        print('Failed to load patient report');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<void> fetchPatientOPDReport(String opdid) async {
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.apiUrl1}${AppConfig.getPatientReportByOPDEndpoint}?OPDID=$opdid'));

      if (response.statusCode == 200) {
        final List<dynamic> reportData = jsonDecode(response.body);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportScreen(
              reportData: reportData,
              ipid: opdid,
              patientId: widget.patientId,
            ),
          ),
        );
      } else {
        print('Failed to load patient report');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }


  String formatDate(String dateTime) {
    if (dateTime.isEmpty) return 'N/A';
    DateTime parsedDate = DateTime.parse(dateTime);
    return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
  }

  // Function to display all records (both IPD and OPD)
  Widget buildAllRecords() {
    List<Map<String, dynamic>> allRecords = [];

    // Add IPD record to the list if IPD data is available
    if (ipdData.isNotEmpty) {
      allRecords.add({
        'type': 'Reciept',
        'number': ipdData['ipid']?.toString() ?? 'N/A',
        'date': formatDate(ipdData['doa']?.toString() ?? ''),
        'viewAction': () {
          fetchPatientReport(ipdData['ipid']?.toString() ?? 'N/A');
        }
      });
    }

    // Add OPD records to the list if OPD data is available
    List<dynamic> opdRecords = opdData['opdRecords'] ?? [];
    for (var record in opdRecords) {
      allRecords.add({
        'type': 'Reciept',
        'number': record['opd_registration_no']?.toString() ?? 'N/A',
        'date': formatDate(record['registration_date']?.toString() ?? ''),
        'viewAction': () {
          fetchPatientOPDReport(record['opd_registration_no']?.toString() ?? 'N/A');
        }
      });
    }

    // Return the ListView
    return ListView.builder(
      itemCount: allRecords.length,
      itemBuilder: (context, index) {
        final record = allRecords[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0), // Add some vertical spacing
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to space them evenly
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record['type']} No: ${record['number']}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Registration Date: ${record['date']}',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: record['viewAction'],
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor, // Background color
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                  elevation: 5, // Shadow elevation
                ),
                child: Text(
                  'View',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Function to filter records based on user selection
  Widget buildFilteredRecords() {
    if (selectedFilter == 'Show All') {
      return buildAllRecords(); // Show both IPD and OPD records
    } else if (selectedFilter == 'IPD') {
      return buildIPDRecord();
    } else if (selectedFilter == 'OPD') {
      return buildOPDRecord();
    }
    return Container();
  }

  Widget buildIPDRecord() {
    return ListView(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receipt No: ${ipdData['ipid']?.toString() ?? 'N/A'}',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Registration Date: ${formatDate(ipdData['doa']?.toString() ?? '')}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8), // Add some spacing between the text and button
            ElevatedButton(
              onPressed: () {
                fetchPatientReport(ipdData['ipid']?.toString() ?? 'N/A');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor, // Background color

                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
                elevation: 5, // Shadow elevation
              ),
              child: Text(
                'View',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        Divider(), // Optional: add a divider for better separation between records
      ],
    );
  }


  Widget buildOPDRecord() {
    List<dynamic> opdRecords = opdData['opdRecords'] ?? [];

    return ListView.builder(
      itemCount: opdRecords.length,
      itemBuilder: (context, index) {
        final record = opdRecords[index];
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reciept No: ${record['opd_registration_no']?.toString() ?? 'N/A'}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Registration Date: ${formatDate(record['registration_date']?.toString() ?? '')}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    fetchPatientOPDReport(record['opd_registration_no']?.toString() ?? 'N/A');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
                    'View',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
            Divider(),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor3,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor3,
        title: Text(first_name ?? 'Health Records',style: TextStyle(
          color: AppColors.primaryColor,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
        ),
      ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Row for patient image, name, and ID
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Patient image with border radius
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey,
                    child: patientImage != null
                        ? Image.memory(
                      patientImage!,
                      fit: BoxFit.cover,
                    )
                        : Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.patientId}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Styled Dropdown filter
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: DropdownButton<String>(
                value: selectedFilter,
                isExpanded: true,
                underline: SizedBox(),
                icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
                items: filterOptions
                    .map((filter) => DropdownMenuItem(
                  child: Text(
                    filter,
                    style: TextStyle(
                        fontSize: 16, color: Colors.teal),
                  ),
                  value: filter,
                ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedFilter = newValue!;
                  });
                },
              ),
            ),

            SizedBox(height: 16),

            // Display filtered records in a styled list format
            Expanded(child: buildFilteredRecords()),
          ],
        ),
      ),
    );
  }
}
