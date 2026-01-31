import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String defaultBaseUrl = 'https://court-hub-tuesday-asp.trycloudflare.com';
  late http.Client _httpClient;
  String? _baseUrl;
  String? _jwtToken;

  ApiService() {
    _httpClient = http.Client();
  }

  Future<String> get baseUrl async {
    if (_baseUrl != null) return _baseUrl!;
    
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? defaultBaseUrl;
    return _baseUrl!;
  }

  void setAuthToken(String? token) {
    _jwtToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
  };

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = await baseUrl;
    final response = await _httpClient.post(
      Uri.parse('$url/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Login failed');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password, String passwordConfirm) async {
    final url = await baseUrl;
    final response = await _httpClient.post(
      Uri.parse('$url/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'password_confirm': passwordConfirm}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Registration failed');
    }
  }

  Future<bool> logout() async {
    final url = await baseUrl;
    final response = await _httpClient.post(
      Uri.parse('$url/api/auth/logout'),
      headers: _headers,
    );
    return response.statusCode == 200;
  }

  Future<List<dynamic>> getAvailableSlots() async {
    final url = await baseUrl;
    final response = await _httpClient.get(
      Uri.parse('$url/api/slots/available'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load slots');
    }
  }

  Future<Map<String, dynamic>> reserveSlot(int slotId) async {
    final url = await baseUrl;
    final response = await _httpClient.post(
      Uri.parse('$url/api/reservations'),
      headers: _headers,
      body: jsonEncode({'slot_id': slotId}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to reserve slot');
    }
  }

  Future<bool> checkoutReservation(int reservationId) async {
    final url = await baseUrl;
    final response = await _httpClient.post(
      Uri.parse('$url/api/reservations/$reservationId/checkout'),
      headers: _headers,
    );
    return response.statusCode == 200;
  }

  Future<List<dynamic>> getMyReservations() async {
    final url = await baseUrl;
    final response = await _httpClient.get(
      Uri.parse('$url/api/reservations'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load reservations');
    }
  }
}
