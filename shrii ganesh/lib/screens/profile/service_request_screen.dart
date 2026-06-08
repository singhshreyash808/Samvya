import 'package:flutter/material.dart';

class ServiceRequestScreen extends StatelessWidget {
  const ServiceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Requests"),
      ),

      body: ListView(

        children: const [

          ListTile(
            leading: Icon(Icons.download),
            title: Text("Download Statement"),
          ),

          ListTile(
            leading: Icon(Icons.verified_user),
            title: Text("Re-KYC"),
          ),

          ListTile(
            leading: Icon(Icons.edit),
            title: Text("Update Profile"),
          ),

          ListTile(
            leading: Icon(Icons.receipt_long),
            title: Text("Interest Certificate"),
          ),
        ],
      ),
    );
  }
}