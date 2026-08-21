import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samvya/models/transaction_model.dart';
import 'package:samvya/services/api_service.dart';

class TransactionService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  late final Dio _dio;

  TransactionService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiService.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json", "Accept": "application/json"},
      ),
    );
  }

  Future<String?> _getToken() async => await _storage.read(key: "jwt");

  /// Fetch all transactions; optionally filter by status: pending|approved|rejected|all and accountId
  Future<List<BankTransaction>> getTransactions({String status = 'all', String? accountId}) async {
    final token = await _getToken();
    if (token == null) return [];
    try {
      final queryParams = {"token": token, "status": status};
      if (accountId != null) {
        queryParams["account_id"] = accountId;
      }
      
      final response = await _dio.get(
        "/transactions",
        queryParameters: queryParams,
      );
      final List data = response.data;
      return data.map((e) => BankTransaction.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Create a new pending transaction
  Future<Map<String, dynamic>> createTransaction({
    required String senderAccountId,
    required String recipientName,
    required String recipientAccountNumber,
    String? recipientBank,
    required double amount,
    String? description,
  }) async {
    final token = await _getToken();
    if (token == null) return {"success": false, "message": "Not logged in."};
    try {
      final response = await _dio.post(
        "/transactions",
        queryParameters: {"token": token},
        data: jsonEncode({
          "sender_account_id": senderAccountId,
          "recipient_name": recipientName,
          "recipient_account_number": recipientAccountNumber,
          "recipient_bank": recipientBank,
          "amount": amount,
          "description": description,
        }),
      );
      return {"success": true, "transaction": BankTransaction.fromJson(response.data)};
    } on DioException catch (e) {
      return {"success": false, "message": e.response?.data?["detail"] ?? "Failed to create transaction."};
    }
  }

  /// Approve a pending transaction
  Future<bool> approveTransaction(String txnId) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      await _dio.patch("/transactions/$txnId/approve", queryParameters: {"token": token});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Reject a pending transaction
  Future<bool> rejectTransaction(String txnId) async {
    final token = await _getToken();
    if (token == null) return false;
    try {
      await _dio.patch("/transactions/$txnId/reject", queryParameters: {"token": token});
      return true;
    } catch (_) {
      return false;
    }
  }
}
