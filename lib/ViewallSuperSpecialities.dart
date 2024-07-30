import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class ViewAllSuperSpecialities extends StatefulWidget {
  @override
  _ViewAllSuperSpecialitiesState createState() => _ViewAllSuperSpecialitiesState();
}

class _ViewAllSuperSpecialitiesState extends State<ViewAllSuperSpecialities> {
  List<dynamic> _superSpecialities = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSuperSpecialities();
  }

  Future<void> _fetchSuperSpecialities() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.166:8081/api/Application/Superspecialitytitles'));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        // Debug output
        print(responseBody);

        if (responseBody['status'] == 'success') {
          setState(() {
            _superSpecialities = responseBody['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = responseBody['message'] ?? 'Failed to load super specialties';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load super specialties';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Super Specialities'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(child: Text(_errorMessage))
          : ListView.builder(
        itemCount: _superSpecialities.length,
          itemBuilder: (context, index) {
            var speciality = _superSpecialities[index];
            Uint8List? imageData;
            if (speciality['image'] != null) {
              imageData = base64Decode(speciality['image']);
            }

            return ListTile(
              leading: imageData != null
                  ? Image.memory(imageData, width: 50, height: 50, fit: BoxFit.cover)
                  : Icon(Icons.image, size: 50), // Display a placeholder icon if image is null
              title: Text(speciality['title'] ?? 'No title'),
              subtitle: Text(speciality['description'] ?? 'No description'),
            );
          }
      ),
    );
  }
}
