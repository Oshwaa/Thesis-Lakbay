import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:Lakbay/main.dart';
import 'package:Lakbay/pages/bindRFID.dart';
import 'package:http/http.dart' as http;
//import 'package:Lakbay/pages/navigation.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController rfidController = TextEditingController();
  TextEditingController PinController = TextEditingController();
  String bindedRFID = 'Bind RFID';
  bool isObscured = true; // Added
  final String hostIP = '10.14.1.130'; // CHANGE IP

  @override
  void initState() {
    super.initState();
    loadBoundRFID();
  }

  void loadBoundRFID() async {
    String? rfid = await ProfileBindingService.getBindedRFID();
    setState(() {
      bindedRFID = rfid ?? 'Bind RFID';
    });
  }

  void bindRFID() async {
    String rfidData = rfidController.text.trim();

    await ProfileBindingService.bindRFID(rfidData);
    loadBoundRFID(); // Reload the Bound RFID after binding
  }

  Future<void> checkPin() async {
    try {
      final response = await http.post(
        Uri.parse('http://' + (hostIP) + '/phpprograms/checkPin.php'), //host
        body: {
          'pin': PinController.text.trim(),
          'user_id': rfidController.text.trim(),
        },
      );

      if (response.statusCode == 200) {
        // Parse the response as JSON
        final jsonData = json.decode(response.body);

        // Check if the response has a 'status' field
        if (jsonData['status'] == 'success') {
          // Continue with your logic
          print("Login Success");
          bindRFID();
          // Show successful login dialog
          showResultDialog('Success', 'Login successful');
        } else {
          // Handle the case where the login is not successful
          print('Login failed: ${jsonData['message']}');
          // Show error dialog
          showResultDialog('Error', 'Login failed: ${jsonData['message']}');
        }
      } else {
        // Handle other status codes if needed
        print('HTTP request failed with status: ${response.statusCode}');
        // Show error dialog
        showResultDialog('Error', 'HTTP request failed');
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      // Show error dialog
      showResultDialog('Error', 'Error during HTTP request');
    }
  }

  // Function to show dialog
  void showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 15, 15, 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: Colors.green,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green, fontSize: 18.0),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        return false; // Do not close the app
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person,
                color: Colors.green,
                size: 70,
              ),
              SizedBox(height: 20),
              TextField(
                cursorColor: Colors.green,
                controller: rfidController,
                decoration: InputDecoration(
                  labelText: 'Enter RFID:',
                  labelStyle:
                      TextStyle(color: Colors.white), // Label text color
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide:
                        BorderSide(color: Colors.white70), // Border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide:
                        BorderSide(color: Colors.white), // Focused border color
                  ),
                ),
                style: TextStyle(color: Colors.white), // Text color
              ),
              SizedBox(height: 20),

              SizedBox(height: 20),
              TextField(
                cursorColor: Colors.green,
                controller: PinController,
                obscureText: isObscured,
                decoration: InputDecoration(
                  labelText: 'Enter Pin',
                  labelStyle:
                      TextStyle(color: Colors.white), // Label text color
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide:
                        BorderSide(color: Colors.white70), // Border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide:
                        BorderSide(color: Colors.white), // Focused border color
                  ),
                  suffixIcon: IconButton(
                    color: Colors.white70,
                    icon: Icon(
                      isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isObscured = !isObscured;
                      });
                    },
                  ),
                ),
                style: TextStyle(color: Colors.white), // Text color
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: checkPin,
                child: Text('Bind RFID'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 42),
                  primary: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              // Display the currently Bound RFID
              Text(
                'Bound RFID: $bindedRFID',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
        //bottomNavigationBar: BottomNavigation(),
      ),
    );
  }
}
