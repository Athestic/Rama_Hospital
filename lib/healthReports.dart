import 'dart:typed_data';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';
import 'colors.dart';

class Reports extends StatefulWidget {
  final Uint8List pdfBytes;

  const Reports({Key? key, required this.pdfBytes}) : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestNotificationPermission();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  Future<void> _onDidReceiveNotificationResponse(NotificationResponse response) async {
    final String? payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      OpenFile.open(payload);
    }
  }

  void _requestNotificationPermission() async {
    bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (granted != true) {
      print('Notification permission denied');
    }
  }

  Future<void> _showNotification(String title, String body, String filePath) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'download_channel',
      'Download Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: filePath,
    );
  }

  Future<void> _downloadReport(BuildContext context) async {
    try {
      var status = await Permission.storage.status;

      if (Platform.isAndroid) {
        if (status.isDenied || status.isRestricted || status.isLimited) {
          status = await Permission.storage.request();
        }

        if (await Permission.manageExternalStorage.isDenied) {
          var manageStatus = await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Manage External Storage permission denied')),
            );
            return;
          }
        }
      }

      if (status.isGranted || await Permission.manageExternalStorage.isGranted) {
        await _showNotification('Downloading', 'Your report is downloading...', '');

        String fileName = 'Patient_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';

        String filePath;

        if (Platform.isAndroid) {
          String downloadsPath = '/storage/emulated/0/Download';
          Directory downloadsDir = Directory(downloadsPath);

          if (!downloadsDir.existsSync()) {
            downloadsDir.createSync(recursive: true);
          }

          filePath = '${downloadsDir.path}/$fileName';
        } else {
          final dir = await getApplicationDocumentsDirectory();
          filePath = '${dir.path}/$fileName';
        }

        File file = File(filePath);
        await file.writeAsBytes(widget.pdfBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report downloaded successfully')),
        );

        await _showNotification('Download Complete', '$fileName saved.', filePath);
      } else if (status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Storage permission permanently denied. Please enable it from app settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied')),
        );
      }
    } catch (e) {
      print('Download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading file: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor3,
      appBar: AppBar(
        backgroundColor: AppColors.cardColor3,
        elevation: 0,
        title: Text(
          'Patient Report',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: () => _downloadReport(context),
        //     icon: Icon(Icons.download, color: AppColors.primaryColor),
        //     tooltip: 'Download Report',
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          color: AppColors.primaryColor,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SfPdfViewer.memory(widget.pdfBytes),
            ),
          ),
        ),
      ),
    );
  }
}