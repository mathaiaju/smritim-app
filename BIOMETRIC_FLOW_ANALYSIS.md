# Biometric Flow Analysis

## Current Flow Issues

### 1. Login Flow (login_screen.dart)
```dart
ApiClient.enableBiometric(true);  // ✅ Sets biometric AND persists to SharedPreferences
ApiClient.setSession(token, user); // ❌ Only sets in-memory, NOT persisted
```

**Problem**: Session is not persisted, so after app restart:
- `ApiClient.isLoggedIn` returns `false` (token is null)
- Biometric prompt never shows

### 2. Splash Screen Flow (splash_screen.dart)
```dart
if (ApiClient.isLoggedIn) {  // ❌ Always false after restart
  if (ApiClient.biometricEnabled && ...) {
    // Show biometric
  }
}
```

**Problem**: `isLoggedIn` checks `_token != null`, but token is never loaded from storage

### 3. ApiClient Issues
- `setSession()` - Only sets in-memory, doesn't persist
- `loadBiometricPref()` - Only loads biometric flag, not token/user
- `logout()` - Sets `biometricEnabled = false` but doesn't persist

## Required Fixes

### Fix 1: Persist session on login
```dart
static Future<void> setSession({
  required String token,
  required Map<String, dynamic> user,
}) async {
  _token = token;
  currentUser = user;
  
  // Persist to SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setString('user', jsonEncode(user));
}
```

### Fix 2: Load session on app startup
```dart
static Future<void> loadSession() async {
  final prefs = await SharedPreferences.getInstance();
  _token = prefs.getString('token');
  final userJson = prefs.getString('user');
  if (userJson != null) {
    currentUser = jsonDecode(userJson);
  }
  biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
}
```

### Fix 3: Clear session on logout
```dart
static Future<void> logout() async {
  _token = null;
  currentUser = null;
  
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('user');
  await prefs.setBool('biometric_enabled', false);
}
```

### Fix 4: Update main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.loadSession(); // Load both session AND biometric pref
  runApp(const SmritiSaarathiAdminApp());
}
```

## Expected Flow After Fixes

### First Launch
1. App starts → `loadSession()` → No token found → `isLoggedIn = false`
2. Splash screen → Shows login screen
3. User logs in → `setSession()` persists token → `enableBiometric(true)` persists flag
4. Navigate to dashboard

### Second Launch (with biometric)
1. App starts → `loadSession()` → Token found → `isLoggedIn = true`, `biometricEnabled = true`
2. Splash screen → Checks biometric support → Shows biometric prompt
3. If biometric succeeds → Navigate to dashboard
4. If biometric fails → Show login screen

### Logout
1. User clicks logout → `logout()` clears token and biometric flag
2. Next launch → No token → Show login screen
