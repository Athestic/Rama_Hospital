import 'package:flutter/material.dart';
class DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final double rating;
  final String imagePath;

  DoctorCard({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Container(
          width: 150,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(imagePath, height: 50),
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
