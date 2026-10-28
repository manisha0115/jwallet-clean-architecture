
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl}) {
    debugPrint('ApiClient created with baseUrl: "$baseUrl"');
  }

  final String baseUrl;
  final http.Client client = http.Client();

  Future<dynamic> post(
      String path, {
        Map<String, String>? headers,
        Map<String, dynamic>? params,
      }) async {
    debugPrint('BASE URL = "$baseUrl"');
    debugPrint('API PATH = "$path"');
    final uri = Uri.parse(
      '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}'
          '${path.startsWith('/') ? path.substring(1) : path}',
    );

    final requestHeaders = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      ...?headers,
    };

    final requestBody = jsonEncode(params ?? <String, dynamic>{});

    // API request logs
    debugPrint('========== API REQUEST ==========');
    debugPrint('Method: POST');
    debugPrint('URL: $uri');
    debugPrint('Headers: ${requestHeaders.keys.toList()}');
    debugPrint('Body: $requestBody');

    try {
      final response = await client.post(
        uri,
        headers: requestHeaders,
        body: requestBody,
      );

      debugPrint('========== API RESPONSE ==========');
      debugPrint('URL: $uri');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      dynamic responseData;

      try {
        responseData = jsonDecode(response.body);
      } on FormatException {
        throw Exception(
          'Invalid JSON response. HTTP ${response.statusCode}: '
              '${response.body}',
        );
      }

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return responseData;
      }

      final message = responseData is Map
          ? responseData['message']?.toString()
          : null;

      throw Exception(
        message ?? 'Request failed: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('========== API ERROR ==========');
      debugPrint('URL: $uri');
      debugPrint('Error: $e');
      rethrow;
    }
  }

  Future<dynamic> get(
      String path, {
        Map<String, String>? headers,
      }) async {
    final uri = Uri.parse(
      '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}'
          '${path.startsWith('/') ? path.substring(1) : path}',
    );

    debugPrint('========== API REQUEST ==========');
    debugPrint('Method: GET');
    debugPrint('URL: $uri');

    try {
      final response = await client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          ...?headers,
        },
      );

      debugPrint('========== API RESPONSE ==========');
      debugPrint('URL: $uri');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      final dynamic responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return responseData;
      }

      final message = responseData is Map
          ? responseData['message']?.toString()
          : null;

      throw Exception(
        message ?? 'Request failed: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('========== API ERROR ==========');
      debugPrint('URL: $uri');
      debugPrint('Error: $e');
      rethrow;
    }
  }

  void dispose() {
    client.close();
  }
}
