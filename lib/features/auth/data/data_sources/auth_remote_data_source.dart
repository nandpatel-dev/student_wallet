import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:student_app/core/constants/api_constants.dart';

class AuthRemoteDataSource {
  final Dio dio = Dio();

  Future<bool> requestOtp(String email) async {
    try {
      final response = await dio.post(
        ApiConstants.requestOtp,
        data: {'email': email},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    try {
      final response = await dio.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otp': otp},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.data['success'] == true) {
        return response.data['data']['sessionToken'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> exchangeAppToken(String appToken) async {
    try {
      final response = await dio.post(
        ApiConstants.exchangeAppToken,
        data: {'appToken': appToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['sessionToken'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
