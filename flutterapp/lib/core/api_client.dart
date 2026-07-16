import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_service.dart';
import 'constants.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String get baseUrl => kApiBaseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await StorageService.instance.getToken();
    return {'Content-Type': 'application/json', if (token != null) 'Authorization': 'Bearer $token'};
  }

  Future<http.Response> get(String path) async {
    final headers = await _headers();
    return http.get(Uri.parse('$kApiBaseUrl$path'), headers: headers);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final headers = await _headers();
    return http.post(Uri.parse('$kApiBaseUrl$path'), headers: headers, body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) async {
    final headers = await _headers();
    return http.delete(Uri.parse('$kApiBaseUrl$path'), headers: headers);
  }
}
