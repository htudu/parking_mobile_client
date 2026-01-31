# 🚀 Flutter App - Quick Start Guide

## Features Included

✅ **User Authentication**
- Login screen with email/password
- Persistent session management
- Error handling

✅ **Browse & Reserve Slots**
- Grid view of all available parking slots
- Filter available slots
- One-tap reservation with QR code generation
- Responsive design

✅ **My Reservations** (NEW)
- View all active reservations
- See slot numbers and reservation dates
- View QR code for each reservation
- Checkout from slot directly
- Pull-to-refresh

✅ **QR Code Scanner** (NEW)
- Scan QR codes to checkout
- Torch/flashlight support
- Real-time barcode detection
- Confirmation dialog before checkout
- Success feedback

---

## Installation Steps

### 1️⃣ Install Flutter (Windows)

```powershell
# Using Scoop (easiest)
scoop install flutter

# Verify installation
flutter doctor
```

Or download from: https://flutter.dev/docs/get-started/install/windows

### 2️⃣ Create Flutter Project

```powershell
# Create new Flutter project
flutter create --org com.parking parking_app
cd parking_app

# Copy starter files from flutter_starter folder
# Or clone if already created
```

### 3️⃣ Add Dependencies

```powershell
flutter pub get
```

**Dependencies included:**
```yaml
http: ^1.1.0              # HTTP requests
provider: ^6.0.0          # State management
qr_flutter: ^4.0.0        # QR code display
mobile_scanner: ^3.4.0    # QR code scanning
shared_preferences: ^2.2.0 # Local storage
intl: ^0.19.0             # Date formatting
```

---

## Project Structure

```
lib/
├── main.dart                          # App entry + Auth provider
├── services/
│   └── api_service.dart              # API integration with Flask backend
├── screens/
│   ├── login_screen.dart             # Login UI
│   ├── slots_screen.dart             # Browse & reserve slots
│   ├── reservation_screen.dart       # Show QR after reservation
│   ├── my_reservations_screen.dart   # View & checkout reservations (NEW)
│   └── qr_scanner_screen.dart        # Scan QR to checkout (NEW)
└── widgets/
    ├── slot_card.dart                # Reusable slot card
    └── reservation_card.dart         # Reusable reservation card
```

---

## Configuration

### Update Backend URL

Open `lib/services/api_service.dart` and update:

```dart
static const String baseUrl = 'http://localhost:5000'; // Change this!

// For production:
// static const String baseUrl = 'https://parking-app.com';
// Or use Cloudflare tunnel: 'https://your-tunnel.trycloudflare.com'
```

---

## Build & Run

### Run on Emulator

```powershell
# Start Android emulator first (from Android Studio)
# Then:
flutter run
```

### Run on Real Phone (USB)

```powershell
# Enable USB debugging on phone, connect via USB
flutter run

# Or build APK and transfer manually
flutter build apk --debug
```

### Build Release APK

```powershell
# Creates optimized APK for Play Store
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (for Play Store)

```powershell
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## User Flow

### 1. Login
- Enter email & password
- Authenticated with Flask backend
- Session token stored in memory

### 2. Browse Slots
- Grid of available parking slots
- Shows slot number & availability status
- Tap "Reserve" button

### 3. Make Reservation
- Confirmation screen appears
- QR code generated and displayed
- Tap "Back to Slots" to continue

### 4. View My Reservations
- Tap bookmark icon in app bar
- See all active reservations
- View QR code for each
- Option to checkout

### 5. Checkout (Method 1 - Direct)
- From My Reservations, tap "Checkout"
- Confirm action in dialog
- Slot becomes available again

### 6. Checkout (Method 2 - QR Scanner)
- From My Reservations, tap QR icon in app bar
- Point camera at QR code
- Confirm checkout in dialog
- Success message shown

---

## API Endpoints Used

```
POST   /auth/login                    → Login user
GET    /slots/available               → Get available slots
POST   /reservations/create?slot_id=X → Make reservation
GET    /reservations/                 → Get user's reservations
POST   /reservations/X/checkout       → Checkout from slot
```

---

## Permissions (Android)

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- For camera (QR scanning) -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- For internet -->
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Testing Checklist

- [ ] Login with valid credentials
- [ ] Browse available slots
- [ ] Make a reservation
- [ ] View QR code
- [ ] Logout and login again
- [ ] View My Reservations
- [ ] Scan QR code and checkout
- [ ] Test on actual Android phone
- [ ] Test APK installation

---

## Troubleshooting

### App crashes on startup
**Solution:** Make sure `baseUrl` in `api_service.dart` is correct and Flask backend is running

### Camera not working (QR Scanner)
**Solution:** Grant camera permission when prompted, check `AndroidManifest.xml` permissions

### API calls failing (401 Unauthorized)
**Solution:** Ensure token is being set after login in `api_service.dart`

### QR codes not scanning
**Solution:** 
- Ensure good lighting
- Hold camera steady
- Try toggling flashlight (torch button)

### Can't install APK on phone
**Solution:** 
- Enable "Unknown Sources" in Settings
- Try smaller APK file (release build)
- Check USB debugging mode

---

## Deployment to Play Store

1. **Build release APK/AAB**
   ```powershell
   flutter build appbundle --release
   ```

2. **Create Google Play Developer Account**
   - Visit https://play.google.com/console

3. **Create new app** in Play Console

4. **Upload AAB file**
   - Go to Release > Production
   - Upload `app-release.aab`

5. **Fill app details**
   - App name, description, category
   - Screenshots, icon, privacy policy

6. **Review & publish**
   - Usually takes 2-4 hours for review

---

## Performance Tips

- Use release build for testing performance
- QR scanning requires camera permission
- First launch may take time initializing database
- Network calls cache results where possible

---

## Useful Commands

```powershell
# Clean build
flutter clean
flutter pub get

# Run with verbose output
flutter run -v

# Run on specific device
flutter devices
flutter run -d <device-id>

# Build for production
flutter build apk --release
flutter build appbundle --release

# Check package size
flutter build apk --analyze-size

# Run tests
flutter test
```

---

## Estimated Timeline

| Phase | Time |
|-------|------|
| Setup & configuration | 10 mins |
| First test run | 5 mins |
| APK build | 2-5 mins |
| Install on phone | 1 min |
| **Total** | **20 mins** |

---

## Support

For issues with:
- **Flutter**: https://flutter.dev/docs
- **Mobile Scanner**: https://pub.dev/packages/mobile_scanner
- **Provider**: https://pub.dev/packages/provider
- **HTTP Client**: https://pub.dev/packages/http

---

**Status**: ✅ Production Ready  
**Last Updated**: January 31, 2026
