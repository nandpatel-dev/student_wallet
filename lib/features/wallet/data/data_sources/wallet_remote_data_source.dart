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
        final data = WalletData.fromJson(response.data['data']);
        
        // Fix localhost URLs for all certificates so they work on mobile
        // Dynamically get host (e.g., 192.168.1.3) from ApiConstants.baseUrl
        final serverIp = Uri.tryParse(ApiConstants.baseUrl)?.host ?? '192.168.1.4';
        
        for (var cert in data.certificates) {
          // This ensures that the URLs provided by the server are actually reachable
          cert.updateUrls(serverIp);
        }
        
        return data;
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
        data: {}, // Some servers require an empty body for POST
        options: Options(
          headers: {'x-student-wallet': token},
          validateStatus: (s) => s != null && s < 500, // Handle non-200 responses gracefully
        ),
      );

      print('VERIFY API RESPONSE: ${response.data}');

      // Handle common response formats
      if (response.data is Map) {
        final data = response.data;
        String? finalUrl;

        // Check for common URL fields directly or in 'data' wrapper
        if (data['success'] == true && data['data'] != null) {
          final inner = data['data'];
          if (inner is String) {
            finalUrl = inner;
          } else if (inner is Map) {
            finalUrl = inner['url'] ?? inner['shareUrl'] ?? inner['verifyUrl'];
          }
        } else {
          // Fallback to direct fields
          finalUrl = data['shareUrl'] ?? data['url'] ?? data['verifyUrl'];
        }

        if (finalUrl != null && finalUrl is String) {
          // Dynamically get host (e.g., 192.168.1.3) from ApiConstants.baseUrl
          final serverIp = Uri.tryParse(ApiConstants.baseUrl)?.host ?? '192.168.1.4';
          
          if (finalUrl.contains('localhost')) {
             finalUrl = finalUrl.replaceAll('localhost', serverIp);
          } else if (finalUrl.contains('127.0.0.1')) {
             finalUrl = finalUrl.replaceAll('127.0.0.1', serverIp);
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
