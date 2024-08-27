class AppConfig {

  static const String apiUrl1 = 'http://192.168.1.179:8081/api';
  // static const String apiUrl1 = 'http://192.168.1.179:8080/api';

  // Patient Registration Endpoints
  static const String patientRegistrationStateEndpoint = '/HospitalApp/GetState';
  static const String patientRegistrationGetCitiesByStateEndpoint = '/HospitalApp/GetCityByState';
  static const String patientRegistrationGetReligionsEndpoint = '/HospitalApp/GetReligions';

  // Homepage Endpoints
  static const String superspecialityEndpoint = '/HospitalApp/Superspecialitytitles';
  static const String specialityEndpoint = '/HospitalApp/Specialitytitles';

  // Login Endpoints
  static const String patientLoginEndpoint = '/HospitalApp/PatientLogin';

  // Feedback Endpoints
  static const String patientfeedbackEndpoint = '/HospitalApp/GetHospitalAppFeedback';

  // Patient Endpoints
  static const String getPatientByIdEndpoint = '/HospitalApp/GetPatientById';
  // Doctors Endpoints
  static const String getDoctorsBySpecializationEndpoint = '/HospitalApp/GetDoctorsBySpecialization';
}
