import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'Reports.dart';
import 'colors.dart';
import 'app_config.dart';
import 'healthReports.dart';

class HealthRecordsScreen extends StatefulWidget {
  final String patientId;

  HealthRecordsScreen({required this.patientId});

  @override
  _HealthRecordsScreenState createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  bool isLoading = true;
  Uint8List? patientImage;
  String? firstName;
  List<Map<String, dynamic>> patientReports = [];


  @override
  void initState() {
    super.initState();
    fetchPatientReports();
    _getPatientName();
  }

  Future<void> fetchPatientReports() async {
    try {
      final response = await http.get(Uri.parse(
          '${AppConfig.apiUrl1}${AppConfig.getPatientReportPdfEndpoint}?patientId=${widget.patientId}'
      ));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          patientReports =
          List<Map<String, dynamic>>.from(data); // 👈 DIRECTLY use data
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load reports');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching reports: $error');
    }
  }


  Future<void> _getPatientName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('first_name');
    });
  }

  String formatDate(String dateTime) {
    if (dateTime.isEmpty) return 'N/A';
    try {
      final DateTime parsed = DateTime.parse(dateTime);
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed
          .day.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Invalid Date';
    }
  }

  Widget buildRecordsList(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return Center(
          child: Text('No records available.', style: TextStyle(fontSize: 16)));
    }

    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final record = records[index];
        final bool isOPD = record['type'] == 'OPD';

        return ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Receipt No: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black, // Important: set color because TextSpan defaults to white
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: '${record['sample_id'] ?? 'N/A'}',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () {
              final String? base64Pdf = record['pdf_file'];
              if (base64Pdf != null && base64Pdf.isNotEmpty) {
                print('Base64 PDF length: ${base64Pdf.length}');
                try {
                  final Uint8List pdfBytes = base64Decode(base64Pdf);
                  print('Decoded PDF bytes length: ${pdfBytes.length}');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Reports(pdfBytes: pdfBytes),
                    ),
                  );
                } catch (e) {
                  print('Error decoding PDF: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Invalid PDF format')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No PDF available')),
                );
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
            ),
            child: Text('View', style: TextStyle(color: Colors.white)),
          ),
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
        elevation: 0,
        title: Text(
          firstName ?? 'Health Records',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[300],
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  widget.patientId,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),


            SizedBox(height: 16),

            Expanded(child: buildRecordsList(patientReports)),
          ],
        ),
      ),
    );
  }
}