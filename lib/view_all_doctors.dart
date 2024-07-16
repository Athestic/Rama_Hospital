import 'package:flutter/material.dart';

class ViewAllDoctors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Top Doctors'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DoctorCard(
              name: 'Dr. Anil Bhat',
              specialty: 'Cardiology',
              rating: 4.5,
            ),
            DoctorCard(
              name: 'Dr. R K Singh',
              specialty: 'MS-ENT',
              rating: 4.5,
            ),
            DoctorCard(
              name: 'Dr. Navneet Kumar',
              specialty: 'Neurology',
              rating: 4.5,
            ),
            DoctorCard(
              name: 'Dr. Anshu Sharma',
              specialty: 'Ophthalmology',
              rating: 4.5,
            ),
            DoctorCard(
              name: 'Dr. Anil Bhat',
              specialty: 'Cardiology',
              rating: 4.5,
            ),
            DoctorCard(
              name: 'Dr. R K Singh',
              specialty: 'MS-ENT',
              rating: 4.5,
            ),
            DoctorCard(
              name: 'Dr. Navneet Kumar',
              specialty: 'Neurology',
              rating: 4.5,
            ),
            DoctorCard(
              name: 'Dr. Anshu Sharma',
              specialty: 'Ophthalmology',
              rating: 4.5,
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;

  DoctorCard({required this.name, required this.specialty, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.person, size: 50),
              SizedBox(height: 10),
              Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
              Text(specialty),
              SizedBox(height: 10),
              Text('$rating', style: TextStyle(color: Colors.blue)),
            ],
          ),
        ),
      ),
    );
  }
}
