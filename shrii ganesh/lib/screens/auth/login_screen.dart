import 'package:flutter/material.dart';
import 'package:samvya/screens/mpin/verify_mpin_screen.dart';

import '../../services/firebase_auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Samvya Login"),
      ),

body: Stack(
children: [

// Background Logo
Positioned.fill(
child: Opacity(
opacity: 0.08,
child: Image.asset(
"assets/icons/logo.png",
fit: BoxFit.cover,
),
),
),

Container(
decoration: const BoxDecoration(
gradient: LinearGradient(
colors: [
Color(0xFF5ED3C5),
Color(0xFF9AE5DB),
],
begin: Alignment.topCenter,
end: Alignment.bottomCenter,
),
),
),

Center(
child: SingleChildScrollView(
child: Padding(
padding: const EdgeInsets.all(24),

child: Container(
padding: const EdgeInsets.all(25),

decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(30),
boxShadow: [
BoxShadow(
color: Colors.black12,
blurRadius: 10,
),
],
),


child: Column(
mainAxisSize: MainAxisSize.min,
children: [

Image.asset(
"assets/icons/logo.png",
height: 120,
),

const SizedBox(height: 20),

const Text(
"Welcome to Samvya",
style: TextStyle(
fontSize: 26,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 8),

const Text(
"Rural Banking Platform",
style: TextStyle(
color: Colors.grey,
),
),

const SizedBox(height: 30),

TextField(
controller: emailController,
decoration: InputDecoration(
hintText: "Email",
filled: true,
fillColor: Colors.grey.shade100,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(15),
borderSide: BorderSide.none,
),
),
),

const SizedBox(height: 15),

TextField(
controller: passwordController,
obscureText: true,
decoration: InputDecoration(
hintText: "Password",
filled: true,
fillColor: Colors.grey.shade100,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(15),
borderSide: BorderSide.none,
),
),
),

const SizedBox(height: 25),

SizedBox(
width: double.infinity,
height: 55,
child: ElevatedButton(
onPressed: () async {
String? result =
await authService.loginUser(
email: emailController.text.trim(),
password: passwordController.text.trim(),
);

if (!mounted) return;

if (result == null) {

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) =>
const VerifyMpinScreen(),
),
);

} else {

ScaffoldMessenger.of(context)
.showSnackBar(
SnackBar(
content: Text(result),
),
);
}
},
style: ElevatedButton.styleFrom(
backgroundColor:
const Color(0xFF5ED3C5),
shape: RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),
),
child: const Text(
"LOGIN",
style: TextStyle(
color: Colors.white,
fontWeight: FontWeight.bold,
),
),
),
),

const SizedBox(height: 10),

TextButton(
onPressed: () {
Navigator.push(
context,
MaterialPageRoute(
builder: (_) =>
const RegisterScreen(),
),
);
},
child: const Text(
"Create New Account",
),
),
],
),
),
),
),
),
],
),
    );
  }
}