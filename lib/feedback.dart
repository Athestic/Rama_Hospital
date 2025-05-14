import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Make sure to import http package
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'app_config.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  String _selectedCategory = 'Doctors';
  String _feedback = '';
  double _rating = 0.0; // Rating value
  String? patientId;
  List<Map<String, dynamic>> _feedbackList = []; // List to hold feedback data

  final List<String> _categories = [
    'Doctors',
    'Nursing Staff',
    'Facilities',
    'Appointments',
    'Billing',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    _getPatientId(); // Fetch patientId on initialization
  }

  Future<void> _getPatientId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    patientId = prefs.getString('patientId'); // Get the saved patientId

    // Fetch feedback data after obtaining patientId
    if (patientId != null) {
      _fetchFeedback(); // Fetch feedback data
    }
  }

  Future<void> _fetchFeedback() async {
    String apiUrl = '${AppConfig.apiUrl1}${AppConfig.getHospitalAppFeedbackByPatientId}?PatientID=$patientId';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Decode the response body
        final List<dynamic> feedbackData = jsonDecode(response.body);
        setState(() {
          _feedbackList = List<Map<String, dynamic>>.from(feedbackData);
        });

        // Print the fetched feedback data to the terminal
        print('Fetched Feedback Data:');
        print(_feedbackList);
      } else {
        throw Exception('Failed to fetch feedback. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching feedback: $error');
      // Optionally show an error dialog or message
    }
  }

  Future<void> _submitFeedback() async {
    if (_feedback.isEmpty || _rating == 0.0 || patientId == null) {
      // Handle the error state
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Incomplete Feedback'),
            content: Text('Please provide a rating and feedback.'),
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
      return;
    }

    // Construct the API URL
    final String apiUrl = '${AppConfig.apiUrl1}${AppConfig.patientFeedbackEndpoint}?PatientID=$patientId&Feedback=$_feedback';

    try {
      // Send the POST request
      final response = await http.post(Uri.parse(apiUrl));

      // Log the submitted data to the terminal
      print('Submitted Feedback Data:');
      print('Patient ID: $patientId');
      print('Category: $_selectedCategory');
      print('Rating: $_rating');
      print('Feedback: $_feedback');

      if (response.statusCode == 200) {
        // Successfully submitted feedback
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Feedback Submitted'),
              content: Text(
                'Category: $_selectedCategory\nRating: $_rating\nFeedback: $_feedback',
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

        // Optionally, you can refetch the feedback after submission
        _fetchFeedback(); // Refresh the feedback list
      } else {
        // Handle the error response
        throw Exception('Failed to submit feedback. Status code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle network or other errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while submitting feedback: $error'),
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
    }
  }

  String _formatDate(String dateString) {
    // Parse the date string and format it to 'YYYY-MM-DD'
    DateTime dateTime = DateTime.parse(dateString);
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feedback',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Rama Hospital',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontFamily: 'Poppins',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Select Category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: 'Select a category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.black, // Border color when enabled and not focused
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: AppColors.secondaryColor, // Color when the dropdown is focused
                      width: 1.0,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.red, // Error color
                      width: 1.0,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.red, // Focused error color
                      width: 1.0,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),

              SizedBox(height: 20),
              Text(
                'Rate Your Experience',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color: index < _rating ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _rating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              SizedBox(height: 20),
              Text(
                'Feedback',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              TextFormField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your feedback here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: Colors.black, // Color when enabled and not focused
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: AppColors.secondaryColor, // Color when focused
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) {
                  _feedback = value;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Submit Feedback',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 20),
              Text(
                'Previous Feedback:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8), // Added some space for better readability
              _feedbackList.isEmpty
                  ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'No feedback available.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true, // Ensure it takes the necessary height
                physics: NeverScrollableScrollPhysics(), // Disable internal scrolling
                itemCount: _feedbackList.length,
                itemBuilder: (context, index) {
                  final feedbackItem = _feedbackList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Feedback ID: ${feedbackItem['feedbackID']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          Text(feedbackItem['feedback']),
                          SizedBox(height: 8.0),
                          Text(
                            'Submitted on: ${_formatDate(feedbackItem['createdOn'])}', // Format the date here
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
