import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:open_file/open_file.dart'; // Import this after adding it to pubspec.yaml

class ReportScreen extends StatefulWidget {
  final String ipid;
  final List<dynamic> reportData;
  final String patientId;



  ReportScreen({required this.ipid, required this.reportData,required this.patientId});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String patientName = '';
  String mobileNumber = '';
  String aadharNo = '';
  Map<String, dynamic> patientData = {};

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    fetchPatientDetails(); // Fetch patient data on initialization
    _requestNotificationPermission();
  }

  // Method to fetch patient data
  Future<void> fetchPatientDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://ramahospital.co.in/HospitalApplication/api/HospitalApp/GetPatientById?PatientId=${widget
                .patientId}'),
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

  // Method to initialize notifications
  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  // Handle notification click
  Future<void> _onDidReceiveNotificationResponse(
      NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      OpenFile.open(payload); // Open the downloaded file
    }
  }

  // Request notification permission for Android 13+
  void _requestNotificationPermission() async {
    bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    if (granted == true) {
      // Permission granted
    } else {
      // Permission denied
    }
  }

  // Show a notification
  Future<void> _showNotification(String title, String body,
      String filePath) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails('download_channel', 'Downloads',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true);

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
        payload: filePath); // Pass file path as payload
  }

  // Download report and show notifications
  Future<void> _downloadReport() async {
    final pdf = pw.Document();

    // Load the image data for the logo
    final ByteData imageData = await rootBundle.load(
        'assets/logo/mainlogo.png');
    final Uint8List imageBytes = imageData.buffer.asUint8List();

    // Add report data to the PDF with a border and minimized top space
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(20),
        footer: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            // Center the column's content horizontally
            children: [
              pw.Text(
                'Rama City, NH-9, Delhi Meerut Expressway, Near Mother Dairy, Pilkhuwa, Hapur (U.P.) - 245304',
                style: pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center, // Center text horizontally
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Phone: 7877775530 | Email: helpdesk@ramahospital.com',
                style: pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center, // Center text horizontally
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 12),
                textAlign: pw.TextAlign
                    .center, // Center page number text horizontally
              ),
            ],
          );
        },
        build: (pw.Context context) {
          return [
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 2),
              ),
              padding: pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Name: ${patientData['first_name'] ?? 'N/A'}',
                              style: pw.TextStyle(fontSize: 12)),
                          pw.Text('Patient ID: ${patientData['patient_id'] ??
                              'N/A'}', style: pw.TextStyle(fontSize: 12)),
                          pw.Text('Phone: ${patientData['phone_no'] ?? 'N/A'}',
                              style: pw.TextStyle(fontSize: 12)),
                          pw.Text(
                              'Father: ${patientData['father_spouse_name'] ??
                                  'N/A'}', style: pw.TextStyle(fontSize: 12)),
                          pw.Text(
                              'Aadhar No: ${patientData['adharNo'] ?? 'N/A'}',
                              style: pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                      pw.Image(
                        pw.MemoryImage(imageBytes),
                        width: 150,
                        height: 150,
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  ...widget.reportData.map((category) {
                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Category: ${category['categoryName']}',
                            style: pw.TextStyle(fontSize: 18)),
                        pw.SizedBox(height: 10),
                        ...category['services'].map<pw.Widget>((service) {
                          return pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Service: ${service['serviceName']}',
                                  style: pw.TextStyle(fontSize: 16)),
                              pw.SizedBox(height: 5),
                              pw.Table(
                                border: pw.TableBorder.all(
                                    color: PdfColors.grey),
                                columnWidths: {
                                  0: pw.FlexColumnWidth(3),
                                  1: pw.FlexColumnWidth(1),
                                  2: pw.FlexColumnWidth(2),
                                  3: pw.FlexColumnWidth(2),
                                },
                                children: [
                                  pw.TableRow(
                                    decoration: pw.BoxDecoration(
                                        color: PdfColors.lightBlue),
                                    children: [
                                      pw.Text('Component Name',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,fontSize: 10)),
                                      pw.Text('Unit', style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,fontSize: 10)),
                                      pw.Text('Range', style: pw.TextStyle(
                                          fontWeight: pw.FontWeight.bold,fontSize: 10)),
                                      pw.Text('Actual Value',
                                          style: pw.TextStyle(
                                              fontWeight: pw.FontWeight.bold,fontSize: 10)),
                                    ],
                                  ),
                                  ...List.generate(
                                      service['components'].length, (index) {
                                    final component = service['components'][index];
                                    return pw.TableRow(
                                      decoration: pw.BoxDecoration(
                                        color: index.isEven
                                            ? PdfColors.white
                                            : PdfColors.grey200,
                                      ),
                                      children: [
                                        pw.Text(
                                            component['pathCompName'] ?? 'N/A'),
                                        pw.Text(component['pathUnitValue'] ??
                                            'N/A'),
                                        pw.Text(
                                            component['rangeValue'] ?? 'N/A'),
                                        pw.Text(
                                            component['actualValue'] ?? 'N/A'),
                                      ],
                                    );
                                  }),
                                ],
                              ),

                              pw.SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Save the PDF or trigger download (based on your existing logic

    try {
      _showNotification(
          'Download Started', 'Your report is downloading...', '');

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        if (directory == null) throw 'Unable to get external storage directory';
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      }

      final filePath = Platform.isAndroid
          ? '${directory!.path.split('Android')[0]}Download/report_${widget
          .ipid}.pdf'
          : '${directory!.path}/report_${widget.ipid}.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      _showNotification(
          'Download Complete', 'Your report has been downloaded', filePath);

      print('Report downloaded at: $filePath');
      HapticFeedback.mediumImpact();

      OpenFile.open(filePath);
    } catch (e) {
      print('Error while saving the PDF: $e');
      _showNotification(
          'Download Failed', 'There was an error while downloading the report',
          '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report for IPID: ${widget.ipid}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadReport,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.reportData.length,
          itemBuilder: (context, index) {
            final category = widget.reportData[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(


                  child: Text(
                    'Category: ${category['categoryName']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                ...category['services'].map<Widget>((service) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Service: ${service['serviceName']}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      DataTable(
                        columnSpacing: 10,
                        headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.blueAccent),
                        border: TableBorder.all(color: Colors.grey),
                        columns: [
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Component Name',
                                style: TextStyle(color: Colors.white,fontSize: 10),

                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Unit',
                                style: TextStyle(color: Colors.white,fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Range',
                                style: TextStyle(color: Colors.white,fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Expanded(
                              child: Text(
                                'Actual Value',
                                style: TextStyle(color: Colors.white,fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        rows: List.generate(
                          service['components'].length,
                              (componentIndex) {
                            final component = service['components'][componentIndex];
                            return DataRow(
                              cells: [
                                DataCell(
                                    Text(component['pathCompName'] ?? 'N/A')),
                                DataCell(
                                    Text(component['pathUnitValue'] ?? 'N/A')),
                                DataCell(
                                    Text(component['rangeValue'] ?? 'N/A')),
                                DataCell(
                                    Text(component['actualValue'] ?? 'N/A')),
                              ],
                            );
                          },
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
    );
  }
}