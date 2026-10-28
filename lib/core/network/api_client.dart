
import 'dart:convert';

import 'package:http/http.dart' as http;


class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  final http.Client client = http.Client();

  Future<dynamic> post(
      String path, {
        Map<String, String>? headers,
        Map<String, dynamic>? params,
      }) async {
    final uri = Uri.parse(
      '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}'
          '${path.startsWith('/') ? path.substring(1) : path}',
    );

    final response = await client.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        ...?headers,
      },
      body: jsonEncode(params ?? <String, dynamic>{}),
    );

    final dynamic responseData =
    jsonDecode(response.body);

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
  }


  Future<dynamic> get(
      String path, {
        Map<String, String>? headers,
      }) async {
    final uri = Uri.parse(
      '${baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'}'
          '${path.startsWith('/') ? path.substring(1) : path}',
    );

    final response = await client.get(
      uri,
      headers: {
        'Accept': 'application/json',
        ...?headers,
      },
    );

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
  }


  void dispose() {
    client.close();
  }
}
