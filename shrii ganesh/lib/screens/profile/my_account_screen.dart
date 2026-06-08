import 'package:flutter/material.dart';

class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Account"),
      ),

      body: ListView(
        children: const [

          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text("Account Number"),
            subtitle: Text("1234567890"),
          ),

          ListTile(
            leading: Icon(Icons.credit_card),
            title: Text("IFSC Code"),
            subtitle: Text("SAMV0001234"),
          ),

          ListTile(
            leading: Icon(Icons.currency_rupee),
            title: Text("Available Balance"),
            subtitle: Text("₹25,000"),
          ),
        ],
      ),
    );
  }
}