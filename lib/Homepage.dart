import 'package:bottom_navigation/PatientLogin.dart';
import 'package:bottom_navigation/colors.dart';
import 'package:flutter/material.dart';
import 'view_all_doctors.dart';
import 'patient_registration.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bookappointment.dart';


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

  List<Map<String, dynamic>> _sections = [
    {
      'type': 'Top Doctor',
      'widget': DoctorCard(
        name: 'Dr. Anil Bhat',
        specialty: 'Cardiology',
        rating: 4.5,
        patientStories:30.0,
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
        patientStories:20.0,
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
        patientStories:34.0,
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
        patientStories:23.0,
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
      'type': 'Super_Specialties',
      'widget': SuperSpecialties(
        description: 'Cardiology',
        imagePath: 'assets/cardiology.jpg',
        details: 'Cardiology deals with disorders of the heart and blood vessels.',
        bestDoctor: 'Dr. Anil Bhat',
        call:'7877775530',
        iconPath: 'assets/super_specialities/Cardiology.png',
      ),
    },
    {
      'type': 'Super_Specialties',
      'widget': SuperSpecialties(
        description: 'Gastroenterology',
        imagePath: 'assets/super_specialities/Gastro.jpg',
        details: 'A gastroenterologist is a specialist in gastrointestinal diseases. Gastroenterologists treat all the organs in your digestive system.',
        bestDoctor: 'Dr. Anil Bhat',
        call:'7877775530',
        iconPath: 'assets/super_specialities/Gastroenterology.png',
      ),
    },
    {
      'type': 'Super_Specialties',
      'widget': SuperSpecialties(
        description: 'Nephrology',
        imagePath: 'assets/super_specialities/nephrology.jpg',
        details: 'Nephrology is a branch of internal medicine that deals with kidney diseases and disorders.',
        bestDoctor: 'Dr. DK Sinha',
        call:'7877775530',
        iconPath: 'assets/super_specialities/Nephrology.png',
      ),
    },
    {
      'type': 'Super_Specialties',
      'widget': SuperSpecialties(
        description: 'Neurology',
        imagePath: 'assets/super_specialities/neurology.jpeg',
        details: 'A neurologist is a medical doctor who diagnoses, treats and manages disorders of the brain and nervous system (brain, spinal cord and nerves).',
        bestDoctor: 'Dr. Navneet Kumar',
        call:'7877775530',
        iconPath: 'assets/super_specialities/Orthopaedics.png',
      ),
    },
    {
      'type': 'Specialties',
      'widget': Specialties(
        description: 'Cardiology',
        imagePath: 'assets/cardiology.jpg',
        details: 'Cardiology deals with disorders of the heart and blood vessels.',
        bestDoctor: 'Dr. Anil Bhat',
        call:'7877775530',
        iconPath: 'assets/specialities/Dental.png',
      ),
    },
    {
      'type': 'Specialties',
      'widget': Specialties(
        description: 'Urology',
        imagePath: 'assets/Urology.jpg',
        details: 'Urology focuses on surgical and medical diseases of the urinary-tract system.',
        bestDoctor: 'Dr. R K Singh',
        call:'7877775530',
        iconPath: 'assets/specialities/Haematology.png',
      ),
    },
    {
      'type': 'Specialties',
      'widget': Specialties(
        description: 'Colonoscopy',
        imagePath: 'assets/Colonoscopy.jpg',
        details: 'Colonoscopy is an endoscopic examination of the large bowel and the distal part of the small bowel.',
        bestDoctor: 'Dr. Arun Kumar',
        call:'7877775530',
        iconPath: 'assets/specialities/Pulmonology.png',
      ),
    },
    {
      'type': 'Specialties',
      'widget': Specialties(
        description: 'Ophthalmology',
        imagePath: 'assets/Ophthalmology.jpg',
        details: 'Ophthalmology deals with the anatomy, physiology, and diseases of the eye.',
        bestDoctor: 'Dr. Anshu Sharma',
        call:'7877775530',
        iconPath: 'assets/specialities/Urology.png',
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
          (section['widget'] is SuperSpecialties &&
              (section['widget'] as SuperSpecialties)
                  .description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase())) ||
          (section['widget'] is Specialties &&
              (section['widget'] as Specialties)
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
              padding: const EdgeInsets.only(top: 15.0), // Adjust the top padding value as needed
              child: Image.asset(
                'assets/Ramalogo.jpeg', // Update the path to your logo asset
                height: 100,
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
                              height: MediaQuery.of(context).size.height * 0.2,
                              width: MediaQuery.of(context).size.height * 0.5,// Set height to 40% of screen height
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
                                      backgroundColor: Colors.red, // Background color
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
                                      makePhoneCall('tel:7877775530');
                                        },
                                      ),
                                    ],

                          )
                              );
                      },
                    );
                  }


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
          // Search Bar with Shadow
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
                    offset: Offset(0, 3), // changes position of shadow
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
          // "Your Health Matters" banner
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Health Matters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        'Explore Advice, Health Tips & More',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                // Padding(
                  // padding: EdgeInsets.zero,
                Image.asset(
                    'assets/ban_doc.png', // Update the path to your image asset
                    height: 80,


                  ),
                // ),
              ],
            ),
          ),

          SizedBox(height: 16.0),

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
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
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
          SizedBox(height: 40),
          // Section 2
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
          // Section 3
          Text(
            'Super Specialties',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filteredSections
                  .where((section) => section['type'] == 'Super_Specialties')
                  .map<Widget>((section) =>
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: section['widget'],
                  ))
                  .toList(),
            ),
          ),
          SizedBox(height: 16.0),
          // Section 4
          Text(
            'Specialties',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Container(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filteredSections
                  .where((section) => section['type'] == 'Specialties')
                  .map<Widget>((section) =>
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: section['widget'],
                  ))
                  .toList(),
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
                      // tests: section['widget'].tests,
                      // preparation: section['widget'].preparation,
                    ),
                  ))
                  .toList(),
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
    //   onTap: () {
    //     showDialog(
    //       context: context,
    //       builder: (BuildContext context)
          // {
            // return AlertDialog(
            //   title: Center(child: Text(name)),
            //   content: SingleChildScrollView(
            //     child: Column(
            //       mainAxisSize: MainAxisSize.min,
            //       children: [
            //         ClipRRect(
            //           borderRadius: BorderRadius.circular(10),
            //           child: Image.asset(imagePath),
            //         ),
            //         SizedBox(height: 15),
            //         Center(child: Text('Specialty: $specialty')),
            //         Center(child: Text('Rating: $rating')),
            //         Center(child: Text('Operations: $operations')),
            //         Center(child: Text('Degrees: $degrees')),
            //         Center(child: Text('Patient Stories: $patientStories')),
            //         SizedBox(height: 8),
            //         ElevatedButton(
            //           onPressed: () {
            //             Navigator.of(context).pop();
            //             Navigator.push(
            //               context,
            //               MaterialPageRoute(
            //                 builder: (context) => PatientRegistrationForm(),
            //               ),
            //             );
            //           },
            //           child: Text('Book Appointment'),
            //           style: ElevatedButton.styleFrom(
            //             foregroundColor: Colors.white, // Foreground color
            //             backgroundColor: Colors.teal, // Background color
            //           ),
            //         ),
            //         SizedBox(height: 8),
            //         ElevatedButton(
            //           onPressed: () {
            //             Navigator.of(context).pop();
            //           },
            //           child: Text('Close'),
            //           style: ElevatedButton.styleFrom(
            //             foregroundColor: Colors.white, // Foreground color
            //             backgroundColor: Colors.grey, // Background color
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // );
         // },
        //);
      //},
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

// Super Specialties Widget
class SuperSpecialties extends StatelessWidget {
  final String description;
  final String imagePath;
  final String details;
  final String bestDoctor;
  final String iconPath; // Changed to String to handle custom icon path
  final String call;

  SuperSpecialties({
    required this.description,
    required this.imagePath,
    required this.details,
    required this.bestDoctor,
    required this.iconPath,
    required this.call,
  });

  Future<void> _launchDialer(String number) async {
    final url = 'tel:$number';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(imagePath),
                    ),
                    SizedBox(height: 15),
                    Center(child: Text('Description: $description')),
                    Center(child: Text('Details: $details')),
                    Center(child: Text('Best Doctor: $bestDoctor')),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _launchDialer(call);
                        },
                        child: Text('Call Now: $call'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, // Foreground color
                          backgroundColor: Colors.blue, // Background color
                        ),
                      ),
                    ),
                    // SizedBox(height: 8),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.of(context).pop();
                    //   },
                    //   child: Text('Close'),
                    //   style: ElevatedButton.styleFrom(
                    //     foregroundColor: Colors.white, // Foreground color
                    //     backgroundColor: Colors.grey, // Background color
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column( // Changed from Row to Column
            children: [
              Image.asset(
                iconPath,
                height: 24,
                width: 24,
              ),
              SizedBox(height: 8.0), // Changed from width to height
              Text(
                description,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



// Specialties Widget
class Specialties extends StatelessWidget {
  final String description;
  final String imagePath;
  final String details;
  final String bestDoctor;
  final String iconPath;
  final String call;

  Specialties({
    required this.description,
    required this.imagePath,
    required this.details,
    required this.bestDoctor,
    required this.iconPath,
    required this.call,
  });

  Future<void> _launchDialer(String number) async {
    final url = 'tel:$number';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(imagePath),
                    ),
                    SizedBox(height: 15),
                    Center(child: Text('Description: $description')),
                    Center(child: Text('Details: $details')),
                    Center(child: Text('Best Doctor: $bestDoctor')),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _launchDialer(call);
                        },
                        child: Text('Call Now: $call'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, // Foreground color
                          backgroundColor: Colors.blue, // Background color
                        ),
                      ),
                    ),
                    // SizedBox(height: 8),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     Navigator.of(context).pop();
                    //   },
                    //   child: Text('Close'),
                    //   style: ElevatedButton.styleFrom(
                    //     foregroundColor: Colors.white, // Foreground color
                    //     backgroundColor: Colors.grey, // Background color
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column( // Changed from Row to Column
            children: [
              Image.asset(
                iconPath,
                height: 24,
                width: 24,
              ),
              SizedBox(height: 8.0), // Changed from width to height
              Text(
                description,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
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

Future<void> makePhoneCall(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}