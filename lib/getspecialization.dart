import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:global/colors.dart';
import 'package:http/http.dart' as http;
import 'doctor_list_screen.dart';
import 'app_config.dart';

// Global Selected Specialization Holder
class SelectedSpecialization {
  static String? specializationName;
  static int? specializationId;
}

class SpecializationsScreen extends StatefulWidget {
  @override
  _SpecializationsScreenState createState() => _SpecializationsScreenState();
}

class _SpecializationsScreenState extends State<SpecializationsScreen> {
  late Future<List<Specialization>> futureSpecializations;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    futureSpecializations = fetchSpecializations();
  }

  Future<List<Specialization>> fetchSpecializations() async {
    final response = await http.get(Uri.parse('${AppConfig.apiUrl1}${AppConfig.specialityEndpoint}'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      List<Specialization> specializations = jsonData.map((data) => Specialization.fromJson(data)).toList();

      specializations.sort((a, b) => a.specialization.toLowerCase().compareTo(b.specialization.toLowerCase()));
      return specializations;
    } else {
      throw Exception('Failed to load specializations');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardColor3,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Specializations',
          style: TextStyle(color: Colors.teal, fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Speciality',
                prefixIcon: Icon(Icons.search, color: AppColors.secondaryColorShades),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Specialization>>(
              future: futureSpecializations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No specializations found'));
                } else {
                  List<Specialization> filteredSpecializations = snapshot.data!
                      .where((spec) => spec.specialization.toLowerCase().contains(_searchQuery))
                      .toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
                      double imageSize = constraints.maxWidth > 600 ? 100 : 80;

                      return GridView.builder(
                        padding: EdgeInsets.all(10.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                        ),
                        itemCount: filteredSpecializations.length,
                        itemBuilder: (context, index) {
                          Specialization specialization = filteredSpecializations[index];
                          Uint8List imageBytes = base64Decode(specialization.iconBase64);

                          return GestureDetector(
                            onTap: () {
                              // Save the selected specialization globally
                              SelectedSpecialization.specializationName = specialization.specialization;
                              SelectedSpecialization.specializationId = specialization.specializationId;

                              // Then navigate to the doctors screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorsScreen(
                                    specializationId: specialization.specializationId,
                                    specializationName: specialization.specialization,
                                    fetchDoctors: fetchDoctorsBySpecialization(specialization.specializationId),
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.memory(
                                    imageBytes,
                                    width: imageSize,
                                    height: imageSize,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  specialization.specialization,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth > 600 ? 16 : 12,
                                    fontFamily: 'Poppins',
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
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

class Specialization {
  final String specialization;
  final int specializationId;
  final String iconBase64;

  Specialization({required this.specialization, required this.specializationId, required this.iconBase64});

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      specialization: json['specialization'] ?? 'Unknown Specialization',
      specializationId: json['specializationId'] ?? 0,
      iconBase64: json['iconBase64'] ?? '',
    );
  }
}
