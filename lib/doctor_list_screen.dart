import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'patient_registration.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // For the rating stars

class DoctorListScreen extends StatelessWidget {
  final List<Doctor> doctors;

  DoctorListScreen({required this.doctors});

  Uint8List _decodeBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return Uint8List(0);
    }
    try {
      return base64Decode(base64String);
    } catch (e) {
      print('Error decoding base64 string: $e');
      return Uint8List(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_outlined),
            onPressed: () {
              // Handle filter action
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: doctor.doctorImg != null
                            ? MemoryImage(_decodeBase64(doctor.doctorImg))
                            : AssetImage('assets/no_image.png') as ImageProvider,
                        backgroundColor: Colors.grey[200],
                        onBackgroundImageError: (exception, stackTrace) {
                          print('Error loading image: $exception');
                        },
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor.doctorName,
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      //       Text(
                      //         doctor.specialization,
                      //         style: TextStyle(
                      //           color: Colors.grey[700],
                      //         ),
                      //       ),
                      //       SizedBox(height: 8.0),
                      //       Row(
                      //         children: [
                      //           RatingBarIndicator(
                      //             rating: doctor.rating,
                      //             itemBuilder: (context, index) => Icon(
                      //               Icons.star,
                      //               color: Colors.amber,
                      //             ),
                      //             itemCount: 5,
                      //             itemSize: 20.0,
                      //             direction: Axis.horizontal,
                      //           ),
                      //           SizedBox(width: 8.0),
                      //           Text(
                      //             '${doctor.patientStories} Patient Stories',
                      //             style: TextStyle(
                      //               color: Colors.grey[700],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       SizedBox(height: 8.0),
                      //       Text(
                      //         'Availability: ${doctor.availability}',
                      //         style: TextStyle(
                      //           color: Colors.green[700],
                      //         ),
                      //       ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                              builder: (context) => PatientRegistrationForm(),
                          ),
                          );

                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal, // Set the background color to match the button in the image
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0), // Make the button rounded
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Adjust padding for size
                        ),
                        child: Text(
                          'Book Now',
                          style: TextStyle(
                            fontSize: 16, // Adjust font size if needed
                            color: Colors.white, // Set the text color to white
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class Doctor {
  final int doctorId;
  final String doctorName;
  // final String specialization;
  // final double rating;
  // final int experience;
  // final String availability;
  // final int patientStories;
  final String? doctorImg;

  Doctor({
    required this.doctorId,
    required this.doctorName,
    // required this.specialization,
    // required this.rating,
    // required this.experience,
    // required this.availability,
    // required this.patientStories,
    this.doctorImg,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      doctorId: json['doctorId'],
      doctorName: json['doctorName'],
      // specialization: json['specialization'],
      // rating: json['rating'].toDouble(),
      // experience: json['experience'],
      // availability: json['availability'],
      // patientStories: json['patientStories'],
      doctorImg: json['doctorImg'] as String?,
    );
  }
}
