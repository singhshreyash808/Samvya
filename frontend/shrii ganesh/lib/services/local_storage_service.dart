import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // ==========================
  // KEYS
  // ==========================

  static const String _registeredKey = "registered";

  static const String _nameKey = "name";
  static const String _mobileKey = "mobile";
  static const String _emailKey = "email";

  static const String _addressKey = "address";
  static const String _villageKey = "village";
  static const String _districtKey = "district";
  static const String _stateKey = "state";
  static const String _pinCodeKey = "pinCode";

  static const String _mpinKey = "mpin";

  static const String _biometricKey = "biometric";

  static const String _consentKey = "dpdpa_consent_given";

  // ==========================
  // DPDPA CONSENT
  // ==========================

  static Future<bool> isConsentGiven() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  static Future<void> setConsentGiven() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, true);
  }

  // ==========================
  // REGISTER
  // ==========================

  static Future<void> saveUser({
    required String name,
    required String mobile,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);
    await prefs.setString(_mobileKey, mobile);
    await prefs.setString(_emailKey, email);

    await prefs.setBool(_registeredKey, true);
  }

  static Future<bool> isRegistered() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_registeredKey) ?? false;
  }

  // ==========================
  // USER
  // ==========================

  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_nameKey) ?? "";
  }

  static Future<String> getMobile() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_mobileKey) ?? "";
  }

  static Future<String> getEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_emailKey) ?? "";
  }

  // ==========================
  // PROFILE
  // ==========================
  static Future<void> updateProfile({
    required String name,
    required String mobile,
    required String email,
    required String address,
    required String village,
    required String district,
    required String state,
    required String pinCode,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, name);
    await prefs.setString(_mobileKey, mobile);
    await prefs.setString(_emailKey, email);

    await prefs.setString(_addressKey, address);
    await prefs.setString(_villageKey, village);
    await prefs.setString(_districtKey, district);
    await prefs.setString(_stateKey, state);
    await prefs.setString(_pinCodeKey, pinCode);

  }


  static Future<String> getAddress() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_addressKey) ?? "";
  }

  static Future<String> getVillage() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_villageKey) ?? "";
  }

  static Future<String> getDistrict() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_districtKey) ?? "";
  }

  static Future<String> getState() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_stateKey) ?? "";
  }

  static Future<String> getPinCode() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_pinCodeKey) ?? "";

  }
  static const String _accountKey = "account";
  static const String _balanceKey = "balance";

  static Future<String> getAccountNumber() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_accountKey) ??
        "4218 4567 8975 2345";
  }

  static Future<double> getBalance() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getDouble(_balanceKey) ??
        25000;
  }

  static Future<void> saveAccountDetails({

    required String account,

    required double balance,

  }) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_accountKey, account);

    await prefs.setDouble(_balanceKey, balance);

  }


  // ==========================
  // MPIN
  // ==========================

  static Future<void> saveMPIN(String mpin) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_mpinKey, mpin);
  }

  static Future<String?> getMPIN() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_mpinKey);
  }

  // ==========================
  // MPIN FAILED ATTEMPTS / BLOCK
  // ==========================

  static const String _failedAttemptsKey = "failedAttempts";
  static const String _blockUntilKey = "blockUntil";

  static Future<int> getFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_failedAttemptsKey) ?? 0;
  }

  static Future<void> incrementFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_failedAttemptsKey) ?? 0;
    await prefs.setInt(_failedAttemptsKey, current + 1);
  }

  static Future<void> resetFailedAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_failedAttemptsKey, 0);
    await prefs.remove(_blockUntilKey);
  }

  static Future<void> setBlockUntil(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_blockUntilKey, time.toIso8601String());
  }

  static Future<DateTime?> getBlockUntil() async {
    final prefs = await SharedPreferences.getInstance();
    String? timeStr = prefs.getString(_blockUntilKey);
    if (timeStr == null) return null;
    return DateTime.tryParse(timeStr);
  }


  // ==========================
  // BIOMETRIC
  // ==========================

  static Future<void> saveBiometric(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_biometricKey, value);
  }

  static Future<bool> getBiometric() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_biometricKey) ?? false;
  }

  // ==========================
  // LOGOUT
  // ==========================

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_biometricKey);
  }
}