class AppConfig {
  static const String apiUrl1 = 'http://192.168.1.109:8081/api';

  // Patient Registration Endpoints
  static const String getStateEndpoint = '/HospitalApp/GetState';
  static const String patientRegistrationGetCitiesByStateEndpoint = '/HospitalApp/GetCityByState';
  static const String patientRegistrationGetReligionsEndpoint = '/HospitalApp/GetReligions';

  // Homepage Endpoints
  static const String specialityEndpoint = '/HospitalApp/Specialitytitles';

  // Login Endpoints
  static const String patientLoginEndpoint = '/HospitalApp/PatientLogin';

  // Feedback Endpoints
  static const String patientFeedbackEndpoint = '/HospitalApp/HospitalAppFeedback';

  // Patient Details Endpoints
  static const String getPatientByIdEndpoint = '/HospitalApp/GetPatientById';

  // New Endpoint for Save/Update Patient Image
  static const String saveOrUpdatePatientImageEndpoint = '/HospitalApp/SaveOrUpdatePatientImage';

  // Doctors Endpoints
  static const String getDoctorsBySpecializationEndpoint = '/HospitalApp/GetDoctorsBySpecialization';
  static const String getUnitDetailsEndpoint = '/HospitalApp/GetUnitDetails';

  // Billing Endpoints lab
  static const String getBillingByPatientIdEndpoint = '/Pharma/GetBillingByPatientId';
  static const String getServiceByBillNoEndpoint = '/Pharma/GetServiceByBillNo';
  static const String getDoctorDataEndpoint = '/HospitalApp/GetDoctorData';

  // Patient Details Endpoints
  static const String getIpidWithImageEndpoint = '/HospitalApp/GetIpidWithImeage';
  static const String getOpdByPatientIdEndpoint = '/HospitalApp/GetOpdByPatientId';
  static const String getPatientReportByIPIDEndpoint = '/HospitalApp/GetPatientReportByIPID';
  static const String getPatientReportByOPDEndpoint = '/HospitalApp/GetPatientReportByOPD';

  // lab Endpoints
  static const String getServiceInvestigationEndpoint = '/Pharma/GetServiceInvestigation';
  // New Lab Endpoint Post
  static const String addInvestigationEndpoint = '/Pharma/AddInvestigation';

  // New Endpoint for Fetching Medicines
  static const String getPharmaItemsEndpoint = '/Pharma/GetPharmaItems';

  // New Endpoint for Adding Pharma Items(Post)
  static const String addPharmaItemsEndpoint = '/Pharma/AddPharmaItems';

  // New Endpoint for Fetching Pharmacy Orders by Patient ID
  static const String getRequisitionByPatientIdEndpoint = '/Pharma/GetRequisitionByPatientId';

  // New Endpoint for Fetching Patient Details by ID
  static const String getPatientDetailsByIdEndpoint = '/HospitalApp/GetPatientById';

  // New OPD Registration Endpoint
  static const String opdRegistrationEndpoint = '/HospitalApp/OpdRegistration';

  // New Patient Registration App Endpoint
  static const String patientRegistrationAppEndpoint = '/HospitalApp/PatientRegistrationApp';


}
