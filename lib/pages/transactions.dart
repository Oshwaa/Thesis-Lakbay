import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Lakbay/pages/bindRFID.dart';
import 'package:http/http.dart' as http;

class Transactions extends StatefulWidget {
  @override
  _TransactionsState createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  List<Map<String, dynamic>> transactions = [];
  String user_ID = '';
  final String hostIP = '10.14.1.130'; //CHANGE IP
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadBoundRFID();
  }

  Future<void> fetchTransactions() async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://' + (hostIP) + '/phpprograms/getTransactions.php'), //host
        body: {'user_ID': user_ID},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          transactions = List<Map<String, dynamic>>.from(
              data.reversed); // Reversing the list
        });
      } else {
        print(
            'Failed to load transactions. Error code: ${response.statusCode}');
        print('Error message: ${response.body}');
      }
    } catch (error) {
      print('Error fetching transactions: $error');
    }
  }

  Future<void> loadBoundRFID() async {
    try {
      String? rfid = await ProfileBindingService.getBindedRFID();
      setState(() {
        user_ID = rfid ?? ''; // Set user_ID to the Bound RFID
      });
    } catch (e) {
      print('Error loading RFID: $e');
    }
    if (user_ID.isNotEmpty) {
      fetchTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        backgroundColor: Colors.white12,
        color: Colors.green, // Set the color of the refresh indicator
        onRefresh: () async {
          await fetchTransactions();
        },
        child: Container(
          color: Colors.black, // Set background color
          child: Theme(
            data: ThemeData(
              scrollbarTheme: ScrollbarThemeData(
                // Customize scrollbar color
                thumbColor: MaterialStateProperty.all(Colors.white10),
                trackColor: MaterialStateProperty.all(Colors.green),
                // Only show scrollbar when scrolled
                //showTrackOnHover: true,
              ),
            ),
            child: Scrollbar(
              controller: _scrollController, // Attach ScrollController
              child: Center(
                // Wrap SingleChildScrollView with Center
                child: SingleChildScrollView(
                  controller: _scrollController, // Attach ScrollController
                  child: Column(
                    children: [
                      if (transactions.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            String type = transactions[index]['Type'];
                            String date = transactions[index]['Date'];
                            String id = transactions[index]['ID'];
                            String amount = transactions[index]['Amount'];
                            String endpoint =
                                transactions[index]['Endpoint'] ?? '';
                            String transactionMessage;

                            switch (type) {
                              case 'Sent':
                                transactionMessage =
                                    '$date, $id sent ₱$amount to $endpoint.';
                                break;
                              case 'Received':
                                transactionMessage =
                                    '$date, $id received ₱$amount from $endpoint.';
                                break;
                              case 'Paid':
                                transactionMessage =
                                    '$date, $id paid ₱$amount.';
                                break;
                              case 'Collected':
                                transactionMessage =
                                    '$date, $id collected ₱$amount.';
                                break;
                              default:
                                transactionMessage = 'Unknown transaction type';
                                break;
                            }

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Card(
                                elevation: 3.0,
                                color: Colors.white10,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                child: ListTile(
                                  title: Text(
                                    transactionMessage,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      if (transactions.isEmpty)
                        Center(
                          child: Text(
                            'No transactions available.',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
