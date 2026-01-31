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

/// Auth Provider for managing login state
class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userEmail;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;

  Future<bool> login(ApiService api, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await api.login(email, password);
      _token = result['token'];
      _userEmail = email;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _token = null;
    _userEmail = null;
    notifyListeners();
  }
}
