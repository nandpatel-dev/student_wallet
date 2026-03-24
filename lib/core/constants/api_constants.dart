class ApiConstants {
  static const String baseUrl = 'http://192.168.1.3:3000/api';
  
  // Wallet Endpoints
  static const String requestOtp = '$baseUrl/student-wallet/request-otp';
  static const String verifyOtp = '$baseUrl/student-wallet/verify-otp';
  static const String exchangeAppToken = '$baseUrl/student-wallet/exchange-app-token';
  static const String me = '$baseUrl/student-wallet/me';
  static const String session = '$baseUrl/student-wallet/session';
  static const String certificates = '$baseUrl/student-wallet/certificates';
  static String shareCertificate(String id) => '$certificates/$id/share';
}
