import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    final url = Uri.parse("$baseUrl$endpoint");

    // Debug logs for requests
    print("URL: $url");
    print("BODY: ${data != null ? jsonEncode(data) : 'null'}");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
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
      throw Exception("Timeout occurred");
    } catch (e) {
      // Generic connection/reset or unexpected error
      print("Network error: $e");
      throw Exception("Connection reset");
    }
  }

  Future<http.Response> postMultipart(
    String endpoint, {
    required String filePath,
  }) async {
    final url = Uri.parse("$baseUrl$endpoint");

    // Debug log for multipart requests
    print("Calling API: $url");

    final request = http.MultipartRequest("POST", url);
    request.files.add(await http.MultipartFile.fromPath("image", filePath));

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}