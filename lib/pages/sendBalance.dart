import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Lakbay/pages/bindRFID.dart';

class SendForm extends StatefulWidget {
  const SendForm({Key? key});

  @override
  _SendFormState createState() => _SendFormState();
}

class _SendFormState extends State<SendForm> {
  TextEditingController toController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  String sender = ''; // Initialize sender
  final String hostIP = '10.14.1.130'; //change according to host
  Future<void> sendBalance(
      String recipient, String amount, String sender) async {
    try {
      final response = await http.post(
        Uri.parse('http://' + (hostIP) + '/phpprograms/sendBalance.php'),
        body: {
          'recipient': recipient,
          'amount': amount,
          'user_ID': sender,
        },
      );

      if (response.statusCode == 200) {
        if (response.body == "Success") {
          _showTransferResultDialog(true, "Balance Sent.");
        } else {
          _showTransferResultDialog(
              false, 'Failed to send balance. Status code: ${response.body}');
        }
      } else {
        _showTransferResultDialog(
            false, 'Failed to send balance. Status code: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
      _showTransferResultDialog(
          false, 'An error occurred. Please try again later.');
    }
  }

  @override
  void initState() {
    super.initState();
    loadBoundRFID();
  }

  Future<void> loadBoundRFID() async {
    try {
      String? rfid = await ProfileBindingService.getBindedRFID();
      setState(() {
        sender = rfid ?? ''; // Set user_ID to the Bound RFID
      });
    } catch (e) {
      print('Error loading RFID: $e');
    }
    if (sender.isNotEmpty) {
      print(sender);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Send Balance'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                style: TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.green,
                controller: toController,
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    labelText: 'Recipient:',
                    labelStyle: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              TextField(
                style: TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: Colors.green,
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white)),
                    labelText: 'Amount:',
                    labelStyle: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  primary: Colors.green,
                ),
                onPressed: () {
                  if (toController.text.isEmpty ||
                      amountController.text.isEmpty ||
                      toController.text.trim() == sender) {
                    _showErrorMessage('Invalid Amount/Recipient.');
                  } else {
                    _showConfirmationDialog(
                        toController.text.trim(), amountController.text.trim());
                  }
                },
                child: Text('Send'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(String recipient, String amount) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 15, 15, 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text(
            'Confirmation',
            style: TextStyle(
              color: Colors.green,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Recipient: $recipient',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Text(
                  'Amount: $amount',
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.green, fontSize: 18.0),
              ),
              onPressed: () {
                sendBalance(recipient, amount, sender);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.green, fontSize: 18.0),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showErrorMessage(String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 15, 15, 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          title: Text(
            'Error',
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
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTransferResultDialog(bool success, String message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 15, 15, 15),
          title: Text(
            success ? 'Success' : 'Error',
            style: TextStyle(color: Colors.green),
          ),
          content: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SendForm(),
  ));
}
