import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),


        body: ListView(

        children: const [

          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Change MPIN"),
          ),

          ListTile(
            leading: Icon(Icons.fingerprint),
            title: Text("Face ID / Touch ID"),
          ),

          ListTile(
            leading: Icon(Icons.phone_android),
            title: Text("Device ID"),
          ),

          ListTile(
            leading: Icon(Icons.info),
            title: Text("App Version"),
            subtitle: Text("1.0.0"),
          ),
        ],
      ),
    );
  }
}