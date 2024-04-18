import 'package:flutter/material.dart';
import 'package:Lakbay/main.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateHome();
  }

  _navigateHome() async {
    await Future.delayed(Duration(milliseconds: 2000), () {});
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MyHomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your logo widget here
            Image.asset(
              'assets/lakbay_logo.png', // Replace 'assets/logo.png' with your actual logo path
              width: 100, // Adjust the width as needed
              height: 100, // Adjust the height as needed
            ),
            SizedBox(height: 20), // Add some space between logo and text
            Text(
              'Lakbay',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
