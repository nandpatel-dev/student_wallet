import 'package:dio/dio.dart';
import 'package:student_app/core/constants/api_constants.dart';
import 'package:student_app/features/wallet/data/models/wallet_cert_model.dart';

class WalletRemoteDataSource {
  final Dio dio = Dio();

  Future<WalletData> fetchWallet(String token) async {
    try {
      final response = await dio.get(
        ApiConstants.me,
        options: Options(
          headers: {'x-student-wallet': token},
        ),
      );

      if (response.data['success'] == true) {
        return WalletData.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch wallet info');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        throw Exception('Unauthorized');
      }
      rethrow;
    }
  }

  Future<String> getShareableUrl(String token, String certId) async {
    try {
      final response = await dio.post(
        ApiConstants.shareCertificate(certId),
        options: Options(
          headers: {'x-student-wallet': token},
        ),
      );

      print('VERIFY API RESPONSE: \${response.data}');

      // Handle both wrapped {success: true, data: {url: ...}} and direct {shareUrl: ...} responses
      if (response.data is Map) {
        final data = response.data;
        String? finalUrl;

        if (data['success'] == true) {
          final innerData = data['data'];
          if (innerData is String) finalUrl = innerData;
          else if (innerData is Map) {
            finalUrl = innerData['url'] ?? innerData['shareUrl'] ?? innerData['verifyUrl'] ?? innerData.toString();
          }
        } else if (data['shareUrl'] != null || data['url'] != null || data['verifyUrl'] != null) {
           finalUrl = data['shareUrl'] ?? data['url'] ?? data['verifyUrl'];
        }

        if (finalUrl != null) {
          // If the backend returns localhost or anything that looks like internal address, attempt rewrite if it's on the same subnet
          if (finalUrl.contains('localhost')) {
             finalUrl = finalUrl.replaceAll('localhost', '192.168.1.3');
          } else if (finalUrl.contains('127.0.0.1')) {
             finalUrl = finalUrl.replaceAll('127.0.0.1', '192.168.1.3');
          }
          return finalUrl;
        }
        
        throw Exception(data['message'] ?? 'Failed to get shareable URL. Response: $data');
      }

      throw Exception('Unexpected response format: ${response.data}');
    } catch (e) {
      if (e is DioException) {
         print('SHARE CERT API ERROR: ${e.response?.data}');
         if (e.response?.statusCode == 401) {
           throw Exception('Unauthorized');
         }
      }
      rethrow;
    }
  }
}
