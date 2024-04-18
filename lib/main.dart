import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Lakbay/pages/bindRFID.dart';
import 'package:Lakbay/pages/sendBalance.dart';
import 'package:Lakbay/pages/profile.dart';
import 'package:Lakbay/pages/transactions.dart';
import 'package:Lakbay/pages/splash.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Lakbay',
        theme: ThemeData(
          fontFamily: 'Gotham',
          scaffoldBackgroundColor: Colors.black,
          hintColor: Colors.green,
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white12,
            elevation: 0,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
          ),
        ),
        home: Splash());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String balance = 'Loading...';
  bool _isMounted = false;
  String user_ID = '';
  bool isLoading = true;
  int _currentIndex = 0;
  final String hostIP = '10.14.1.130'; //CHANGE IP
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _pageController = PageController(initialPage: _currentIndex);
    loadBoundRFID();
  }

  @override
  void dispose() {
    _isMounted = false;
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchBalance() async {
    try {
      final response = await http.post(
        Uri.parse('http://' + (hostIP) + '/phpprograms/getBalance.php'), //host
        body: {'user_ID': user_ID},
      );

      if (_isMounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data.containsKey('Balance')) {
            setState(() {
              balance = data['Balance'].toString();
              isLoading = false;
            });
          } else {
            throw Exception('Invalid JSON structure');
          }
        } else {
          throw Exception('Failed to load balance: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (_isMounted) {
        print('Error: $e');
        setState(() {
          balance = 'Error';
          isLoading = false;
        });
      }
    }
  }

  Future<void> refreshBalance() async {
    setState(() {
      isLoading = true;
    });
    await fetchBalance();
  }

  Future<void> loadBoundRFID() async {
    try {
      String? rfid = await ProfileBindingService.getBindedRFID();
      setState(() {
        user_ID = rfid ?? '';
      });
    } catch (e) {
      print('Error loading RFID: $e');
    }
    if (user_ID.isNotEmpty) {
      fetchBalance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex == 0) {
          return true;
        } else {
          _pageController.previousPage(
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          );
          loadBoundRFID();
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white12,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/lakbay_logo.png',
              width: 40,
              height: 40,
            ),
          ),
          title: Text(
            'Lakbay',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              fontFamily: 'Gotham',
            ),
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: refreshBalance,
          child: PageView(
            controller: _pageController,
            onPageChanged: (int newIndex) {
              setState(() {
                _currentIndex = newIndex;
              });
            },
            children: [
              MyHomePageContent(
                balance: balance,
                user_ID: user_ID,
                refreshBalance: refreshBalance,
              ),
              Transactions(),
              Profile(),
            ],
          ),
        ),
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white12,
          selectedItemColor: Colors.green, // Change the color when selected
          unselectedItemColor:
              Colors.white, // Change the color when not selected
          currentIndex: _currentIndex,
          onTap: (int newIndex) {
            setState(() {
              _currentIndex = newIndex;
              _pageController.animateToPage(
                newIndex,
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            });
            loadBoundRFID();
          },
          items: [
            BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
            BottomNavigationBarItem(
                label: 'Transactions', icon: Icon(Icons.list)),
            BottomNavigationBarItem(label: 'Profile', icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}

class MyHomePageContent extends StatelessWidget {
  final String balance;
  final String user_ID;
  final Future<void> Function() refreshBalance;

  const MyHomePageContent({
    required this.balance,
    required this.user_ID,
    required this.refreshBalance,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Colors.green,
      backgroundColor: Colors.white12,
      onRefresh: refreshBalance,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Ensure the l5ist is always scrollable
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 180,
                ),
                Icon(
                  Icons.directions_bus,
                  size: 40,
                  color: Colors.green,
                ),
                SizedBox(height: 20),
                Container(
                  height: 25, // Adjust the height as needed
                  child: Text(
                    'Balance:',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  '\u{20B1}$balance',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    fontFamilyFallback: ['Sans', 'Quaaykop'],
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'User ID: $user_ID',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 18),
                IconButton(
                  icon: Icon(Icons.refresh),
                  iconSize: 24,
                  onPressed: () async {
                    await refreshBalance();
                  },
                  tooltip: 'Refresh Balance',
                  color: Colors.white,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SendForm()),
                    );
                    print('Money transfer initiated for User ID: $user_ID');
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 52),
                    primary: Colors.green,
                  ),
                  child: Text(
                    'Send',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
