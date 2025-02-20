import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'network_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final connectivityService = ref.read(connectivityServiceProvider);
  return ApiService(connectivityService);
});

class ApiService {
  final ConnectivityService _connectivityService;

  ApiService(this._connectivityService);

  // Helper function for GET requests
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? headers}) async {
    try {
      // Check internet before making request
      bool isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        throw Exception("No Internet Connection");
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: headers ?? _defaultHeaders(),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Helper function for POST requests
  Future<dynamic> post(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    try {
      // Check internet before making request
      bool isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        throw Exception("No Internet Connection");
      }

      final response = await http.post(
        Uri.parse(endpoint),
        headers: headers ?? _defaultHeaders(),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Default headers for requests
  Map<String, String> _defaultHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Handle the HTTP response
  dynamic _handleResponse(http.Response response) {
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    switch (response.statusCode) {
      case 200:
      case 201:
        return json.decode(response.body);
      case 204:
        return null;
      case 400:
        throw Exception('Bad Request: ${response.body}');
      case 401:
        throw Exception('Unauthorized: ${response.body}');
      case 403:
        throw Exception('Forbidden: ${response.body}');
      case 404:
        throw Exception('Not Found: ${response.body}');
      case 500:
        throw Exception('Internal Server Error: ${response.body}');
      default:
        throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // Handle errors and check for connectivity
  dynamic _handleError(dynamic error) {
    print('Error Occurred: $error');

    if (error is http.ClientException) {
      print('Network Error:${error.message}');
      throw Exception("No Internet Connection");
    } else if (error is http.ClientException) {
      print('Network Error: ${error.message}');
      throw Exception('Network error: ${error.message}');
    } else if (error is FormatException) {
      print('Data Parsing Error: ${error.message}');
      throw Exception('Data parsing error: ${error.message}');
    } else {
      print('Unexpected Error: $error');
      throw Exception(error);
    }
  }
}
