import 'dart:convert';
import 'package:makc/Model/company_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SharedPref {
  SharedPref._();
  static SharedPref sharedPref = SharedPref._();

  // Login Methods
  static Future<void> saveLogin(bool login) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isLogin", login);
  }

  static Future<bool?> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("isLogin") ?? false;
  }

  // Token Methods
  static Future<void> saveLoginToken(String loginToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("loginToken", loginToken);
  }

  static Future<String?> isLoggedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("loginToken");
  }

  // Clear Token Method
  static Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("loginToken");
      await prefs.setBool("isLogin", false);
      print('Token cleared from SharedPreferences');
    } catch (e) {
      print('Error clearing token: $e');
    }
  }

  // Clear All Data Method
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('All SharedPreferences data cleared');
    } catch (e) {
      print('Error clearing SharedPreferences: $e');
    }
  }

  // Company Data Methods
  static Future<void> saveCompanyData(CompanyDataModel company) async {
    final prefs = await SharedPreferences.getInstance();
    String companyJson = jsonEncode(company.toJson());
    await prefs.setString("company", companyJson);
  }

  static Future<CompanyDataModel?> getCompanyData() async {
    final prefs = await SharedPreferences.getInstance();
    String? companyString = prefs.getString("company");
    if (companyString != null) {
      Map<String, dynamic> json = jsonDecode(companyString);
      return CompanyDataModel.fromJson(json);
    }
    return null;
  }

  // Device ID Methods
  static const String deviceIdKey = "device_id";

  static Future<void> saveDeviceId(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(deviceIdKey, deviceId);
  }

  static Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(deviceIdKey);
  }

  // Image Path Methods
  static Future<void> saveImagePath(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("imagePath", imagePath);
  }

  static Future<String?> getImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("imagePath");
  }

  static Future<void> saveNoImagePath(String noImagePath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("noImagePath", noImagePath);
  }

  static Future<String?> getNoImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("noImagePath");
  }
}