import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'onlineappointment.dart';
import 'inpersonvisit.dart';
import 'app_config.dart';
import 'package:lottie/lottie.dart';

class Doctor {
  final String doctorName;
  final int unitId;
  final int doctorId;
  final double consultationFee;
  final String? qualification;
  final String fromDate;
  final String toDate;
  final String Descrp;
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
    required this.Descrp,
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
      Descrp: json['doctorDescrp'] ?? '',

      toDate: json['to_date'] ?? '',
      todayOpd: json['todayOpd'] ?? 0,
      doctorImg: json['doctor_image']?.toString(),
      experience: json['experience']?.toString() ?? '0',
    );
  }
}

class GlobalDoctorData {
  static final GlobalDoctorData _instance = GlobalDoctorData._internal();
  GlobalDoctorData._internal();
  factory GlobalDoctorData() => _instance;

  String? doctorName;
  String? doctorImg;
  String? experience;
  String? Descrp;
  int? unitId;
  int? doctorId;
  double? consultationFee;

  void setDoctorDetails(Doctor doctor) {
    doctorName = doctor.doctorName;
    doctorImg = doctor.doctorImg;
    experience = doctor.experience;
    Descrp = doctor.Descrp;

    unitId = doctor.unitId;
    doctorId = doctor.doctorId;
    consultationFee = doctor.consultationFee;
  }
}

class DoctorsScreen extends StatefulWidget {
  final int specializationId;
  final String specializationName;
  final Future<List<Doctor>> fetchDoctors;

  DoctorsScreen({
    required this.specializationId,
    required this.specializationName,
    required this.fetchDoctors,
  });

  @override
  _DoctorsScreenState createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  List<Doctor> allDoctors = [];
  List<Doctor> filteredDoctors = [];
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    widget.fetchDoctors.then((doctors) {
      // Print each doctor's description
      for (var doc in doctors) {
        print("Doctor: ${doc.doctorName}, Description: ${doc.Descrp}");
      }

      setState(() {
        allDoctors = doctors;
        filteredDoctors = doctors;
        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        filteredDoctors = allDoctors
            .where((doctor) =>
            doctor.doctorName.toLowerCase().contains(_searchQuery))
            .toList();
      });
    });
  }


  void storeDoctorDetailsGlobally(Doctor doctor) {
    GlobalDoctorData().setDoctorDetails(doctor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose Your Doctor',
          style: TextStyle(
            color: AppColors.primaryColor,
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
                controller: _searchController,
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
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : error != null
                ? Center(child: Text('Error: $error'))
                : filteredDoctors.isEmpty
                ? Center(child: Text('No doctors found'))
                : ListView.builder(
              itemCount: filteredDoctors.length,
              itemBuilder: (context, index) {
                Doctor doctor = filteredDoctors[index];

                Widget doctorImage;
                if (doctor.doctorImg != null) {
                  if (doctor.doctorImg!.startsWith('http')) {
                    doctorImage = Image.network(
                      doctor.doctorImg!,
                      width: 120,
                      height: 140,
                      fit: BoxFit.cover,
                    );
                  } else {
                    doctorImage = Image.memory(
                      base64Decode(doctor.doctorImg!),
                      width: 120,
                      height: 140,
                      fit: BoxFit.cover,
                    );
                  }
                } else {
                  doctorImage = Icon(Icons.person, size: 80);
                }

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dr. ${doctor.doctorName}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.bold,
                                            fontFamily: 'Poppins',
                                          ),
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          widget.specializationName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                          overflow:
                                          TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 5),
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.green,
                                              width: 1.0,
                                            ),
                                            borderRadius:
                                            BorderRadius
                                                .circular(10),
                                          ),
                                          padding:
                                          EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4),
                                          child: Text(
                                            '${doctor.experience!} ',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '4/5',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                              size: 16,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        RichText(
                                          textAlign:
                                          TextAlign.right,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                'Availability\n',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                  Colors.black,
                                                  fontWeight:
                                                  FontWeight
                                                      .w500,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                'Mon, Tue, Fri',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                  Colors.blue,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 5.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        storeDoctorDetailsGlobally(
                                            doctor);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DoctorDetailScreeninpersonvisit(
                                                    doctor: doctor),
                                          ),
                                        );
                                      },
                                      style:
                                      ElevatedButton.styleFrom(
                                        backgroundColor:
                                        AppColors.primaryColor,
                                        shape:
                                        RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(
                                              5),
                                        ),
                                        padding:
                                        EdgeInsets.symmetric(
                                            horizontal: 9,
                                            vertical: 2),
                                      ),
                                      child: Text(
                                        'Hospital Visit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Lottie.asset(
                                                    'assets/video_animation.json', // Replace with your Lottie file path or URL
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    'We’re excited to be expanding our services — exciting updates are on the way, so stay tuned and connected with us!',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.secondaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      ),
                                      child: Text(
                                        'Video Consult',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12), // Space between text and image
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.secondaryColor,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 120,
                              height: 125,
                              child: doctorImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

  Future<List<Doctor>> fetchDoctorsBySpecialization(int specializationId) async {
  final uri = Uri.parse(
    '${AppConfig.apiUrl1}${AppConfig.getUnitDetailsEndpoint}?specId=$specializationId',
  );

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((data) => Doctor.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load doctors');
  }
}
