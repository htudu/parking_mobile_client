import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String defaultBaseUrl = 'https://court-hub-tuesday-asp.trycloudflare.com';
  String? _authToken;
  String? _baseUrl;

  Future<String> get baseUrl async {
    if (_baseUrl != null) return _baseUrl!;
    
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString('api_base_url') ?? defaultBaseUrl;
    return _baseUrl!;
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _authToken = data['token'] ?? 'logged_in'; // Adjust based on your API
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<List<dynamic>> getAvailableSlots() async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/slots/available'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['slots'] ?? [];
    } else {
      throw Exception('Failed to load slots');
    }
  }

  Future<Map<String, dynamic>> reserveSlot(int slotId) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/reservations/create?slot_id=$slotId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to reserve slot');
    }
  }

  Future<bool> checkoutReservation(int reservationId) async {
    final url = await baseUrl;
    final response = await http.post(
      Uri.parse('$url/reservations/$reservationId/checkout'),
      headers: _headers,
    );

    return response.statusCode == 200;
  }

  Future<List<dynamic>> getMyReservations() async {
    final url = await baseUrl;
    final response = await http.get(
      Uri.parse('$url/reservations/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reservations'] ?? [];
    } else {
      throw Exception('Failed to load reservations');
    }
  }
}
