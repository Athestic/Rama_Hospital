
import 'package:global/Healthpackages.dart';
import 'package:global/Medicine.dart';
import 'package:global/getappointmentandservices.dart';
import 'package:global/feedback.dart';
import 'package:global/laborderlist.dart';
import 'package:global/labtest.dart';
import 'package:global/pharmaorderlist.dart';
import 'healthrecord.dart';
import 'patient_profile.dart';
import 'package:flutter/material.dart';
import 'PatientLogin.dart';
import 'colors.dart';
import 'patient_registration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'getspecialization.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'about.dart';
import 'termsandcondition.dart';
import 'Privacy.dart';
import 'app_config.dart';
import 'patient_registration_other.dart';
import 'patient_registration_lab.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  String? patientId;
  String? patientImage; // Store patient image
  String? patientName = "Hello, User"; // Default patient name if not logged in


  // Method to get the correct widget based on the selected index
  Widget get _currentPage {
    switch (_selectedIndex) {
      case 0:
        return PatientLogin(); // Profile page
      case 1:
        return HomePage(); // Home page
      case 2:
        return BookingAppointmentPage(patientId: patientId ?? ''); // Appointment page
      default:
        return HomePage(); // Default to HomePage
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginAndFetchPatientData(); // Fetch patient data if logged in
    _getPatientId();
  }

  Future<void> _getPatientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    patientId = prefs.getString('patientId'); // Get the saved patientId
    setState(() {}); // Update the UI after fetching the patientId
  }

  // Method to check login and fetch patient data
  Future<void> _checkLoginAndFetchPatientData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getString('patientId');
    final token = prefs.getString('jwtToken');

    if (patientId != null && token != null) {
      // Patient is logged in, fetch patient data
      await _fetchPatientData(patientId, token);
    } else {
      // Patient not logged in, set default values
      setState(() {
        patientImage = null; // No image, use default image
        patientName = "Hello, User";
      });
    }
  }


  Future<void> _fetchPatientData(String patientId, String token) async {
    try {
      // Construct the full URL using AppConfig
      final url = Uri.parse('${AppConfig.apiUrl1}${AppConfig.getPatientByIdEndpoint}?PatientId=$patientId');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Add authentication token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Update the patient image and name immediately in the drawer
        setState(() {
          patientImage = data['patientImage']?.isNotEmpty == true ? data['patientImage'] : null;
          patientName = "Hello, ${data['first_name'] ?? 'User'}";
        });

        // Store the data locally in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('patientImage', data['patientImage'] ?? '');
        await prefs.setString('patientName', data['first_name'] ?? 'User');
      } else {
        print('Failed to load patient data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching patient data: $e');
    }
  }


  // Function to handle tab navigation in the BottomNavigationBar
  void _onItemTapped(int index) async {
    if (index == 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getString('patientId');
      final token = prefs.getString('jwtToken');

      if (patientId != null && token != null) {
        // If the user is logged in, navigate to the profile screen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => PatientProfileScreen(patientId: patientId)),
        );
      } else {
        // If the user is not logged in, navigate to the login screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PatientLogin()),
        );
      }
    } else {
      // For Home and Appointment tabs
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return OrientationBuilder(
        builder: (context, orientation) {
          // Determine if the orientation is landscape
          bool isLandscape = orientation == Orientation.landscape;
          return Scaffold(


            appBar: _selectedIndex == 1
                ? AppBar(
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (BuildContext context) {
                      return IconButton(
                        icon: CircleAvatar(
                          radius: isLandscape ? 15 : 20, // Smaller radius in landscape
                          backgroundImage: patientImage != null
                              ? MemoryImage(base64Decode(patientImage!))
                              : AssetImage('assets/logo/person.jpeg') as ImageProvider,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Image.asset(
                      'assets/logo/mainlogo.png',
                      height: isLandscape ? screenHeight * 0.3 : screenHeight * 0.5, // Adjust height
                      width: isLandscape ? screenWidth * 0.2 : screenWidth * 0.3, // Adjust width
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: SizedBox(
                          width: isLandscape ? screenWidth * 0.08 : screenWidth * 0.1,
                          height: isLandscape ? screenHeight * 0.08 : screenHeight * 0.1,
                          child: Image.asset('assets/ambulance.png'),
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return Container(
                                height: screenHeight * (isLandscape ? 0.40 : 0.18),
                                width: screenWidth * (isLandscape ? 1 : 1),
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: 'Emergency ',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Call,',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' Ambulance',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                      child: Text(
                                        '7877775530',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.05,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      onPressed: () {
                                        _launchDialer(context, '7877775530');
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: SizedBox(
                          width: isLandscape ? screenWidth * 0.08 : screenWidth * 0.1,
                          height: isLandscape ? screenHeight * 0.08 : screenHeight * 0.1,
                          child: Image.asset('assets/offer.png'),
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            )
                : null,
              drawer: Drawer(
                width: isLandscape ? 250 : 270, // Adjust drawer width for landscape
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: isLandscape ? 30 : 40, // Adjust avatar size for landscape
                              backgroundImage: patientImage != null
                                  ? MemoryImage(base64Decode(patientImage!))
                                  : AssetImage('assets/logo/person.jpeg') as ImageProvider,
                            ),
                            SizedBox(height: isLandscape ? 10 : 15),
                            Text(
                              patientName ?? 'Hello, User',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: isLandscape ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),


              // My Account section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 6.0),
                      child: Text(
                        'My Account',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              PatientLogin()),
                        );
                      },
                    ),
                    Divider(),
                    // Second Section Header
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 1.0, horizontal: 3.0),
                      child: Text(
                        'My Services',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.calendar_today),
                      title: Text('My Appointments'),
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences
                            .getInstance();
                        final patientId = prefs.getString('patientId');

                        if (patientId != null) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                BookingAppointmentPage(patientId: patientId)),
                          );
                        } else {
                          _showLoginDialog(
                              context); // Show login dialog if not logged in
                        }
                      },
                    ),

                    ListTile(
                      leading: Icon(Icons.health_and_safety),
                      title: Text('My Health Records'),
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences
                            .getInstance();
                        final patientId = prefs.getString('patientId');
                        final token = prefs.getString('jwtToken');

                        if (patientId != null && token != null) {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                HealthRecordsScreen(patientId: patientId)),
                          );
                        } else {
                          _showLoginDialog(context); // Show login dialog
                        }
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.add_circle_outline),
                      title: Text('Book an Appointment'),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SpecializationsScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.medical_information),
                      title: Text('Pharmacy Order'),
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences
                            .getInstance();
                        final patientId = prefs.getString('patientId');

                        if (patientId != null) {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                PharmacyOrderList(patientId: patientId)),
                          );
                        } else {
                          _showLoginDialog(
                              context); // Show login dialog if not logged in
                        }
                      },
                    ),

                    ListTile(
                      leading: Icon(Icons.medical_information),
                      title: Text('Lab Order'),
                      onTap: () async {
                        SharedPreferences prefs = await SharedPreferences
                            .getInstance();
                        final patientId = prefs.getString('patientId');

                        if (patientId != null) {
                          Navigator.pop(context); // Close the drawer
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>
                                Laborderlist(patientId: patientId)),
                          );
                        } else {
                          _showLoginDialog(
                              context); // Show login dialog if not logged in
                        }
                      },
                    ),

                    Divider(),
                    // Other Information section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 6.0),
                      child: Text(
                        'Other Information',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.privacy_tip),
                      title: Text('Privacy Policy'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                        );
                      },
                    ),

                    ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('About Us'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => About()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.rule),
                      title: Text('Terms and Conditions'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              TermsAndConditionsScreen()),
                        );
                      },
                    ),

                    Divider(),
                    ListTile(
                      leading: Icon(Icons.feedback_outlined),
                      title: Text('Feedback'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              FeedbackScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.question_answer),
                      title: Text('FAQs'),
                      onTap: () {},
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout'),
                      onTap: () async {
                        // Clear shared preferences to log out the user
                        SharedPreferences prefs = await SharedPreferences
                            .getInstance();
                        await prefs.clear();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              PatientLogin()),
                              (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            body: _currentPage, // Display the selected page
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.schedule),
                  label: 'Appointments',
                ),
              ],
              selectedItemColor: AppColors.primaryColor,
              unselectedItemColor: Colors.grey,
              selectedFontSize: 14,
              unselectedFontSize: 14,
              selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
              backgroundColor: Colors.white,
            ),
          );
        }
    );
  }
}


  void _showLoginDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Not Logged In'),
        content: Text('Please log in to view your health records.'),
        actions: <Widget>[
          TextButton(
            child: Text('Log In'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PatientLogin()),
              );
            },
          ),
        ],
      );
    },
  );
}

void _launchDialer(BuildContext context, String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );

  if (await canLaunch(launchUri.toString())) {
    await launch(launchUri.toString());
  } else {
    // Show an error message if unable to launch the dialer
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Get screen dimensions for responsiveness
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;

        return AlertDialog(
          title: Text('Error'),
          content: Container(
            width: screenWidth * 0.8, // 80% of screen width
            height: screenHeight * 0.035, // 10% of screen height
            child: Center(
              child: Text('Could not launch the dialer.'),
            ),
          ),
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
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  List<String> _videoIds = [
    'RWFuFD5X2W0',
    'mBOHXb1toK8',
    'egpvnmn03b8',
    'nmrhuACA2k4',
    'Kb7vHrB6V7Q',
    '0vrDk36i-8Q',
    'OwdqlveqTtA'
  ];
  late YoutubePlayerController _youtubeController;
  bool _isVideoPlayerVisible = false; // New flag to track visibility


  @override
  void initState() {
    super.initState();

    _youtubeController = YoutubePlayerController(
      initialVideoId: _videoIds[0],
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _youtubeController.unMute();
      _youtubeController.setVolume(100);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  Future<bool> _isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final patientId = prefs.getString('patientId');
    return patientId != null; // true if logged in, false otherwise
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 300),
            child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Login Required",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Sorry, you are not logged in. Please log in to continue.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "😔", // Emoji
                        style: TextStyle(fontSize: 40),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10,
                                  vertical: 5),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PatientLogin()),
                              );
                            },
                            child: Text("Login",
                              style: TextStyle(fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                        PatientRegistrationForm2()),
                                  );
                                },
                                child: Text("Register",
                                  style: TextStyle(fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]
                )),
          ),
        );
      },
    );
  }


  void _showLoginRequiredDialog1() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 300),
            child: Container(
                padding: EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Login Required",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Sorry, you are not logged in. Please log in to continue.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "😔", // Emoji
                        style: TextStyle(fontSize: 40),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10,
                                  vertical: 5),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PatientLogin()),
                              );
                            },
                            child: Text("Login",
                              style: TextStyle(fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) =>
                                        PatientRegistrationForm1()),
                                  );
                                },
                                child: Text("Register",
                                  style: TextStyle(fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]
                )),
          ),
        );
      },
    );
  }

  void _navigateToScreen(Widget screen, {bool requiresLogin = true}) async {
    if (requiresLogin) {
      bool loggedIn = await _isLoggedIn();
      if (loggedIn) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      } else {
        _showLoginRequiredDialog();
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Our Services',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontFamily: 'Poppins',
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 0.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildServiceCard(
                      titleLine1: 'Doctor',
                      titleLine2: 'Appointment',
                      subtitle: 'Book Now',
                      imageAsset: 'assets/homeCon/doctoricon.png',
                      backgroundColor: Color(0xFFE0F7FA),
                      onPressedSubtitle: () {
                        // No login required
                        _navigateToScreen(
                            SpecializationsScreen(), requiresLogin: false);
                      },
                    ),

                    SizedBox(width: 16.0),
                    _buildServiceCard(
                      titleLine1: 'Lab ',
                      titleLine2: 'Test',
                      subtitle: 'Book Test',
                      imageAsset: 'assets/homeCon/img_1.png',
                      backgroundColor: Color(0xFFE0F7FA),
                      onPressedSubtitle: () {
                        // Login required for Lab Test
                        _navigateToScreen(LabTestBooking());
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildServiceCard(
                      titleLine1: 'Buy',
                      titleLine2: 'Medicines',
                      subtitle: 'Buy',
                      imageAsset: 'assets/homeCon/Capsule & Pill.png',
                      backgroundColor: Color(0xFFFFF3E0),
                      onPressedSubtitle: () {
                        // Login required for Buy Medicines
                        _navigateToScreen(MedicinePage());
                      },
                    ),
                    SizedBox(width: 16.0),
                    _buildServiceCard(
                      titleLine1: 'Health',
                      titleLine2: 'Package',
                      subtitle: 'Explore',
                      imageAsset: 'assets/homeCon/Stethoscope.png',
                      backgroundColor: Color(0xFFFFF3E0),
                      onPressedSubtitle: () {
                        // No login required
                        _navigateToScreen(
                            HealthPackages(), requiresLogin: false);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),


          SizedBox(height: 16.0),

          Text(
            'Popular Services',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 150,

            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildImageCard(
                      'assets/specialities/Diabetes.png'),
                  _buildImageCard(
                      'assets/specialities/Silver.png'),
                  _buildImageCard(
                      'assets/specialities/Womens.png'),
                  _buildImageCard(
                      'assets/specialities/speacialoffer.jpeg'),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Health Tips',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontFamily: 'Poppins',
            ),
          ),
         // Add a line divider under the title
          SizedBox(height: 8.0),

// Horizontal scroll for video thumbnails
          Container(
            height: 120.0, // Slightly increase height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _videoIds.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _youtubeController.load(_videoIds[index]);
                      _isVideoPlayerVisible = true;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    width: 140.0,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.teal, width: 2.0),  // Change border color and width
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),  // Adds depth to thumbnails
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        'https://img.youtube.com/vi/${_videoIds[index]}/0.jpg',
                        height: 120.0,
                        width: 150.0,
                        fit: BoxFit.cover,  // Ensures the thumbnail fills the container
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10.0),

// Video Player, only visible when a video is selected
          _isVideoPlayerVisible
              ? Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.primaryColor, // Match with the overall color theme
                width: 2.5,  // Thicker border for focus
              ),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 6,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 13 / 7,
              child: YoutubePlayer(
                controller: _youtubeController,
                showVideoProgressIndicator: true,
                onReady: () {
                  _youtubeController.unMute();
                  _youtubeController.setVolume(100);
                },
                onEnded: (metaData) {
                  print('Video has ended');
                },
              ),
            ),
          )
              : Container(),
          SizedBox(height: 16.0),


        ],
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Container(
      width: 360,
      // Set the desired width
      height: 350,
      // Adjust the height as necessary to match the aspect ratio
      margin: EdgeInsets.only(right: 16.0),
      // Adds space between cards
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        // Rounded corners for the image
        child: Column(
          children: [
            Container(
              height: 150,
              // Adjust the height to ensure the image is fully displayed
              width: 360,
              // Set the desired width
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover, // Ensure the image fills the container
              ),
            ),
            // SizedBox(height: 8.0),
            // Text(
            //   title,
            //   style: TextStyle(fontSize: 14.0),
            //   textAlign: TextAlign.center, // Align text to center if desired
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required String titleLine1,
    required String titleLine2,
    required String subtitle,
    required String imageAsset,
    required Color backgroundColor,
    required VoidCallback onPressedSubtitle,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressedSubtitle, // Trigger navigation on card tap
        child: Container(
          padding: EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and image row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleLine1,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      Text(
                        titleLine2,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    imageAsset,
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
              SizedBox(height: 4.0),
              // Subtitle button row
              SizedBox(
                width: 100.0,
                height: 25.0,
                child: ElevatedButton(
                  onPressed: onPressedSubtitle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.0,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



  class Specialty {
  final int specializationId;
  final String specialization;
  final String iconBase64;

  Specialty({
    required this.specializationId,
    required this.specialization,
    required this.iconBase64,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      specializationId: json['specializationId'] ?? 0,  // Ensure this maps to the correct field
      specialization: json['specialization'] ?? '',
      iconBase64: json['iconBase64'] ?? '',
    );
  }
}

