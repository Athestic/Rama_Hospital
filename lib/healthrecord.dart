import 'package:flutter/material.dart';
class HealthRecordsScreen extends StatelessWidget {
  final String patientId;

  HealthRecordsScreen({required this.patientId});

  @override
  Widget build(BuildContext context) {
    TextEditingController patientIdController = TextEditingController(text: patientId);
    TextEditingController reportDetailsController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Health Records'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: patientIdController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Patient ID',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: reportDetailsController,
              decoration: InputDecoration(
                labelText: 'Report Details',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Implement the view reports logic here
              },
              child: Text('View Reports'),
            ),
          ],
        ),
      ),
    );
  }
}
