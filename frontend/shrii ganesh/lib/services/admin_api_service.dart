import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samvya/services/api_service.dart';

class AdminApiService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  late final Dio _dio;

  AdminApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiService.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );
  }

  Future<String?> _getToken() async {
    return await _storage.read(key: "admin_jwt");
  }

  // 1. Admin Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        "/admin/auth/login",
        data: {"email": email, "password": password},
      );
      final result = Map<String, dynamic>.from(response.data);
      if (result["success"] == true && result["token"] != null) {
        await _storage.write(key: "admin_jwt", value: result["token"]);
        await _storage.write(key: "admin_email", value: email);
        if (result["admin"] != null) {
          await _storage.write(key: "admin_name", value: result["admin"]["full_name"] ?? "Admin");
          await _storage.write(key: "admin_role", value: result["admin"]["role"] ?? "OPERATIONS_OFFICER");
        }
      }
      return result;
    } on DioException catch (e) {
      return {
        "success": false,
        "detail": e.response?.data["detail"] ?? "Invalid credentials or backend unreachable"
      };
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: "admin_jwt");
    await _storage.delete(key: "admin_email");
    await _storage.delete(key: "admin_name");
    await _storage.delete(key: "admin_role");
  }

  Future<String?> getAdminName() async {
    return await _storage.read(key: "admin_name") ?? "Admin Officer";
  }

  Future<String?> getAdminRole() async {
    return await _storage.read(key: "admin_role") ?? "SUPER_ADMIN";
  }

  // 2. Dashboard Metrics
  Future<Map<String, dynamic>> getDashboard() async {
    final token = await _getToken();
    try {
      final response = await _dio.get("/admin/dashboard", queryParameters: {"token": token});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to fetch dashboard"};
    }
  }

  // 3. User Management
  Future<Map<String, dynamic>> getUsers({String? search}) async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        "/admin/users",
        queryParameters: {"token": token, if (search != null && search.isNotEmpty) "search": search},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to fetch users"};
    }
  }

  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    final token = await _getToken();
    try {
      final response = await _dio.get("/admin/users/$userId", queryParameters: {"token": token});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to fetch user details"};
    }
  }

  Future<Map<String, dynamic>> toggleUserStatus(String userId, bool isActive) async {
    final token = await _getToken();
    try {
      final response = await _dio.patch(
        "/admin/users/$userId/status",
        queryParameters: {"token": token},
        data: {"is_active": isActive},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to update user status"};
    }
  }

  // 4. Transactions
  Future<Map<String, dynamic>> getTransactions({String? search}) async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        "/admin/transactions",
        queryParameters: {"token": token, if (search != null && search.isNotEmpty) "search": search},
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to fetch transactions"};
    }
  }

  // 5. Complaints
  Future<Map<String, dynamic>> getComplaints() async {
    final token = await _getToken();
    try {
      final response = await _dio.get("/admin/complaints", queryParameters: {"token": token});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to fetch complaints"};
    }
  }

  Future<Map<String, dynamic>> updateComplaint(String complaintId, Map<String, dynamic> data) async {
    final token = await _getToken();
    try {
      final response = await _dio.patch(
        "/admin/complaints/$complaintId",
        queryParameters: {"token": token},
        data: data,
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to update complaint"};
    }
  }

  // 6. Service Requests
  Future<Map<String, dynamic>> getServiceRequests() async {
    final token = await _getToken();
    try {
      final response = await _dio.get("/admin/requests", queryParameters: {"token": token});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to fetch service requests"};
    }
  }

  // 7. Risk & Fraud
  Future<Map<String, dynamic>> getRiskEvents() async {
    final token = await _getToken();
    try {
      final response = await _dio.get("/admin/risk/events", queryParameters: {"token": token});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to fetch risk events"};
    }
  }

  // 8. Security Events
  Future<Map<String, dynamic>> getSecurityEvents() async {
    final token = await _getToken();
    try {
      final response = await _dio.get("/admin/security/events", queryParameters: {"token": token});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to fetch security events"};
    }
  }

  // 9. Audit Logs
  Future<Map<String, dynamic>> getAuditLogs() async {
    final token = await _getToken();
    try {
      final response = await _dio.get("/admin/audit-logs", queryParameters: {"token": token});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to fetch audit logs"};
    }
  }

  // 10. Admin Users Management
  Future<Map<String, dynamic>> getAdmins() async {
    final token = await _getToken();
    try {
      final response = await _dio.get("/admin/admins", queryParameters: {"token": token});
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to fetch admins"};
    }
  }

  Future<Map<String, dynamic>> createAdmin(Map<String, dynamic> data) async {
    final token = await _getToken();
    try {
      final response = await _dio.post(
        "/admin/admins",
        queryParameters: {"token": token},
        data: data,
      );
      return Map<String, dynamic>.from(response.data);
    } on DioException catch (e) {
      return {"success": false, "detail": e.response?.data["detail"] ?? "Failed to create admin"};
    }
  }
}
