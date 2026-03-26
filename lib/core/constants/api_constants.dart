class ApiConstants {
  // Use '10.0.2.2' for Android Emulator, or your Local IP (192.168.x.x) for Physical Devices
  static const String baseUrl = 'http://192.168.1.21:3000/api';

  
  // Wallet Endpoints
  static const String requestOtp = '$baseUrl/student-wallet/request-otp';
  static const String verifyOtp = '$baseUrl/student-wallet/verify-otp';
  static const String exchangeAppToken = '$baseUrl/student-wallet/exchange-app-token';
  static const String me = '$baseUrl/student-wallet/me';
  static const String session = '$baseUrl/student-wallet/session';
  static const String certificates = '$baseUrl/student-wallet/certificates';
  static String shareCertificate(String id) => '$certificates/$id/share';
  static String downloadCertificate(String id) => '$certificates/$id/download';
  static String viewCertificate(String id) => '$certificates/$id/view';
}
