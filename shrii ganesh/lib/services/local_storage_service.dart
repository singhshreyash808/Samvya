import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {

  static Future<void> saveMPIN(String mpin) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_mpin', mpin);
  }

  static Future<String?> getMPIN() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_mpin');
  }
  }