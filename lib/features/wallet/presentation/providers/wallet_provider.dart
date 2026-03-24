import 'package:flutter/material.dart';
import 'package:student_app/core/services/secure_storage_service.dart';
import 'package:student_app/features/wallet/data/data_sources/wallet_remote_data_source.dart';
import 'package:student_app/features/wallet/data/models/wallet_cert_model.dart';
import 'package:student_app/features/auth/data/data_sources/auth_remote_data_source.dart';

class WalletProvider with ChangeNotifier {
  final WalletRemoteDataSource _walletDataSource = WalletRemoteDataSource();
  final AuthRemoteDataSource _authDataSource = AuthRemoteDataSource();
  final SecureStorageService _storageService = SecureStorageService();

  WalletData? _walletData;
  bool _isLoading = false;
  String? _error;

  WalletData? get walletData => _walletData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWallet() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token != null) {
        _walletData = await _walletDataSource.fetchWallet(token);
      } else {
        _error = 'No token found';
      }
    } catch (e) {
      _error = e.toString();
      if (_error!.contains('Unauthorized')) {
        await _storageService.deleteToken();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendOtp(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authDataSource.requestOtp(email);
      if (!success) {
        _error = 'Failed to send OTP';
      }
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authDataSource.verifyOtp(email, otp);
      if (token != null) {
        await _storageService.saveToken(token);
        await loadWallet();
        return true;
      } else {
        _error = 'Invalid OTP';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> handleDeepLink(String appToken) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final sessionToken = await _authDataSource.exchangeAppToken(appToken);
      if (sessionToken != null) {
        await _storageService.saveToken(sessionToken);
        await loadWallet();
        return true;
      } else {
        _error = 'Token expired or already used';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storageService.deleteToken();
    _walletData = null;
    notifyListeners();
  }

  Future<String?> getShareableUrl(String certId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception('No token found');
      final url = await _walletDataSource.getShareableUrl(token, certId);
      return url;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
