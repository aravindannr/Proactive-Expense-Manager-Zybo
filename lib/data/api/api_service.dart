import 'dart:convert';
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

  // ─── Auth ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/send-otp/'),
      headers: _headers,
      body: jsonEncode({'phone': phone}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createAccount(String phone, String nickname) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/create-account/'),
      headers: _headers,
      body: jsonEncode({'phone': phone, 'nickname': nickname}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ─── Categories ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories/'),
      headers: _headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addCategory(Map<String, dynamic> categoryJson) async {
    final response = await http.post(
      Uri.parse('$baseUrl/categories/add/'),
      headers: _headers,
      body: jsonEncode(categoryJson),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteCategories(List<String> ids) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/categories/delete/'),
      headers: _headers,
      body: jsonEncode({'ids': ids}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // ─── Transactions ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/'),
      headers: _headers,
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> addTransactions(List<Map<String, dynamic>> transactions) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/add/'),
      headers: _headers,
      body: jsonEncode({'transactions': transactions}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> deleteTransactions(List<String> ids) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/delete/'),
      headers: _headers,
      body: jsonEncode({'ids': ids}),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
