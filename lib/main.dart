import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/slots_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const ParkingApp());
}

class ParkingApp extends StatelessWidget {
  const ParkingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Parking Reservation',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return auth.isAuthenticated ? const SlotsScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}

/// Auth Provider for managing login state and JWT token
class AuthProvider extends ChangeNotifier {
  String? _userEmail;
  String? _jwtToken;
  bool _isLoading = false;

  bool get isAuthenticated => _jwtToken != null;
  String? get userEmail => _userEmail;
  String? get jwtToken => _jwtToken;
  bool get isLoading => _isLoading;

  Future<bool> login(ApiService api, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await api.login(email, password);
      _userEmail = result['email'];
      _jwtToken = result['token'];
      api.setAuthToken(_jwtToken!);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> register(ApiService api, String email, String password, String passwordConfirm) async {
    _isLoading = true;
    notifyListeners();

    try {
      await api.register(email, password, passwordConfirm);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout(ApiService api) async {
    try {
      await api.logout();
    } catch (e) {
      // Handle logout error
    }
    _userEmail = null;
    _jwtToken = null;
    api.setAuthToken(null);
    notifyListeners();
  }
}
