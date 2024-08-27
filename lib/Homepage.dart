import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:bottom_navigation/PatientLogin.dart';
import 'package:bottom_navigation/colors.dart';
import 'view_all_doctors.dart';
import 'patient_registration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'doctor_list_screen.dart';
import 'app_config.dart';
import 'doctor_online.dart';

// import 'DoctorListScreen.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    Container(child: Center(child: Text('Appointments'))),
    PatientLogin(), // Add PatientLogin screen to the list
    PatientRegistrationForm(),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.green, // Set the background color to green
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
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
          selectedItemColor: Colors.green, // Selected item color
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<SuperSpecialty> _superSpecialties = [];
  List<Specialty> _specialties = [];

  @override
  void initState() {
    super.initState();
    fetchSuperSpecialties().then((data) {
      setState(() {
        _superSpecialties = data;
      });
    });
    fetchSpecialties().then((data1) {
      setState(() {
        _specialties = data1;
      });
    });
  }
  Future<List<SuperSpecialty>> fetchSuperSpecialties() async {
    var uri = Uri.parse('${AppConfig.apiUrl1}${AppConfig.superspecialityEndpoint}');
    var response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      data.forEach((item) {
        print("SuperSpecialty ID: ${item['id']}");  // Print the ID to check it's not 0
      });
      return data.map((item) => SuperSpecialty.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load super specialties');
    }
  }

  Future<List<Specialty>> fetchSpecialties() async {


    var uri = Uri.parse('${AppConfig.apiUrl1}${AppConfig.specialityEndpoint}');
    var response = await http.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      data.forEach((item) {
        print("Specialty ID: ${item['id']}");  // Print the ID to check it's not 0
      });
      return data.map((item) => Specialty.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load specialties');
    }
  }

  Uint8List _convertBase64ToImage(String base64String) {
    try {
      Uint8List bytes = base64Decode(base64String);
      if (bytes.isEmpty) throw Exception('Empty byte array');
      return bytes;
    } catch (e) {
      print('Error decoding base64 string: $e');
      return Uint8List(0);
    }
  }
  Future<List<Doctor>> fetchDoctorsBySpecialization(int specializationId) async {
    final url = Uri.parse('${AppConfig.apiUrl1}${AppConfig.getDoctorsBySpecializationEndpoint}?specialization_id=$specializationId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => Doctor.fromJson(item)).toList();
      } else {
        print('Failed to load doctors with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      throw Exception('Failed to load doctors');
    }
  }



  void _onSpecialtyTap(int specializationId) async {
    print('Specialization ID tapped: $specializationId');  // Ensure this prints the correct ID

    try {
      List<Doctor> doctors = await fetchDoctorsBySpecialization(specializationId);
      if (doctors.isEmpty) {
        print('Doctors not found for specialization ID: $specializationId');
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DoctorListScreen(doctors: doctors)),
        );
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching doctors: $e'),
        ),
      );
    }
  }




  // Future<void> sendSpecializationId(int specializationId) async {
  //   final url = Uri.parse('http://192.168.1.107:8081/api/Application/SendSpecializationId');
  //   final headers = {"Content-Type": "application/json"};
  //   final body = json.encode({'specializationId': specializationId});
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: headers,
  //       body: body,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('Specialization ID sent successfully');
  //     } else {
  //       print('Failed to send specialization ID. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error sending specialization ID: $e');
  //   }
  // }
  //
  // void _onSpecialtyTap(int specializationId, String specializationName) {
  //   if (specializationId == 0) {
  //     print('Invalid specialization ID');
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid specialization ID')));
  //     return;
  //   }
  //
  //   sendSpecializationId(specializationId);
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => DoctorScreen(
  //         specializationId: specializationId.toString(),
  //         specializationName: specializationName,
  //       ),
  //     ),
  //   );
  // }

  List<Map<String, dynamic>> _sections = [
    {
      'type': 'Top Doctor',
      'widget': DoctorCard(
        name: 'Dr. Anil Bhat',
        specialty: 'Cardiology',
        rating: 4.5,
        patientStories: 30.0,
        imagePath: 'assets/doctors/dranilbhat.jpg',
        operations: 'Cardiac Surgery, Heart Transplant',
        degrees: 'MBBS, MD, DM Cardiology',
      ),
    },
    {
      'type': 'Top Doctor',
      'widget': DoctorCard(
        name: 'Dr. Sanjeev Rohatgi',
        specialty: 'Ophthalmology',
        rating: 4.5,
        patientStories: 20.0,
        imagePath: 'assets/doctors/SanjeevRohatgi.jpg',
        operations: 'ENT Surgery, Cochlear Implant',
        degrees: 'MBBS, MS-ENT',
      ),
    },
    {
      'type': 'Top Doctor',
      'widget': DoctorCard(
        name: 'Dr. Arun Kumar',
        specialty: 'General Medicine',
        rating: 4.5,
        patientStories: 34.0,
        imagePath: 'assets/doctors/arunkumar.jpg',
        operations: 'General Checkup, Diabetes Management',
        degrees: 'MBBS, MD General Medicine',
      ),
    },
    {
      'type': 'Top Doctor',
      'widget': DoctorCard(
        name: 'Dr. Mahesh Gupta',
        specialty: 'General Surgery',
        rating: 4.5,
        patientStories: 23.0,
        imagePath: 'assets/doctors/MaheshGupta.jpg',
        operations: 'General Checkup',
        degrees: 'MS-Gen-Surgery',
      ),
    },

    {
      'type': 'Special Offer',
      'widget': OfferCard(
        title: '20% OFF',
        description: 'Cardiology',
      ),
    },
    {
      'type': 'Special Offer',
      'widget': OfferCard(
        title: '30% OFF',
        description: 'Full Body Checkup',
      ),
    },
    {
      'type': 'Special Offer',
      'widget': OfferCard(
        title: '20% OFF',
        description: 'Colonoscopy',
      ),
    },
    {
      'type': 'Special Offer',
      'widget': OfferCard(
        title: '30% OFF',
        description: 'Ophthalmology',
      ),
    },


    {
      'type': 'Services',
      'widget': Services(
        description: 'Wards & Room',
      ),
    },
    {
      'type': 'Services',
      'widget': Services(
        description: 'Lab Tests ',
      ),
    },
    {
      'type': 'Services',
      'widget': Services(
        description: 'Emergency',
      ),
    },
    {
      'type': 'Services',
      'widget': Services(
        description: 'Pharma',
      ),
    },
    {
      'type': 'healthcheckup',
      'widget': HealthCheckup(
        description: 'Hapur',
      ),
    },
    {
      'type': 'healthcheckup',
      'widget': HealthCheckup(
        description: 'Mandhana ',
      ),
    },
    {
      'type': 'healthcheckup',
      'widget': HealthCheckup(
        description: 'Lakhanpur',
      ),
    },
    {
      'type': 'healthcheckup',
      'widget': HealthCheckup(
        description: 'Noida',
      ),
    },
  ];

  List<Map<String, dynamic>> get _filteredSections {
    if (_searchQuery.isEmpty) {
      return _sections;
    } else {
      return _sections
          .where((section) =>
      section['type'].toString().toLowerCase().contains(
          _searchQuery.toLowerCase()) ||
          (section['widget'] is DoctorCard &&
              (section['widget'] as DoctorCard)
                  .name
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) ||
          (section['widget'] is OfferCard &&
              (section['widget'] as OfferCard)
                  .description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) ||

          (section['widget'] is Services &&
              (section['widget'] as Services)
                  .description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) ||
          (section['widget'] is HealthCheckup &&
              (section['widget'] as HealthCheckup)
                  .description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0),
              // Adjust the top padding value as needed
              child: Image.asset(
                'assets/ramalogoapp.png', // Update the path to your logo asset
                height: 60,
                width: 120,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: SizedBox(
                    width: 34,
                    height: 34,
                    child: Image.asset('assets/ambulance.png'),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return Container(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.15,
                          width: MediaQuery
                              .of(context)
                              .size
                              .height * 0.5,
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
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Call,',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' Ambulance',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 18.0,
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
                                  // Background color
                                  foregroundColor: Colors.white, // Text color
                                ),
                                child: Text(
                                  '7877775530',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                onPressed: () {
                                  _launchDialer('tel:7877775530');
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
                    width: 34,
                    height: 34,
                    child: Image.asset('assets/offer.png'),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),

              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by Doctor, Speciality, Symptoms',
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMenuButton(
                      'Book Appointment',
                      'assets/icon/calendar.png',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ViewAllDoctors(),
                              ),
                            );// Add your navigation or action code here
                      },

                    ),
                    // SizedBox(width: 10.0),
                    _buildMenuButton(
                      'Book Video Consult',
                      'assets/icon/video.png',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => doctoronline(),
                              ),
                            );// // Add your navigation or action code here
                      },
                      //
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMenuButton(
                      '   Test  &  Services   ',
                      'assets/icon/test.png',
                          () {
                        // Add your navigation or action code here
                      },

                    ),
                    // SizedBox(width: 10.0),
                    _buildMenuButton(
                      '  Health  CheckUps ',
                      'assets/icon/heart.png',
                          () {
                        // Add your navigation or action code here
                      },

                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.0),
          // Rest of your code remains unchanged
          // Section 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Our Medical Experts',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewAllDoctors()),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    //   SizedBox(width: 4.0), // Adjust the width as needed
                    //   Icon(
                    //     Icons.arrow_forward_sharp,
                    //     color: Colors.teal,
                    //   ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Container(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filteredSections
                  .where((section) => section['type'] == 'Top Doctor')
                  .map<Widget>((section) =>
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: section['widget'],
                  ))
                  .toList(),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Special Offers',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filteredSections
                  .where((section) => section['type'] == 'Special Offer')
                  .map<Widget>((section) =>
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: section['widget'],
                  ))
                  .toList(),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Super Specialties',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _superSpecialties.map<Widget>((specialty) {
                return GestureDetector(
                  onTap: () {
                    print('Tapped Specialty with ID: ${specialty.specializationId}');  // Debug the ID being tapped
                    _onSpecialtyTap(specialty.specializationId);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (specialty.iconBase64.isNotEmpty)
                          Image.memory(
                            _convertBase64ToImage(specialty.iconBase64),
                            height: 60,
                            width: 60,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error building image: $error');
                              return Icon(Icons.broken_image, size: 60);
                            },
                          )
                        else
                          Icon(Icons.image_not_supported, size: 60),
                        Text(specialty.specialization),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16.0),
          Text(
            'Specialties',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _specialties.map<Widget>((specialty) {
                return GestureDetector(
                  onTap: () => _onSpecialtyTap(specialty.specializationId),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        if (specialty.iconBase64.isNotEmpty)
                          Image.memory(
                            _convertBase64ToImage(specialty.iconBase64),
                            height: 60,
                            width: 60,
                            errorBuilder: (context, error, stackTrace) {
                              print('Error building image: $error');
                              return Icon(Icons.broken_image, size: 60);
                            },
                          )
                        else
                          Icon(Icons.image_not_supported, size: 60),
                        Text(specialty.specialization),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16.0),
          // Section 5
          Text(
            'Services',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filteredSections
                  .where((section) => section['type'] == 'Services')
                  .map<Widget>((section) =>
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: section['widget'],
                  ))
                  .toList(),
            ),
          ),
          SizedBox(height: 16.0),
          // Section 6
          Text(
            'Health Checkup',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filteredSections
                  .where((section) => section['type'] == 'healthcheckup')
                  .map<Widget>((section) =>
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: HealthCheckup(
                      description: section['widget'].description,
                    ),
                  ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, String iconPath,
      VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(16.0),
        backgroundColor: AppColors.primaryColor,
        shadowColor: Colors.grey.withOpacity(0.5),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, height: 20, width: 20),
          SizedBox(width: 4.0),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}


// Doctor Card Widget
class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String imagePath;
  final String operations;
  final String degrees;
  final double patientStories;

  const DoctorCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.imagePath,
    required this.operations,
    required this.degrees,
    required this.patientStories,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              title: Center(child: Text(name)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(imagePath),
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Specialty:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(specialty),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(rating.toString()),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Operations:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(operations),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Degrees:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(degrees),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Patient Stories:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(patientStories.toString()),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PatientRegistrationForm(),
                          ),
                        );
                      },
                      child: Text('Book Appointment'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, // Foreground color
                        backgroundColor: Colors.teal, // Background color
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        width: 150,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20), // Curved sides
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey, // Border color
                  width: 2.0, // Border width
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Curved top
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Curved top
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 140,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center the text
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2.0),
                  Text(specialty),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Offer Card Widget
class OfferCard extends StatelessWidget {
  final String title;
  final String description;

  OfferCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            Text(description),
          ],
        ),
      ),
    );
  }
}
Widget _buildDepartmentItem(String assetPath, String departmentName) {
  return Column(
    children: [
      Image.asset(
        assetPath,
        height: 60,
        width: 60,
      ),
      Text(departmentName),
    ],
  );
}
class SuperSpecialty {
  final int specializationId;
  final String specialization;
  final String iconBase64;

  SuperSpecialty({
    required this.specializationId,
    required this.specialization,
    required this.iconBase64,
  });

  factory SuperSpecialty.fromJson(Map<String, dynamic> json) {
    return SuperSpecialty(
      specializationId: json['specializationId'] ?? 0,  // Ensure this maps to the correct field
      specialization: json['specialization'] ?? '',
      iconBase64: json['iconBase64'] ?? '',
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

class DoctorScreen extends StatelessWidget {
  final String specializationId;
  final String specializationName;

  DoctorScreen({
    required this.specializationId,
    required this.specializationName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(specializationName),
      ),
      body: Center(
        child: Text('Doctors for $specializationName'),
      ),
    );
  }
}
// Services Widget
class Services extends StatelessWidget {
  final String description;

  Services({
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              description,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// Health Checkup Widget
class HealthCheckup extends StatelessWidget {
  final String description;

  // final String tests;
  // final String preparation;

  HealthCheckup({
    required this.description,
    // required this.tests,
    // required this.preparation,
  });


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              description,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.0),
            // Text('Tests: $tests'),
            // Text('Preparation: $preparation'),
          ],
        ),
      ),
    );
  }
}
Future<void> _launchDialer(String number) async {
  final Uri url = Uri(scheme: 'tel', path: number);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

Widget _buildMenuButton(String title, String iconPath, VoidCallback onPressed, {Color color = Colors.red}) {
  return Expanded(
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Set the background color
        padding: EdgeInsets.symmetric(vertical: 16.0),
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          Image.asset(
            iconPath,
            height: 40.0,
            width: 40.0,
          ),
          SizedBox(height: 8.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white, // Set the text color
              fontSize: 16.0,
            ),
          ),
        ],
      ),
    ),
  );
}
