import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart'; // To listen for UPI response
import 'dart:async';

class UpiPaymentPage extends StatefulWidget {
  final double amount;
  final String upiId;
  final String payeeName;

  UpiPaymentPage({
    required this.amount,
    required this.upiId,
    required this.payeeName,
  });

  @override
  _UpiPaymentPageState createState() => _UpiPaymentPageState();
}

class _UpiPaymentPageState extends State<UpiPaymentPage> {
  String paymentStatus = "Waiting for payment...";
  StreamSubscription<String?>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _listenForUpiResponse();
  }

  void _listenForUpiResponse() {
    _linkSubscription = linkStream.listen((String? uri) {
      if (uri != null) {
        Uri upiResponse = Uri.parse(uri);
        String status = upiResponse.queryParameters['Status'] ?? "Unknown";

        setState(() {
          if (status.toLowerCase() == "success") {
            paymentStatus = "✅ Payment Successful!";
          } else if (status.toLowerCase() == "failure") {
            paymentStatus = "❌ Payment Failed!";
          } else {
            paymentStatus = "⏳ Payment Pending!";
          }
        });
      }
    });
  }

  void _makePayment() async {
    String upiUrl =
        "upi://pay?pa=${widget.upiId}&pn=${widget.payeeName}&am=${widget.amount.toStringAsFixed(2)}&cu=INR&tr=${DateTime.now().millisecondsSinceEpoch}";

    Uri uri = Uri.parse(upiUrl);

    // Launch the UPI link with chooser options every time
    if (await canLaunchUrl(uri)) {
      // Use the external application method to ensure app chooser every time
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      setState(() {
        paymentStatus = "⚠️ No UPI app found!";
      });
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("UPI Payment")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Pay ₹${widget.amount.toStringAsFixed(2)} to ${widget.payeeName}",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _makePayment,
              child: Text("Pay via UPI"),
            ),
            SizedBox(height: 30),
            Text(
              paymentStatus,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
