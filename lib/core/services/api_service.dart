import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    baseUrl = ApiConfig.getBaseUrl();
    print("API Base URL: $baseUrl");
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse("$baseUrl$endpoint");

    // Debug logs for requests
    print("POST $url");
    print("BODY: ${data != null ? jsonEncode(data) : 'null'}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Request timeout');
        },
      );

      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");

      return response;
    } on SocketException {
      // Backend not reachable / no network
      print("Network error: Backend not reachable");
      throw Exception("Backend not reachable");
    } on TimeoutException {
      // Request timed out
      print("Network error: Timeout occurred");
      throw Exception("Request timeout");
    } catch (e) {
      // Generic connection/reset or unexpected error
      print("Network error: $e");
      throw Exception("Connection error: $e");
    }
  }

  Future<http.Response> postMultipart(
    String endpoint, {
    required String filePath,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");

    // Debug log for multipart requests
    print("POST Multipart $url");
    print("File: $filePath");

    try {
      final request = http.MultipartRequest("POST", url);
      request.files.add(await http.MultipartFile.fromPath("image", filePath));

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException("Multipart request timeout");
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      print("STATUS: ${response.statusCode}");
      print("RESPONSE: ${response.body}");
      return response;
    } on SocketException {
      print("Network error: Backend not reachable");
      throw Exception("Backend not reachable");
    } on TimeoutException {
      print("Network error: Timeout occurred");
      throw Exception("Request timeout");
    } catch (e) {
      print("Network error: $e");
      throw Exception("Connection error: $e");
    }
  }
}