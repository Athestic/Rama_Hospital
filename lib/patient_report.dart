import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PatientReportScreen extends StatefulWidget {
  final String ipid;
  final String patientId;

  PatientReportScreen({required this.ipid, required this.patientId});

  @override
  _PatientReportScreenState createState() => _PatientReportScreenState();
}

class _PatientReportScreenState extends State<PatientReportScreen> {
  List<Map<String, dynamic>> reportData = [];
  Map<String, dynamic> patientData = {};

  @override
  void initState() {
    super.initState();
    fetchPatientReport();
    fetchPatientDetails();
  }

  Future<void> fetchPatientReport() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.179:8081/api/HospitalApp/GetPatientReportByIPID?IPID=${widget.ipid}'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          reportData = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          reportData = [];
        });
      }
    } catch (e) {
      print('Error fetching report: $e');
      setState(() {
        reportData = [];
      });
    }
  }

  Future<void> fetchPatientDetails() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.179:8081/api/HospitalApp/GetPatientById?PatientId=${widget.patientId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          patientData = json.decode(response.body);
        });
      } else {
        setState(() {
          patientData = {};
        });
      }
    } catch (e) {
      print('Error fetching patient details: $e');
      setState(() {
        patientData = {};
      });
    }
  }

  Future<void> downloadReportAsPDF() async {
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        final ByteData bytes = await rootBundle.load('assets/ramalogoapp.png');
        final Uint8List byteList = bytes.buffer.asUint8List();

        final pdf = pw.Document();

        pdf.addPage(
          pw.Page(
            build: (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [

                        pw.Text('Name: ${patientData['first_name'] ?? 'N/A'}'),
                        pw.Text('Patient ID: ${patientData['patient_id'] ?? 'N/A'}'),
                        pw.Text('Phone: ${patientData['phone_no'] ?? 'N/A'}'),
                        pw.Text('Father: ${patientData['father_spouse_name'] ?? 'N/A'}'),
                        pw.Text('Aadhar No: ${patientData['adharNo'] ?? 'N/A'}'),
                      ],
                    ),
                    pw.Image(pw.MemoryImage(byteList), width: 100),
                  ],
                ),
                pw.SizedBox(height: 16),
                // pw.Text('Patient Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                ...reportData.map((reportItem) {
                  var categoryName = reportItem['categoryName'] ?? 'Unknown';
                  var services = List<Map<String, dynamic>>.from(reportItem['services'] ?? []);

                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Category: $categoryName', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 8),
                      ...services.map((service) {
                        var serviceName = service['serviceName'] ?? 'Unknown';
                        var components = List<Map<String, dynamic>>.from(service['components'] ?? []);

                        return pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('Service: $serviceName', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                            pw.Table.fromTextArray(
                              headers: ['PathCompName', 'PathUnitValue', 'PathUnitName', 'RangeValue', 'ActualValue'],
                              data: components.map((component) {
                                return [
                                  component['pathCompName'] ?? 'N/A',
                                  component['pathUnitValue'] ?? 'N/A',
                                  component['pathUnitName'] ?? 'N/A',
                                  component['rangeValue'] ?? 'N/A',
                                  component['actualValue'] ?? 'N/A',
                                ];
                              }).toList(),
                            ),
                            pw.SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        );

        Directory? directory = await getExternalStorageDirectory();
        if (directory != null) {
          String path = directory.path;
          String fileName = 'patient_report_${widget.ipid}.pdf';
          File file = File('$path/$fileName');

          await file.writeAsBytes(await pdf.save());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF downloaded to $path/$fileName')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error accessing storage directory')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Report'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: downloadReportAsPDF,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: reportData.isEmpty
            ? Center(child: Text('No data available'))
            : Column(
          children: [
            // Align(
            //   alignment: Alignment.topRight,
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Image.asset(
            //       'assets/ramalogoapp.png',
            //       height: 50,
            //     ),
            //   ),
            // ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: reportData.length,
                itemBuilder: (context, index) {
                  var reportItem = reportData[index];
                  var categoryName = reportItem['categoryName'] ?? 'Unknown';
                  var services = List<Map<String, dynamic>>.from(reportItem['services'] ?? []);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category: $categoryName',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      ...services.map((service) {
                        var serviceName = service['serviceName'] ?? 'Unknown';
                        var components = List<Map<String, dynamic>>.from(service['components'] ?? []);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Service: $serviceName',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                border: TableBorder.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                columns: [
                                  DataColumn(label: Text('PathCompName')),
                                  DataColumn(label: Text('PathUnitValue')),
                                  DataColumn(label: Text('PathUnitName')),
                                  DataColumn(label: Text('RangeValue')),
                                  DataColumn(label: Text('ActualValue')),
                                ],
                                rows: components.map((component) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(component['pathCompName'] ?? 'N/A')),
                                      DataCell(Text(component['pathUnitValue'] ?? 'N/A')),
                                      DataCell(Text(component['pathUnitName'] ?? 'N/A')),
                                      DataCell(Text(component['rangeValue'] ?? 'N/A')),
                                      DataCell(Text(component['actualValue'] ?? 'N/A')),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
