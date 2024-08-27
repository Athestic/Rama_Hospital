import 'package:flutter/material.dart';
import 'package:global/DoctorDetailScreen.dart';
import 'package:global/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'inpersonvisit.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Doctor {
  final String doctorName;
  final int unitId;
  final int doctorId;
  final double consultationFee;
  final String? qualification;
  final String fromDate;
  final String toDate;
  final int todayOpd;
  final String? doctorImg;
  final String? experience;

  Doctor({
    required this.doctorName,
    required this.unitId,
    required this.doctorId,
    required this.consultationFee,
    required this.qualification,
    required this.fromDate,
    required this.toDate,
    required this.todayOpd,
    required this.doctorImg,
    required this.experience,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    // Fix: handle the experience field properly (parsing it from string to int)
    int experience = 0;
    if (json['experience'] != null) {
      try {
        experience = int.parse(json['experience']);
      } catch (e) {
        experience = 0; // Default if parsing fails
      }
    }

    return Doctor(
      doctorName: json['doctor_name'] ?? 'Unknown Doctor',
      unitId: json['unit_id'] ?? 0,
      doctorId: json['doctor_id'] ?? 0,
      consultationFee: (json['consultation_fee'] ?? 0).toDouble(),
      qualification: json['qualification'] ?? '',
      fromDate: json['from_date'] ?? '',
      toDate: json['to_date'] ?? '',
      todayOpd: json['todayOpd'] ?? 0,
      doctorImg: json['doctor_image']?.toString(),
      experience: json['experience'] ?? '', // Assign the parsed experience
    );
  }
}

class DoctorsScreen extends StatelessWidget {
  final int specializationId;
  final String specializationName;
  final Future<List<Doctor>> fetchDoctors;

  DoctorsScreen({
    required this.specializationId,
    required this.specializationName,
    required this.fetchDoctors,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$specializationName',
          style: TextStyle(
            color: Colors.teal,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              height: 45.0,
              width: double.infinity,
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search for Doctors',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Doctor>>(
              future: fetchDoctors,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No doctors found'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Doctor doctor = snapshot.data![index];

                      // Display image: either base64 or from a URL
                      Widget doctorImage;
                      if (doctor.doctorImg != null) {
                        if (doctor.doctorImg!.startsWith('http')) {
                          doctorImage = Image.network(
                            doctor.doctorImg!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        } else {
                          doctorImage = Image.memory(
                            base64Decode(doctor.doctorImg!),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          );
                        }
                      } else {
                        doctorImage = Icon(Icons.person, size: 80);
                      }
                      return Card(
                        margin: EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // First Column: Doctor Info Section
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Doctor name and rating
                                    Row(
                                      children: [
                                        Expanded(
                                          child:
                                          Text(
                                            doctor.doctorName, // Use doctorName from the API
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    // Specialization
                                    Text(
                                      'ConsultationFee: ${doctor.consultationFee}',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5), // Space between rating and experience
                                    Text(
                                      'Qualifications :${doctor. qualification}', // Experience from API
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 5), // Space between rating and experience
                                    Text(
                                      'Experience :${doctor.experience}', // Experience from API
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Language : English,Hindi',
                                      style: TextStyle(
                                        // color: Colors.black,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),

                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        // Hospital Visit button
                                        SizedBox(
                                          width: 100,
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              SharedPreferences prefs = await SharedPreferences.getInstance();

                                              await prefs.setString('unitId', doctor.unitId.toString());
                                              await prefs.setString('doctorId', doctor.doctorId.toString());
                                              await prefs.setDouble('consultationFee', doctor.consultationFee);

                                              // Navigate to DoctorDetailScreen or any other appropriate screen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DoctorDetailScreeninpersonvisit(doctor: doctor),
                                                ),
                                              );
                                            },

                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primaryColor,
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                            ),
                                            child: Text(
                                              'Hospital Visit',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        // Video Consultation button
                                        SizedBox(
                                          width: 100,
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => DoctorDetailScreen(doctor: doctor),
                                                ),
                                              ); // / Navigate to Video Consultation screen
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.secondaryColor,
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                            ),
                                            child: Text(
                                              'Video Consult',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 5),
                              // Second Column: Doctor Image Section
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 100,
                                  height: 127,
                                  child: doctorImage, // Display the doctor image
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Method to fetch doctors by specialization
Future<List<Doctor>> fetchDoctorsBySpecialization(int specializationId) async {
  final response = await http.get(Uri.parse(
      'http://192.168.1.106:8081/api/HospitalApp/GetUnitDetails?doctorId=7&specId=$specializationId')); // Adjusted API URL

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((data) => Doctor.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load doctors');
  }
}
