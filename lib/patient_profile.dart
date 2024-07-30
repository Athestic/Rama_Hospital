import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'feedback.dart';
import 'bottomnavigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart'; // Import the Homepage
import 'PatientLogin.dart';
import 'bookappointment.dart';

class MainScreen extends StatefulWidget {
  final String patientId;

  MainScreen({required this.patientId});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default to Home tab

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      HomePage(),
      BookingAppointmentPage(),
      PatientProfileScreen(patientId: widget.patientId),
    ];

    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNav(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      );
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

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
  }

  Future<void> fetchPatientDetails() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.166:8081/api/Application/GetPatientById?PatientId=${widget.patientId}'),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        String firstName = data['first_name'] ?? 'Unknown';
        String lastName = data['middleName'] ?? 'Unknown';
        name = '$firstName $lastName'; // Concatenate first name and last name
        fatherName=data['father_spouse_name'] ?? 'Unknown';
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
      fatherName='Failed to load';
      sex = 'Failed to load';
      patientId = 'Failed to load';
    });
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
              SizedBox(height: 16.0), // Padding from the top
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.teal,
                  child: Text(
                    name.isNotEmpty ? name[0] : 'R',
                    style: TextStyle(fontSize: 40, color: Colors.white),
                  ),
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
                  onPressed: () {},
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
                onTap: () {
                                  },
              ),
              ListTile(
                leading: Icon(Icons.health_and_safety),
                title: Text('My Health Records'),
                onTap: () {},
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => FeedbackScreen()),
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
                onTap: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => PatientLogin()),
                  );
                },
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

