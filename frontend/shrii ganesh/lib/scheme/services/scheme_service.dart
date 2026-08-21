import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:samvya/scheme/models/scheme_model.dart';
import 'package:samvya/scheme/models/category_model.dart';
import 'package:samvya/services/api_service.dart'; // To reuse baseUrl if needed

class SchemeService {
  static const FlutterSecureStorage storage = FlutterSecureStorage();
  late final Dio _dio;

  SchemeService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiService.baseUrl + "/api/v1",
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // Attach JWT to every request
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

  Future<List<SchemeCategory>> getCategories() async {
    try {
      final response = await _dio.get("/schemes/categories");
      List data = response.data;
      return data.map((e) => SchemeCategory.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
  }

  Future<List<GovernmentScheme>> getSchemes({String? categoryId, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get("/schemes/", queryParameters: queryParams);
      List data = response.data;
      return data.map((e) => GovernmentScheme.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching schemes: $e");
      return [];
    }
  }

  Future<List<GovernmentScheme>> getRecommendations() async {
    try {
      final response = await _dio.get("/recommendations/");
      List data = response.data;
      return data.map((e) => GovernmentScheme.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching recommendations: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> chatWithAssistant(String queryText) async {
    try {
      final response = await _dio.post(
        "/scheme-assistant/chat",
        data: jsonEncode({"query": queryText}),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      print("Error in scheme assistant: $e");
      return {
        "response": "Sorry, I am unable to connect to the recommendation engine right now.",
        "tags_detected": [],
        "schemes_count": 0
      };
    }
  }
}
