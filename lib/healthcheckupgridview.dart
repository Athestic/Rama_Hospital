import 'package:flutter/material.dart';
import 'package:bottom_navigation/bookappointment.dart';
import 'package:bottom_navigation/healthcheckupgridview.dart';
import 'package:bottom_navigation/HealthCheckup.dart';
class HealthCheckupGrid extends StatelessWidget {
  final List<Map<String, String>> healthCheckups = [
    {
      'description': 'General Checkup',
      'imagePath': 'assets/healthcheckups/general_checkup.jpg',
    },
    {
      'description': 'Blood Test',
      'imagePath': 'assets/healthcheckups/blood_test.jpg',
    },
    {
      'description': 'X-Ray',
      'imagePath': 'assets/healthcheckups/xray.jpg',
    },
    // Add more health checkups as needed
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: healthCheckups.length,
      itemBuilder: (context, index) {
        final healthCheckup = healthCheckups[index];
        return HealthCheckup(
          description: healthCheckup['description']!,
          imagePath: healthCheckup['imagePath']!,
        );
      },
    );
  }
}
