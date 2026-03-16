import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://appskilltest.zybotech.in';

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ─── Debug Logging ──────────────────────────────────────────────────

  static final _prettyJson = const JsonEncoder.withIndent('  ');

  void _logRequest(String method, String endpoint, {Object? body}) {
    debugPrint('═══════════════════════════════════════════');
    debugPrint('DEBUG: API REQUEST');
    debugPrint('Method: $method');
    debugPrint('Endpoint: $endpoint');
    final safeHeaders = Map<String, String>.from(_headers);
    if (safeHeaders.containsKey('Authorization')) {
      safeHeaders['Authorization'] = 'Bearer ***';
    }
    debugPrint('Headers: $safeHeaders');
    if (body != null) {
      debugPrint('Body: ${_prettyJson.convert(body)}');
    }
    debugPrint('═══════════════════════════════════════════');
  }

  Map<String, dynamic> _logResponse(String endpoint, http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    debugPrint('───────────────────────────────────────────');
    debugPrint('DEBUG: API RESPONSE');
    debugPrint('Endpoint: $endpoint');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Response: ${_prettyJson.convert(decoded)}');
    debugPrint('───────────────────────────────────────────');
    return decoded;
  }

  void _logError(String endpoint, Object error) {
    debugPrint('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    debugPrint('DEBUG: API ERROR');
    debugPrint('Endpoint: $endpoint');
    debugPrint('Error: $error');
    debugPrint('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
  }

  // ─── Auth ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    const endpoint = '/auth/send-otp/';
    final body = {'phone': phone};
    _logRequest('POST', endpoint, body: body);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _logResponse(endpoint, response);
    } catch (e) {
      _logError(endpoint, e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createAccount(String phone, String nickname) async {
    const endpoint = '/auth/create-account/';
    final body = {'phone': phone, 'nickname': nickname};
    _logRequest('POST', endpoint, body: body);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _logResponse(endpoint, response);
    } catch (e) {
      _logError(endpoint, e);
      rethrow;
    }
  }

  // ─── Categories ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCategories() async {
    const endpoint = '/categories/';
    _logRequest('GET', endpoint);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _logResponse(endpoint, response);
    } catch (e) {
      _logError(endpoint, e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addCategory(Map<String, dynamic> categoryJson) async {
    const endpoint = '/categories/add/';
    _logRequest('POST', endpoint, body: categoryJson);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(categoryJson),
      );
      return _logResponse(endpoint, response);
    } catch (e) {
      _logError(endpoint, e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteCategories(List<String> ids) async {
    const endpoint = '/categories/delete/';
    final body = {'ids': ids};
    _logRequest('DELETE', endpoint, body: body);
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _logResponse(endpoint, response);
    } catch (e) {
      _logError(endpoint, e);
      rethrow;
    }
  }

  // ─── Transactions ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTransactions() async {
    const endpoint = '/transactions/';
    _logRequest('GET', endpoint);
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _logResponse(endpoint, response);
    } catch (e) {
      _logError(endpoint, e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addTransactions(List<Map<String, dynamic>> transactions) async {
    const endpoint = '/transactions/add/';
    final body = {'transactions': transactions};
    _logRequest('POST', endpoint, body: body);
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _logResponse(endpoint, response);
    } catch (e) {
      _logError(endpoint, e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteTransactions(List<String> ids) async {
    const endpoint = '/transactions/delete/';
    final body = {'ids': ids};
    _logRequest('DELETE', endpoint, body: body);
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _logResponse(endpoint, response);
    } catch (e) {
      _logError(endpoint, e);
      rethrow;
    }
  }
}
