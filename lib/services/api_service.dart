import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://court-hub-tuesday-asp.trycloudflare.com';
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
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
    final response = await http.get(
      Uri.parse('$baseUrl/slots/available'),
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
    final response = await http.post(
      Uri.parse('$baseUrl/reservations/create?slot_id=$slotId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to reserve slot');
    }
  }

  Future<bool> checkoutReservation(int reservationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reservations/$reservationId/checkout'),
      headers: _headers,
    );

    return response.statusCode == 200;
  }

  Future<List<dynamic>> getMyReservations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/reservations/'),
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
