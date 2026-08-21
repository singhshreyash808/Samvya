import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Us"),
      ),

      body: const Padding(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [

            ListTile(
              leading: Icon(Icons.phone),
              title: Text("+91 XXXXX XXXXX"),
            ),

            ListTile(
              leading: Icon(Icons.email),
              title: Text("support@samvya.com"),
            ),
          ],
        ),
      ),
    );
  }
}