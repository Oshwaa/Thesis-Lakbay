import 'package:flutter/material.dart';
import 'package:Lakbay/main.dart';
import 'package:Lakbay/pages/transactions.dart';
import 'package:Lakbay/pages/profile.dart';

class BottomNavigation extends StatelessWidget {
  static int currentIndex = 0;

  const BottomNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: Colors.white12,
      selectedItemColor: Colors.green, // Change the color when selected
      unselectedItemColor: Colors.white, // Change the color when not selected
      onTap: (index) {
        if (index == currentIndex) {
          return; // Don't do anything if the same tab is tapped again
        }
        currentIndex = index;
        navigateToPage(context, index);
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void navigateToPage(BuildContext context, int index) {
    try {
      if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Profile()),
        );
      } else if (index == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Transactions()),
        );
      } else if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      }
    } catch (e) {
      print('Navigation Error: $e');
    }
  }
}
