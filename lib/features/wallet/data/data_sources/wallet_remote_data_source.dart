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
}
