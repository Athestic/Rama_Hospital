import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'PatientLogin.dart';
import 'app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart'; // For handling file type

class PatientProfileScreen extends StatefulWidget {
  final String patientId;

  PatientProfileScreen({required this.patientId});

  @override
  _PatientProfileScreenState createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late Future<Patient> futurePatient;
  File? _image;

  @override
  void initState() {
    super.initState();
    futurePatient = fetchPatientDetails();
    _loadProfilePicture();
  }

  Future<Patient> fetchPatientDetails() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl1}${AppConfig.getPatientByIdEndpoint}?PatientId=${widget.patientId}'),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return Patient.fromJson(responseData);
    } else {
      throw Exception('Failed to load patient details');
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => PatientLogin()),
          (route) => false,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        // Save the picture locally
        _saveProfilePicture(pickedFile.path);

        // Automatically upload the picture after selecting
        await _uploadProfilePicture();
      }
    } catch (e) {
      if (Platform.isIOS) {
        _showFailureDialog("Failed to pick image on iOS: $e");
      } else {
        _showFailureDialog("Failed to pick image: $e");
      }
    }
  }

  Future<void> _uploadProfilePicture() async {
    if (_image == null) {
      _showFailureDialog('No image selected.');
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.1.106:8081/api/HospitalApp/SaveOrUpdatePatientImage?uhid=${widget.patientId}'),
    );

    try {
      // Attach the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'imageFile', // key expected by the API for the image file
          _image!.path,
          contentType: MediaType('imageFile', 'jpg'), // Adjust based on your file type
        ),
      );

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        _showSuccessDialog('Profile updated successfully.');
      } else {
        // Displaying server's error message for better diagnosis
        String errorResponse = await response.stream.bytesToString();
        _showFailureDialog('Failed to update profile. Status code: ${response.statusCode}. Response: $errorResponse');
      }
    } catch (e) {
      _showFailureDialog('An error occurred: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showFailureDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Failed'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfilePicture(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('profilePicture', path);
  }

  Future<void> _loadProfilePicture() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? picturePath = prefs.getString('profilePicture');
    if (picturePath != null) {
      setState(() {
        _image = File(picturePath);
      });
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose profile picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Patient Dashboard',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            color: Colors.black,
            onPressed: _logout,
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder<Patient>(
        future: futurePatient,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final patient = snapshot.data!;
            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),

                      // Profile Image with Change Picture Button and Edit Icon
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.teal,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : patient.imageUrl.isNotEmpty
                                ? MemoryImage(base64Decode(patient.imageUrl)) // Decode base64 image
                                : null,
                            child: _image == null && patient.imageUrl.isEmpty
                                ? Text(
                              patient.firstName.isNotEmpty
                                  ? patient.firstName[0].toUpperCase()
                                  : '?',
                              style: TextStyle(fontSize: 50, color: Colors.white),
                            )
                                : null,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Hello, ${patient.firstName}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: _showImageSourceDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        ),
                        child: Text(
                          'Change Profile Picture',
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ),
                      SizedBox(height: 20),

                      // User Details
                      Card(
                        color: Colors.grey[100], // Light background for profile details
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow("Name", patient.firstName),
                              _buildDetailRow("Guardian Name", patient.fatherSpouseName),
                              _buildDetailRow("Patient Id", patient.patientId),
                              _buildDetailRow("Mobile No", patient.phoneNo),
                              _buildDetailRow("Aadhar No", patient.adharNo),
                              _buildDetailRow("DOB", patient.dob),
                              _buildDetailRow("Gender", patient.gender),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 100), // Extra space to avoid content overlap
                    ],
                  ),
                ),
              ],
            );
          }
          return Center(child: Text('No patient data available.'));
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Aligns items to the start
        children: [
          Expanded( // Use Expanded to wrap the value text
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          SizedBox(width: 10),
          Expanded( // Use Expanded to wrap the value text
            child: Text(
              value,
              style: TextStyle(fontSize: 13),
              softWrap: true, // Ensures text wraps
            ),
          ),
        ],
      ),
    );
  }
}
class Patient {
  final String patientId;
  final String firstName;
  final String gender;
  final String dob;
  final String phoneNo;
  final String fatherSpouseName;
  final String adharNo;
  final String imageUrl; // This will store base64-encoded image data

  Patient({
    required this.patientId,
    required this.firstName,
    required this.gender,
    required this.dob,
    required this.phoneNo,
    required this.fatherSpouseName,
    required this.adharNo,
    required this.imageUrl,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      patientId: json['patient_id'] ?? '',
      firstName: json['first_name'] ?? '',
      gender: json['gender'] ?? '',
      dob: json['dob'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      fatherSpouseName: json['father_spouse_name'] ?? '',
      adharNo: json['adharNo'] ?? '',
      imageUrl: json['patientImage'] ?? '', // Binary image base64-encoded
    );
  }
}

