import 'package:flutter/material.dart';

class LoanScreen extends StatelessWidget {
  const LoanScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Loans"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: const [

          Card(
            child: ListTile(
              title: Text("KCC Loan"),
              subtitle: Text("Farmer Credit Loan"),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Agriculture Loan"),
              subtitle: Text("Crop Financing"),
            ),
          ),

          Card(
            child: ListTile(
              title: Text("Education Loan"),
              subtitle: Text("Student Support"),
            ),
          ),
        ],
      ),
    );
  }
}