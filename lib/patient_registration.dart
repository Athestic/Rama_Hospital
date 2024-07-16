import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'thank_you_screen.dart';

void main() {
  runApp(MaterialApp(
    home: RegistrationNavigation(),
  ));
}

class RegistrationNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Registration Navigation'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PatientRegistrationForm()),
            );
          },
          child: Text('Go to Registration Form'),
        ),
      ),
    );
  }
}

class PatientRegistrationForm extends StatefulWidget {
  @override
  _PatientRegistrationFormState createState() => _PatientRegistrationFormState();
}

class _PatientRegistrationFormState extends State<PatientRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  late PageController _pageController;
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _cities = [];
  String? _selectedState;
  String? _selectedCity;
  List<Map<String, dynamic>> _religions = [];
  String? _selectedReligion;
  int _currentPage = 0;
  String? _gender;
  String? _maritalStatus;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fetchStates();
    _fetchReligions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchStates() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.196:8080/api/PatientRegistration/GetState'));
      if (response.statusCode == 200) {
        List<dynamic> statesData = json.decode(response.body);
        setState(() {
          _states = statesData.map((state) {
            return {
              'stateId': state['stateId'],
              'stateName': state['stateName'],
            };
          }).toList();
        });
      } else {
        print('Failed to load states: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  Future<void> _fetchCities(int stateId) async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.196:8080/api/PatientRegistration/GetCityByState?StateId=$stateId'));
      if (response.statusCode == 200) {
        List<dynamic> citiesData = json.decode(response.body);
        setState(() {
          _cities = citiesData.map((city) {
            return {
              'cityId': city['cityId'],
              'cityName': city['cityName'].toString(),
            };
          }).toList();
          _selectedCity = null; // Reset the selected city
        });
      } else {
        print('Failed to load cities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  Future<void> _fetchReligions() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.196:8080/api/PatientRegistration/GetReligions'));
      if (response.statusCode == 200) {
        List<dynamic> religionsData = json.decode(response.body);
        setState(() {
          _religions = religionsData.map((religion) {
            return {
              'religionId': religion['religionId'],
              'religionName': religion['religionName'].toString(),
            };
          }).toList();
        });
      } else {
        print('Failed to load religions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching religions: $e');
    }
  }

  Future<void> _registerPatient(Map<String, dynamic> patientData) async {
    try {
      print('Sending patient data: ${json.encode(patientData)}'); // Logging the payload
      final response = await http.post(
        Uri.parse('http://192.168.1.196:8081/api/Application/PatientRegistrationApp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(patientData),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Patient registered successfully')));
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThankYouScreen()),
        );
            } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register patient')));
      }
    } catch (e) {
      print('Error registering patient: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error registering patient: $e')));
    }
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      if (_formKey.currentState!.validate()) {
        Map<String, dynamic> patientData = {
          'first_name': _firstNameController.text,
          'middleName': _middleNameController.text,
          'last_name': _lastNameController.text,
          'father_spouse_name': _guardianNameController.text,
          'relation': _relationController.text,
          'dob': _dobController.text,
          'email': _emailController.text,
          'ReligionID': _religions.firstWhere((religion) => religion['religionName'] == _selectedReligion)['religionId'],
          'phone_no': _phoneNumberController.text,
          'AdharNo': _aadhaarNumberController.text,
          'gender': _gender == 'Male' ? 'M' : 'F',
          'Maritalstatus': _maritalStatus == 'Married' ? 'M' : 'U',
          'attendant': _attendantController.text,
          'attendantContactNumber': _attendantContactNumberController.text,
          'CityId': _cities.firstWhere((city) => city['cityName'] == _selectedCity)['cityId'],
          'address': _areaController.text,
          'Village': _villageController.text,
          'state_id': _selectedState,
          'relationWithPatient': _relationWithPatientController.text,
          'emergency_contact_no': _emergencyContactNumberController.text,
        };
        _registerPatient(patientData);
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
        _ageController.text = _calculateAge(picked).toString();
      });
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _aadhaarNumberController = TextEditingController();
  final TextEditingController _attendantController = TextEditingController();
  final TextEditingController _attendantContactNumberController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _villageController = TextEditingController();
  final TextEditingController _relationWithPatientController = TextEditingController();
  final TextEditingController _emergencyContactNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Partient Registration',
          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: SizedBox(
              width: 34,
              height: 34,
              child: Image.asset('assets/Reg_Patient.png'),
            ),
            onPressed: () {
              // Handle button press
            },
          ),
        ],
      ),

      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                onPageChanged: _onPageChanged,
                children: [_buildPage1(), _buildPage2()],
              ),
            ),
            Container(
              width: double.infinity, // Make the button full width
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Add padding for alignment
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Curved sides
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.0), // Vertical padding
                ),
                child: Text(
                  _currentPage == 1 ? 'Submit' : 'Next',
                  style: TextStyle(fontSize: 16), // Text style
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPage1() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(labelText: 'First Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter first name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _middleNameController,
            decoration: InputDecoration(labelText: 'Middle Name'),
          ),
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(labelText: 'Last Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter last name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _guardianNameController,
            decoration: InputDecoration(labelText: 'Guardian Name'),
          ),
          TextFormField(
            controller: _relationController,
            decoration: InputDecoration(labelText: 'Relation'),
          ),
          TextFormField(
            controller: _dobController,
            decoration: InputDecoration(
              labelText: 'Date of Birth',
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () {
                  _selectDate(context);
                },
              ),
            ),
            readOnly: true,
          ),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter email';
            //   }
            //   return null;
            // },
          ),
          DropdownButtonFormField<String>(
            value: _selectedReligion,
            decoration: InputDecoration(labelText: 'Religion'),
            items: _religions.map<DropdownMenuItem<String>>((religion) {
              return DropdownMenuItem<String>(
                value: religion['religionName'],
                child: Text(religion['religionName']),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedReligion = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a religion';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _phoneNumberController,
            decoration: InputDecoration(labelText: 'Phone Number'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _aadhaarNumberController,
            decoration: InputDecoration(labelText: 'Aadhaar Number'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter Aadhaar number';
              }
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: InputDecoration(labelText: 'Gender'),
            items: ['Male', 'Female'].map<DropdownMenuItem<String>>((gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _gender = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a gender';
              }
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            value: _maritalStatus,
            decoration: InputDecoration(labelText: 'Marital Status'),
            items: ['Married', 'Unmarried'].map<DropdownMenuItem<String>>((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _maritalStatus = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select marital status';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextFormField(
            controller: _attendantController,
            decoration: InputDecoration(labelText: 'Attendant Name'),
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter attendant name';
            //   }
            //   return null;
            // },
          ),
          TextFormField(
            controller: _attendantContactNumberController,
            decoration: InputDecoration(labelText: 'Attendant Contact Number'),
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter attendant contact number';
            //   }
            //   return null;
            // },
          ),
          DropdownButtonFormField<String>(
            value: _selectedState,
            decoration: InputDecoration(labelText: 'State'),
            items: _states.map<DropdownMenuItem<String>>((state) {
              return DropdownMenuItem<String>(
                value: state['stateId'].toString(),
                child: Text(state['stateName']),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedState = newValue;
                if (newValue != null) {
                  _fetchCities(int.parse(newValue));
                }
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a state';
              }
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            value: _selectedCity,
            decoration: InputDecoration(labelText: 'City'),
            items: _cities.map<DropdownMenuItem<String>>((city) {
              return DropdownMenuItem<String>(
                value: city['cityName'],
                child: Text(city['cityName']),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCity = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a city';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _areaController,
            decoration: InputDecoration(labelText: 'Area/Locality'),
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter area/locality';
            //   }
            //   return null;
            // },
          ),
          TextFormField(
            controller: _villageController,
            decoration: InputDecoration(labelText: 'Village/Town'),
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter village/town';
            //   }
            //   return null;
            // },
          ),
          TextFormField(
            controller: _relationWithPatientController,
            decoration: InputDecoration(labelText: 'Relation with Patient'),
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter relation with patient';
            //   }
            //   return null;
            // },
          ),
          TextFormField(
            controller: _emergencyContactNumberController,
            decoration: InputDecoration(labelText: 'Emergency Contact Number'),
            // validator: (value) {
            //   if (value == null || value.isEmpty) {
            //     return 'Please enter emergency contact number';
            //   }
            //   return null;
            // },
          ),

        ],
      ),
    );
  }
}
