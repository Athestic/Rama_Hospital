import 'package:flutter/material.dart';
import 'patient_registration.dart';

class ViewAllDoctors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Our Medical Experts',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DoctorCard(
              name: 'Dr. Ravish Kumar Verma',
              specialty: 'General Medicine',
              experience: '29 Years',
              rating: 87,
              patientStories: 69,
              availability: 'Mon, Tue & Fri',
              imagePath: 'assets/doctors/MaheshGupta.jpg', // Update with actual image path
            ),
            DoctorCard(
              name: 'Dr. Navneet Kumar',
              specialty: 'Neurology',
              experience: '33+ Years',
              rating: 95,
              patientStories: 100,
              availability: 'Mon, Tue & Fri',
              imagePath: 'assets/doctors/dranilbhat.jpg', // Update with actual image path
            ),
            DoctorCard(
              name: 'Dr. Priyanka Dubey',
              specialty: 'Ophthalmology',
              experience: '6+ Years',
              rating: 95,
              patientStories: 30,
              availability: 'Mon, Tue & Fri',
              imagePath: 'assets/doctors/SanjeevRohatgi.jpg', // Update with actual image path
            ),
            // Add more DoctorCard widgets as needed
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String experience;
  final int rating;
  final int patientStories;
  final String availability;
  final String imagePath;

  DoctorCard({
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.patientStories,
    required this.availability,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imagePath,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      specialty,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '$experience experience',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    Row(
                      children: [

                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Availability',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      availability,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),

                child: Text('Book Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
