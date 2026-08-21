import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samvya/models/bank_account_model.dart';
import 'package:samvya/services/api_service.dart';

class BankAccountService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  late final Dio _dio;

  BankAccountService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiService.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
      ),
    );
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: "jwt");
  }

  /// Fetch all bank accounts for the current user
  Future<List<BankAccount>> getAccounts() async {
    final token = await _getToken();
    if (token == null) return [];
    try {
      final response = await _dio.get(
        "/accounts",
        queryParameters: {"token": token},
      );
      final List data = response.data;
      return data.map((e) => BankAccount.fromJson(e)).toList();
    } on DioException {
      // Return empty on network error (offline handled in UI)
      return [];
    }
  }

  /// Add a new bank account
  Future<Map<String, dynamic>> addAccount({
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required String phoneNumber,
    required String tpin,
  }) async {
    final token = await _getToken();
    if (token == null) return {"success": false, "message": "Not logged in."};
    try {
      final response = await _dio.post(
        "/accounts",
        queryParameters: {"token": token},
        data: jsonEncode({
          "bank_name": bankName,
          "account_number": accountNumber,
          "ifsc_code": ifscCode,
          "account_holder_name": accountHolderName,
          "phone_number": phoneNumber,
          "tpin": tpin,
        }),
      );
      return {"success": true, "account": BankAccount.fromJson(response.data)};
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"] ?? "Failed to add account.";
      return {"success": false, "message": detail};
    }
  }

  /// Verify TPIN for a specific account
  Future<Map<String, dynamic>> verifyTpin(String accountId, String tpin) async {
    final token = await _getToken();
    if (token == null) return {"success": false, "message": "Not logged in."};
    try {
      await _dio.post(
        "/accounts/$accountId/verify-tpin",
        queryParameters: {"token": token},
        data: jsonEncode({"tpin": tpin}),
      );
      return {"success": true};
    } on DioException catch (e) {
      final detail = e.response?.data?["detail"] ?? "Incorrect TPIN.";
      return {"success": false, "message": detail};
    }
  }

  /// Delete a bank account
  Future<bool> deleteAccount(String accountId) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      await _dio.delete("/accounts/$accountId", queryParameters: {"token": token});
      return true;
    } catch (_) {
      return false;
    }
  }
}
