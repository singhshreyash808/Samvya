import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person,size: 50),
            ),

            const SizedBox(height: 20),

            Text(
              user?.email ?? "",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            const ListTile(
              leading: Icon(Icons.person),
              title: Text("Full Name"),
              subtitle: Text("User Name"),
            ),

            const ListTile(
              leading: Icon(Icons.phone),
              title: Text("Mobile Number"),
              subtitle: Text("XXXXXXXXXX"),
            ),
          ],
        ),
      ),
    );
  }
}