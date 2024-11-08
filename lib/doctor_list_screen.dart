import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'onlineappointment.dart';
import 'inpersonvisit.dart';

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
      experience: json['experience']?.toString() ?? '0',
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

  Future<void> storeDoctorDetails(Doctor doctor, String specializationName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('doctorName', doctor.doctorName);
    await prefs.setString('doctorImg', doctor.doctorImg ?? '');
    await prefs.setString('experience', doctor.experience ?? '0');
    await prefs.setString('specializationName', specializationName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          specializationName,
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            doctor.doctorName,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'ConsultationFee: ${doctor.consultationFee}',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Qualifications: ${doctor.qualification}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Experience: ${doctor.experience}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Language: English, Hindi',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              await storeDoctorDetails(
                                                  doctor, specializationName);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DoctorDetailScreeninpersonvisit(
                                                          doctor: doctor),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              AppColors.primaryColor,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(7),
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
                                        SizedBox(
                                          width: 100,
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DoctorDetailScreen(
                                                          doctor: doctor),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                              AppColors.secondaryColor,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(7),
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 100,
                                  height: 127,
                                  child: doctorImage,
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
      'http://192.168.1.106:8081/api/HospitalApp/GetUnitDetails?doctorId=7&specId=$specializationId'));

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((data) => Doctor.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load doctors');
  }
}
