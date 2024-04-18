import 'package:shared_preferences/shared_preferences.dart';
//import 'package:flutter_application_1/pages/profile.dart';

class ProfileBindingService {
  // Function to bind RFID to a user profile
  static Future<void> bindRFID(String rfidData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('bindedRFID', rfidData);
  }

  // Function to retrieve the binded RFID
  static Future<String?> getBindedRFID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('bindedRFID');
  }
}

Future<void> resetSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
