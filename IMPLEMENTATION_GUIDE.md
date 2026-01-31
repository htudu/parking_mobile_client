# 📖 Mobile App Implementation Guide

## Getting Started

This guide provides step-by-step instructions for implementing the mobile app client for the Parking Reservation system.

---

## Prerequisites

### For iOS Development
- macOS 12+ (Intel or Apple Silicon)
- Xcode 14+ (from App Store)
- Swift 5.5+
- CocoaPods or SPM for dependencies
- Apple Developer Account (for TestFlight/App Store)

### For Android Development
- Windows/macOS/Linux
- Android Studio Flamingo+ 
- Kotlin 1.8+
- Gradle 7.5+
- Android SDK 24+
- Google Play Developer Account

### For Cross-Platform
- Node.js 16+ (React Native)
- Flutter SDK 3.0+ (Flutter)
- VS Code or favorite IDE

---

## API Contract

### Base URL
```
Development:  http://localhost:5000
Staging:      https://staging.parking-app.com
Production:   https://parking-app.com
```

### Endpoints Overview

#### Authentication
```
POST /auth/register
Body: { email, password, password_confirm }
Response: { message, success }

POST /auth/login
Body: { email, password }
Response: { user, session_id/token }

GET /auth/logout
Response: { message, success }
```

#### Slots
```
GET /slots/
Response: { slots: [{id, slot_number, is_available, created_at}] }

GET /slots/available
Response: { slots: [{...available slots only...}] }
```

#### Reservations
```
POST /reservations/create?slot_id=1
Response: { 
  id, 
  user_id, 
  slot_id, 
  reserved_at,
  qr_image (base64),
  qr_code_data (JSON)
}

GET /reservations/
Response: { reservations: [{id, slot_number, reserved_at, user_email}] }

GET /reservations/<id>
Response: { reservation: {id, slot, user, qr_image, qr_code_data} }

POST /reservations/<id>/checkout
Response: { message: "Successfully checked out", success: true }
```

---

## Swift/iOS Implementation

### Project Setup
```bash
# Create Xcode project
xcode-select --install
swift --version

# Create project structure
mkdir -p ParkingApp/ParkingApp/{Models,Views,ViewModels,Services,Utils}
```

### Key Classes

#### Models
```swift
// User.swift
struct User: Codable {
    let id: Int
    let email: String
    let createdAt: Date
}

// ParkingSlot.swift
struct ParkingSlot: Codable, Identifiable {
    let id: Int
    let slotNumber: String
    let isAvailable: Bool
    let createdAt: Date
}

// Reservation.swift
struct Reservation: Codable, Identifiable {
    let id: Int
    let userId: Int
    let slotId: Int
    let reservedAt: Date
    let qrCodeData: String?
    let qrImage: String? // base64
}
```

#### API Service
```swift
// APIService.swift
class APIService {
    static let shared = APIService()
    private let baseURL = "http://localhost:5000"
    
    func login(email: String, password: String) async throws -> User {
        // Implementation
    }
    
    func getAvailableSlots() async throws -> [ParkingSlot] {
        // Implementation
    }
    
    func reserveSlot(_ slotId: Int) async throws -> Reservation {
        // Implementation
    }
    
    func checkoutReservation(_ reservationId: Int) async throws -> Bool {
        // Implementation
    }
}
```

#### View Models
```swift
// LoginViewModel.swift
@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: String?
    
    func login() async {
        isLoading = true
        do {
            let user = try await APIService.shared.login(
                email: email,
                password: password
            )
            // Navigate to dashboard
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// SlotsViewModel.swift
@MainActor
class SlotsViewModel: ObservableObject {
    @Published var slots: [ParkingSlot] = []
    @Published var isLoading = false
    @Published var error: String?
    
    func loadSlots() async {
        isLoading = true
        do {
            slots = try await APIService.shared.getAvailableSlots()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
```

#### SwiftUI Views
```swift
// LoginView.swift
struct LoginView: View {
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
            
            Button("Sign In") {
                Task {
                    await viewModel.login()
                }
            }
            .disabled(viewModel.isLoading)
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

// SlotsView.swift
struct SlotsView: View {
    @StateObject var viewModel = SlotsViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.slots) { slot in
                SlotRow(slot: slot)
            }
            .onAppear {
                Task {
                    await viewModel.loadSlots()
                }
            }
            .navigationTitle("Available Slots")
        }
    }
}
```

---

## Kotlin/Android Implementation

### Project Setup
```bash
# Create new Android project in Android Studio
# Target API 24+
# Use Kotlin as language
# Add dependencies in build.gradle
```

### Key Classes

#### Models
```kotlin
// User.kt
data class User(
    val id: Int,
    val email: String,
    val createdAt: String
)

// ParkingSlot.kt
data class ParkingSlot(
    val id: Int,
    val slotNumber: String,
    val isAvailable: Boolean,
    val createdAt: String
)

// Reservation.kt
data class Reservation(
    val id: Int,
    val userId: Int,
    val slotId: Int,
    val reservedAt: String,
    val qrCodeData: String? = null,
    val qrImage: String? = null
)
```

#### API Service
```kotlin
// RetrofitClient.kt
object RetrofitClient {
    private const val BASE_URL = "http://localhost:5000/"
    
    val apiService: ApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .addConverterFactory(GsonConverterFactory.create())
            .build()
            .create(ApiService::class.java)
    }
}

// ApiService.kt
interface ApiService {
    @POST("auth/login")
    suspend fun login(@Body loginRequest: LoginRequest): User
    
    @GET("slots/available")
    suspend fun getAvailableSlots(): List<ParkingSlot>
    
    @POST("reservations/create")
    suspend fun reserveSlot(@Query("slot_id") slotId: Int): Reservation
    
    @POST("reservations/{id}/checkout")
    suspend fun checkoutReservation(@Path("id") reservationId: Int): Response<Unit>
}
```

#### ViewModels
```kotlin
// LoginViewModel.kt
class LoginViewModel : ViewModel() {
    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Idle)
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()
    
    fun login(email: String, password: String) {
        viewModelScope.launch {
            _uiState.value = LoginUiState.Loading
            try {
                val user = RetrofitClient.apiService.login(
                    LoginRequest(email, password)
                )
                _uiState.value = LoginUiState.Success(user)
            } catch (e: Exception) {
                _uiState.value = LoginUiState.Error(e.message ?: "Unknown error")
            }
        }
    }
}

// SlotsViewModel.kt
class SlotsViewModel : ViewModel() {
    private val _slots = MutableStateFlow<List<ParkingSlot>>(emptyList())
    val slots: StateFlow<List<ParkingSlot>> = _slots.asStateFlow()
    
    fun loadSlots() {
        viewModelScope.launch {
            try {
                val slotList = RetrofitClient.apiService.getAvailableSlots()
                _slots.value = slotList
            } catch (e: Exception) {
                Log.e("SlotsViewModel", "Error loading slots", e)
            }
        }
    }
}
```

#### Compose UI
```kotlin
// LoginScreen.kt
@Composable
fun LoginScreen(viewModel: LoginViewModel) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    val uiState by viewModel.uiState.collectAsState()
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        verticalArrangement = Arrangement.Center
    ) {
        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") }
        )
        
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            visualTransformation = PasswordVisualTransformation()
        )
        
        Button(
            onClick = { viewModel.login(email, password) },
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 16.dp)
        ) {
            Text("Sign In")
        }
        
        when (uiState) {
            is LoginUiState.Error -> {
                Text(
                    (uiState as LoginUiState.Error).message,
                    color = Color.Red
                )
            }
            is LoginUiState.Loading -> {
                CircularProgressIndicator()
            }
            else -> {}
        }
    }
}

// SlotsScreen.kt
@Composable
fun SlotsScreen(viewModel: SlotsViewModel) {
    val slots by viewModel.slots.collectAsState()
    
    LazyColumn {
        items(slots) { slot ->
            SlotCard(slot = slot)
        }
    }
    
    LaunchedEffect(Unit) {
        viewModel.loadSlots()
    }
}
```

---

## React Native Implementation

### Project Setup
```bash
# Create React Native project
npx react-native init ParkingApp
cd ParkingApp

# Install dependencies
npm install axios react-query @react-native-camera-roll/camera-roll react-native-qrcode-svg

# For Expo alternative
expo init ParkingApp
```

### Key Implementation

#### API Client
```javascript
// api/client.js
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

const API_BASE_URL = 'http://localhost:5000';

const client = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
});

// Add JWT to requests
client.interceptors.request.use(async (config) => {
  const token = await AsyncStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default client;
```

#### Redux Store
```javascript
// store/authSlice.js
import { createSlice, createAsyncThunk } from '@reduxjs/toolkit';
import client from '../api/client';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const login = createAsyncThunk(
  'auth/login',
  async ({ email, password }) => {
    const response = await client.post('/auth/login', { email, password });
    await AsyncStorage.setItem('authToken', response.data.token);
    return response.data;
  }
);

const authSlice = createSlice({
  name: 'auth',
  initialState: { user: null, loading: false, error: null },
  extraReducers: (builder) => {
    builder
      .addCase(login.pending, (state) => {
        state.loading = true;
      })
      .addCase(login.fulfilled, (state, action) => {
        state.loading = false;
        state.user = action.payload.user;
      })
      .addCase(login.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message;
      });
  },
});

export default authSlice.reducer;
```

#### Screens
```javascript
// screens/LoginScreen.js
import React, { useState } from 'react';
import {
  View,
  TextInput,
  TouchableOpacity,
  Text,
  StyleSheet,
  ActivityIndicator,
} from 'react-native';
import { useDispatch, useSelector } from 'react-redux';
import { login } from '../store/authSlice';

export default function LoginScreen({ navigation }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const dispatch = useDispatch();
  const { loading, error } = useSelector((state) => state.auth);

  const handleLogin = async () => {
    dispatch(login({ email, password }))
      .unwrap()
      .then(() => navigation.navigate('Dashboard'))
      .catch((err) => console.error(err));
  };

  return (
    <View style={styles.container}>
      <TextInput
        style={styles.input}
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        style={styles.input}
        placeholder="Password"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      <TouchableOpacity
        style={styles.button}
        onPress={handleLogin}
        disabled={loading}
      >
        {loading ? <ActivityIndicator /> : <Text>Sign In</Text>}
      </TouchableOpacity>
      {error && <Text style={styles.error}>{error}</Text>}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 20, justifyContent: 'center' },
  input: {
    borderWidth: 1,
    padding: 10,
    marginVertical: 10,
    borderRadius: 5,
  },
  button: {
    backgroundColor: '#2563eb',
    padding: 15,
    borderRadius: 5,
    alignItems: 'center',
  },
  error: { color: 'red', marginTop: 10 },
});
```

---

## Testing Strategy

### Unit Tests
```
✅ Model validation
✅ API response parsing
✅ Business logic
✅ Utility functions
```

### Integration Tests
```
✅ API endpoint calls
✅ Authentication flow
✅ Reservation workflow
```

### E2E Tests
```
✅ Complete user journey (Register → Reserve → Checkout)
✅ Error handling
✅ Offline scenarios
```

---

## Deployment Checklist

- [ ] Code review completed
- [ ] All tests passing (>80% coverage)
- [ ] App icon/logo finalized
- [ ] Privacy policy written
- [ ] Terms of Service drafted
- [ ] App Store submission prepared
- [ ] TestFlight beta build created
- [ ] Analytics configured
- [ ] Crash reporting setup
- [ ] Push notifications tested
- [ ] Production API configured
- [ ] Documentation complete

---

## Support Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation)
- [Android Developer Documentation](https://developer.android.com/docs)
- [React Native Documentation](https://reactnative.dev/docs/getting-started)
- [Rest API Testing with Postman](https://www.postman.com/)
- [Firebase Console](https://console.firebase.google.com/)

---

**Status**: Ready for Development  
**Last Updated**: January 31, 2026
