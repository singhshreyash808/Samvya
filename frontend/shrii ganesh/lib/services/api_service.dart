import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ===========================
  // CHANGE YOUR IP HERE
  // ===========================

  static const String baseUrl = "http://192.168.15.214:8000";

  static const FlutterSecureStorage storage = FlutterSecureStorage();

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // Automatically attach JWT to every request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.read(key: "jwt");

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          handler.next(options);
        },
      ),
    );
  }

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // ===========================
  // REGISTER
  // ===========================

  Future<Map<String, dynamic>> register(
      Map<String, dynamic> data) async {

    try {

      print("REGISTER REQUEST");
      print(data);

      Response response = await _dio.post(
        "/auth/register",
        data: data,
      );

      final result = Map<String, dynamic>.from(response.data);

      if (result["success"] == true && result["token"] != null) {
        await storage.write(
          key: "jwt",
          value: result["token"],
        );
      }

      print("REGISTER SUCCESS");
      print(result);

      return result;

    } on DioException catch (e) {

      print("STATUS CODE: ${e.response?.statusCode}");
      print("ERROR DATA:");
      print(e.response?.data);

      String errorMessage = "Registration failed. Please try again.";
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Connection to server failed. Please check your internet or server IP address.";
      } else if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data["detail"] != null) {
          errorMessage = data["detail"].toString();
        } else if (data is String && data.isNotEmpty) {
          errorMessage = data;
        } else {
          errorMessage = "Server error (${e.response?.statusCode}). Please try again.";
        }
      }

      return {
        "success": false,
        "message": errorMessage,
      };

    } catch (e) {

      print(e);

      return {
        "success": false,
        "message": "Registration failed. Please check your connection.",
      };

    }

  }

  // ===========================
  // LOGIN
  // ===========================

  Future<Map<String, dynamic>> login(
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        "/auth/login",
        data: jsonEncode(data),
      );

      final result =
      Map<String, dynamic>.from(response.data);

      if (result["success"] == true &&
          result["token"] != null) {
        await storage.write(
          key: "jwt",
          value: result["token"],
        );

        // Save user info so profile screen can show real name
        final prefs = await _getPrefs();
        if (result["full_name"] != null) {
          await prefs.setString("name", result["full_name"]);
        }
        if (result["mobile"] != null) {
          await prefs.setString("mobile", result["mobile"]);
        }
        if (result["email"] != null) {
          await prefs.setString("email", result["email"]);
        }
        await prefs.setBool("registered", true);
      }

      return result;

    } on DioException catch (e) {
      String errorMessage = "Login Failed";
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = "Connection to server failed. Please check your internet or server IP address.";
      } else if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data["detail"] != null) {
          errorMessage = data["detail"].toString();
        } else if (data is String && data.isNotEmpty) {
          errorMessage = data;
        } else {
          errorMessage = "Server error (${e.response?.statusCode}). Please try again.";
        }
      }

      return {
        "success": false,
        "message": errorMessage,
      };
    }
  }

  // ===========================
  // CHECK DEVICE STATUS
  // ===========================

  Future<Map<String, dynamic>> checkDeviceStatus(
      String requestId) async {
    try {
      final response = await _dio.post(
        "/auth/check-device-status",
        data: jsonEncode({
          "request_id": requestId,
        }),
      );

      final result =
      Map<String, dynamic>.from(response.data);

      if (result["approved"] == true &&
          result["token"] != null) {
        await storage.write(
          key: "jwt",
          value: result["token"],
        );

        // Save user info so profile screen can show real name
        final prefs = await _getPrefs();
        if (result["full_name"] != null) {
          await prefs.setString("name", result["full_name"]);
        }
        if (result["mobile"] != null) {
          await prefs.setString("mobile", result["mobile"]);
        }
        if (result["email"] != null) {
          await prefs.setString("email", result["email"]);
        }
        await prefs.setBool("registered", true);
      }

      return result;

    } on DioException catch (e) {
      return {
        "success": false,
        "approved": false,
        "message":
        e.response?.data["detail"] ??
            "Unable to check device status",
      };
    }
  }

  // ===========================
  // APPROVE DEVICE
  // ===========================

  Future<Map<String, dynamic>> approveDevice(
      String deviceUuid) async {
    try {
      final token = await storage.read(key: "jwt");
      final response = await _dio.post(
        "/auth/approve-device",
        queryParameters: token != null ? {"token": token} : {},
        data: jsonEncode({
          "device_uuid": deviceUuid,
        }),
      );

      return Map<String, dynamic>.from(response.data);

    } on DioException catch (e) {
      return {
        "success": false,
        "message":
        e.response?.data["detail"] ??
            "Unable to approve device",
      };
    }
  }

  // ===========================
  // REJECT DEVICE
  // ===========================

  Future<Map<String, dynamic>> rejectDevice(
      String deviceUuid) async {
    try {
      final token = await storage.read(key: "jwt");
      final response = await _dio.post(
        "/auth/reject-device",
        queryParameters: token != null ? {"token": token} : {},
        data: jsonEncode({
          "device_uuid": deviceUuid,
        }),
      );

      return Map<String, dynamic>.from(response.data);

    } on DioException catch (e) {
      return {
        "success": false,
        "message":
        e.response?.data["detail"] ??
            "Unable to reject device",
      };
    }
  }

  // ===========================
  // PENDING DEVICE APPROVALS
  // ===========================

  Future<Map<String, dynamic>> getPendingDevices() async {
    try {
      final token = await storage.read(key: "jwt");

      if (token == null) {
        return {
          "success": false,
          "pending": [],
          "count": 0,
          "message": "Not logged in. Please login first."
        };
      }

      final response = await _dio.get(
        "/devices/pending",
        queryParameters: {"token": token},
      );

      return Map<String, dynamic>.from(response.data);

    } on DioException catch (e) {
      String msg = "Failed to load pending devices";
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        msg = "Cannot connect to server. Check IP address or internet connection.";
      } else if (e.response != null &&
          e.response?.data is Map &&
          e.response?.data["detail"] != null) {
        msg = e.response!.data["detail"].toString();
      }
      return {
        "success": false,
        "pending": [],
        "count": 0,
        "message": msg,
      };
    }
  }

  // ===========================
  // ALL DEVICES
  // ===========================

  Future<Map<String, dynamic>> getAllDevices() async {
    try {
      final token = await storage.read(key: "jwt");

      if (token == null) {
        return {
          "success": false,
          "devices": [],
          "count": 0,
          "message": "Not logged in. Please login first."
        };
      }

      final response = await _dio.get(
        "/devices/all",
        queryParameters: {"token": token},
      );

      return Map<String, dynamic>.from(response.data);

    } on DioException catch (e) {
      String msg = "Failed to load connected devices";
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.receiveTimeout) {
        msg = "Cannot connect to server. Check your IP address or internet connection.";
      } else if (e.response != null &&
          e.response?.data is Map &&
          e.response?.data["detail"] != null) {
        msg = e.response!.data["detail"].toString();
      }
      return {
        "success": false,
        "devices": [],
        "count": 0,
        "message": msg,
      };
    }
  }

  // ===========================
  // TOKEN
  // ===========================

  Future<String?> getToken() async {
    return await storage.read(key: "jwt");
  }

  Future<bool> isLoggedIn() async {
    return await storage.read(key: "jwt") != null;
  }

  Future<void> logout() async {
    await storage.deleteAll();
  }

  // ===========================
  // VOICE ASSISTANT
  // ===========================

  Future<Map<String, dynamic>> queryAssistant(String queryText, String languageCode) async {
    try {
      final token = await storage.read(key: "jwt");
      final response = await _dio.post(
        "/assistant/query",
        queryParameters: token != null ? {"token": token} : {},
        data: jsonEncode({"query": queryText, "language": languageCode}),
      );

      final result = Map<String, dynamic>.from(response.data);
      return result;
    } on DioException catch (e) {
      print("Assistant Error: ${e.response?.data}");
      return {
        "success": false,
        "response": "Unable to connect to the assistant server."
      };
    }
  }
}