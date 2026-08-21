import 'package:flutter/material.dart';

class AboutSamvyaScreen extends StatelessWidget {
  const AboutSamvyaScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("About Samvya"),
      ),

      body: ListView(

        children: const [

          ListTile(
            leading: Icon(Icons.description),
            title: Text("Terms & Conditions"),
          ),

          ListTile(
            leading: Icon(Icons.privacy_tip),
            title: Text("Privacy Policy"),
          ),
        ],
      ),
    );
  }
}