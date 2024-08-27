import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'PatientLogin.dart';
import 'bookappointment.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import'app_config.dart';
import 'patient_report.dart';
class MainScreen extends StatefulWidget {
  final String patientId;
  final Function(String) onLogin;

  MainScreen({required this.patientId, required this.onLogin});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      HomePage(),
      BookingAppointmentPage(),
      PatientProfileScreen(patientId: widget.patientId), // Pass patientId here
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/home.png')),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/appointment.png')),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/patient.png')),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PatientProfileScreen extends StatefulWidget {
  final String patientId;

  PatientProfileScreen({required this.patientId});

  @override
  _PatientProfileScreenState createState() => _PatientProfileScreenState();
}
class _PatientProfileScreenState extends State<PatientProfileScreen> {
  String name = 'Loading...';
  String fatherName = 'Loading...';
  String dob = 'Loading...';
  String sex = 'Loading...';
  String patientId = 'Loading...';
  File? _profileImage; // Store the profile image

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
  }

  Future<void> fetchPatientDetails() async {
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl1}${AppConfig.getPatientByIdEndpoint}?PatientId=${widget.patientId}'),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        String firstName = data['first_name'] ?? 'Unknown';
        name = '$firstName ';
        fatherName = data['father_spouse_name'] ?? 'Unknown';
        dob = data['dob'] ?? 'Unknown';
        sex = data['gender'] ?? 'Unknown';
        patientId = data['patient_id'] ?? 'Unknown';
      });
    } else {
      setErrorState();
    }
  }

  void setErrorState() {
    setState(() {
      name = 'Failed to load';
      dob = 'Failed to load';
      fatherName = 'Failed to load';
      sex = 'Failed to load';
      patientId = 'Failed to load';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHealthRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HealthRecordsScreen(patientId: patientId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : null,
                  child: _profileImage == null
                      ? Text(
                    name.isNotEmpty ? name[0] : 'R',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  )
                      : null,
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Hello, $name',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () {
                    _showImageSourceActionSheet(context);
                  },
                  child: Text(
                    'Change Profile Picture',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.teal[100],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
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
                      'My Profile',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Divider(thickness: 1, color: Colors.grey),
                    ProfileInfoRow(label: 'Name', value: name),
                    ProfileInfoRow(label: 'Guardian Name', value: fatherName),
                    ProfileInfoRow(label: 'D.O.B', value: dob),
                    ProfileInfoRow(label: 'Gender', value: sex),
                    ProfileInfoRow(label: 'Patient ID', value: patientId),
                  ],
                ),
              ),
              SizedBox(height: 20),
              SectionHeader(title: 'Health Details'),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('My Appointments'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.health_and_safety),
                title: Text('My Health Records'),
                onTap: _showHealthRecords,
              ),
              ListTile(
                leading: Icon(Icons.add_circle_outline),
                title: Text('Book an Appointment'),
                onTap: () {},
              ),
              SizedBox(height: 20),
              SectionHeader(title: 'More Details'),
              ListTile(
                leading: Icon(Icons.privacy_tip),
                title: Text('Privacy Policy'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('About Us'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.rule),
                title: Text('Terms of Use'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.feedback_outlined),
                title: Text('Feedback'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedbackScreen(
                        patientId: widget.patientId, // Pass the patient ID
                        category: 'Doctors', // Set the default category to "Doctors"
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.question_answer),
                title: Text('FAQs'),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                // onTap: () async {
                //   // SharedPreferences prefs = await SharedPreferences.getInstance();
                //   // await prefs.setBool('isLoggedIn', false);
                //   // Navigator.pushReplacement(
                //   //   context,
                //   // MaterialPageRoute(builder: (context) => PatientLogin()),
                //   );
                // },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Page'),
    );
  }
}

class BookingAppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Booking Appointment Page'),
    );
  }
}

class HealthRecordsScreen extends StatefulWidget {
  final String patientId;

  HealthRecordsScreen({required this.patientId});

  @override
  _HealthRecordsScreenState createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  String patientName = 'Loading...';
  List<Map<String, String>> healthRecords = []; // List to hold health records

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
  }

  Future<void> fetchPatientDetails() async {
    // Fetch patient details
    final response = await http.get(
      Uri.parse('${AppConfig.apiUrl1}${AppConfig.getPatientByIdEndpoint}?PatientId=${widget.patientId}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        patientName = data['first_name'] ?? 'Unknown';
      });

      // Fetch IPID and DOA information
      final ipidResponse = await http.get(
        Uri.parse('http://192.168.1.179:8081/api/HospitalApp/GetIpidWithImeage?patientId=${widget.patientId}'),
      );

      if (ipidResponse.statusCode == 200) {
        final ipidData = json.decode(ipidResponse.body);
        setState(() {
          healthRecords = [
            {
              "admitted": ipidData['doa']?.split('T').first ?? 'Unknown',
              "ipid": ipidData['ipid'].toString(),
              "report": "View Report"
            }
          ];
        });
      } else {
        setState(() {
          healthRecords = [
            {"admitted": "Failed to load", "ipid": "Unknown", "report": ""}
          ];
        });
      }
    } else {
      setState(() {
        patientName = 'Failed to load';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController patientIdController = TextEditingController(text: widget.patientId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Health Records'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Patient Name: $patientName', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextField(
              controller: patientIdController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Patient ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Admitted')),
                  DataColumn(label: Text('IPID')),
                  DataColumn(label: Text('Report')),
                ],
                rows: healthRecords.map((record) {
                  return DataRow(cells: [
                    DataCell(Text(record['admitted'] ?? 'Unknown')), // Admitted column
                    DataCell(Text(record['ipid'] ?? 'Unknown')),     // IPID column
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the PatientReportScreen with IPID
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PatientReportScreen(ipid: record['ipid']!,patientId: widget.patientId,),
                            ),
                          );
                        },
                        child: Text(record['report'] ?? 'View Report'),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FeedbackScreen extends StatefulWidget {
  final String patientId;
  final String category;

  FeedbackScreen({required this.patientId, required this.category});

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  bool isLoading = false;

  Future<void> submitFeedback() async {
    setState(() {
      isLoading = true;
    });

    // Prepare the feedback data
    final feedbackData = {
      'patient_id': widget.patientId,
      'category': widget.category,
      'feedback': _feedbackController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiUrl1}/submitFeedback'), // Update with your endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode(feedbackData),
      );

      if (response.statusCode == 200) {
        // Handle successful submission
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Feedback submitted successfully!'),
        ));
        Navigator.pop(context); // Go back to the previous screen
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to submit feedback. Please try again.'),
        ));
      }
    } catch (e) {
      // Handle network or other errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred. Please try again.'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category: ${widget.category}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Patient ID: ${widget.patientId}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Your Feedback',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: () {
                if (_feedbackController.text.isNotEmpty) {
                  submitFeedback();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please write some feedback.'),
                  ));
                }
              },
              child: Text('Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
