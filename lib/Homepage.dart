import 'package:bottom_navigation/PatientLogin.dart';
import 'package:bottom_navigation/colors.dart';
import 'package:flutter/material.dart';
import 'doctor_login.dart';
import 'view_all_doctors.dart';
import 'patient_registration.dart';
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
        // rating: 4.5,
        imagePath: 'assets/doctors/dranilbhat.jpg',
        // operations: 'Cardiac Surgery, Heart Transplant',
        // degrees: 'MBBS, MD, DM Cardiology',
      ),
    },
    {
      'type': 'Top Doctor',
      'widget': DoctorCard(
        name: 'Dr. R K Singh',
        specialty: 'MS-ENT',
        // rating: 4.5,
        imagePath: 'assets/doctors/RKSingh.jpg',
        // operations: 'ENT Surgery, Cochlear Implant',
        // degrees: 'MBBS, MS-ENT',
      ),
    },
    {
      'type': 'Top Doctor',
      'widget': DoctorCard(
        name: 'Dr. Arun Kumar',
        specialty: 'General Medicine',
        // rating: 4.5,
        imagePath: 'assets/doctors/arunkumar.jpg',
        // operations: 'General Checkup, Diabetes Management',
        // degrees: 'MBBS, MD General Medicine',
      ),
    },
    {
      'type': 'Top Doctor',
      'widget': DoctorCard(
        name: 'Dr. Anshu Sharma',
        specialty: 'Ophthalmology',
        // rating: 4.5,
        imagePath: 'assets/doctors/AnshuSharma.jpg',
        // operations: 'Cataract Surgery, LASIK',
        // degrees: 'MBBS, MS Ophthalmology',
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
        icon: Icons.favorite,
      ),
    },
    {
      'type': 'Super_Specialties',
      'widget': SuperSpecialties(
        description: 'Gastroenterology',
        imagePath: 'assets/super_specialities/Gastro.jpg',
        details: 'A gastroenterologist is a specialist in gastrointestinal diseases. Gastroenterologists treat all the organs in your digestive system.',
        bestDoctor: 'Dr. Anil Bhat',
        icon: Icons.local_dining,
      ),
    },
    {
      'type': 'Super_Specialties',
      'widget': SuperSpecialties(
        description: 'Nephrology',
        imagePath: 'assets/super_specialities/nephrology.jpg',
        details: 'Nephrology is a branch of internal medicine that deals with kidney diseases and disorders.',
        bestDoctor: 'Dr. DK Sinha',
        icon: Icons.opacity,
      ),
    },
    {
      'type': 'Super_Specialties',
      'widget': SuperSpecialties(
        description: 'Neurology',
        imagePath: 'assets/super_specialities/neurology.jpeg',
        details: 'A neurologist is a medical doctor who diagnoses, treats and manages disorders of the brain and nervous system (brain, spinal cord and nerves).',
        bestDoctor: 'Dr. Navneet Kumar',
        icon: Icons.memory,
      ),
    },
    {
      'type': 'Specialties',
      'widget': Specialties(
        description: 'Cardiology',
        imagePath: 'assets/cardiology.jpg',
        details: 'Cardiology deals with disorders of the heart and blood vessels.',
        bestDoctor: 'Dr. Anil Bhat',
        icon: Icons.favorite,
      ),
    },
    {
      'type': 'Specialties',
      'widget': Specialties(
        description: 'Urology',
        imagePath: 'assets/Urology.jpg',
        details: 'Urology focuses on surgical and medical diseases of the urinary-tract system.',
        bestDoctor: 'Dr. R K Singh',
        icon: Icons.local_hospital,
      ),
    },
    {
      'type': 'Specialties',
      'widget': Specialties(
        description: 'Colonoscopy',
        imagePath: 'assets/Colonoscopy.jpg',
        details: 'Colonoscopy is an endoscopic examination of the large bowel and the distal part of the small bowel.',
        bestDoctor: 'Dr. Arun Kumar',
        icon: Icons.search,
      ),
    },
    {
      'type': 'Specialties',
      'widget': Specialties(
        description: 'Ophthalmology',
        imagePath: 'assets/Ophthalmology.jpg',
        details: 'Ophthalmology deals with the anatomy, physiology, and diseases of the eye.',
        bestDoctor: 'Dr. Anshu Sharma',
        icon: Icons.remove_red_eye,
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
            Image.asset(
              'assets/ramalogo.png', // Update the path to your logo asset
              height: 50,
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Emergency Call'),
                          content: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.call, size: 50, color: Colors.green),
                                  onPressed: () {
                                    _makePhoneCall('tel:7877775530');
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Close'),
                            ),
                          ],
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
                      SizedBox(height: 4.0), // Spacing between texts
                      Text(
                        'Explore Advice, Health Tips & More',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                          fontFamily: 'Poppins'// Smaller font size for second text
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/ban_doc.png', // Update the path to your image asset
                  height: 90,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),

          // Section 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Doctors',
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
                    color: Colors.blue,
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
            height: 200,
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
            height: 200,
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
            height: 200,
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
            height: 200,
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
            height: 200,
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

class _makePhoneCall {
  _makePhoneCall(String s);
}

// Doctor Card Widget
class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  // final double rating;
  final String imagePath;
  // final String operations;
  // final String degrees;

  const DoctorCard({
    required this.name,
    required this.specialty,
    // required this.rating,
    required this.imagePath,
    // required this.operations,
    // required this.degrees,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(name),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(imagePath),
                    ),
                    SizedBox(height: 15),
                    Text('Specialty: $specialty'),
                    // Text('Rating: $rating'),
                    // Text('Operations: $operations'),
                    // Text('Degrees: $degrees'),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PatientRegistrationForm()),
                        );
                      },
                      child: Text('Book Appointment'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        // padding: const EdgeInsets.only(top: 8.0),
        // margin: EdgeInsets.all(1.0),
        width: 150,
        height: 200, // Add the height property here
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
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Curved top
              child: Image.asset(
                imagePath,
                width: 100,
                height:140,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
  final IconData icon;

  SuperSpecialties({
    required this.description,
    required this.imagePath,
    required this.details,
    required this.bestDoctor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset(
            imagePath,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8.0),
          Text(
            description,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Icon(icon),
              SizedBox(width: 4.0),
              Text(details),
            ],
          ),
          Text('Best Doctor: $bestDoctor'),
        ],
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
  final IconData icon;

  Specialties({
    required this.description,
    required this.imagePath,
    required this.details,
    required this.bestDoctor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset(
            imagePath,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 8.0),
          Text(
            description,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Icon(icon),
              SizedBox(width: 4.0),
              Text(details),
            ],
          ),
          Text('Best Doctor: $bestDoctor'),
        ],
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
