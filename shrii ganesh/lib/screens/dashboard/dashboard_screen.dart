import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_screen.dart';
import '../auth/login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    final userName =
        user?.email?.split("@")[0] ?? "User";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.all(20),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F9D8A),
                      Color(0xFF5ED3C5),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),

                child: Column(
                  children: [

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [

                        const Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),

                        Image.asset(
                          "assets/icons/logo.png",
                          height: 50,
                        ),

                        IconButton(
                          icon: const Icon(
                            Icons.menu,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),

                      ],
                    ),

                    const SizedBox(height: 20),

                    Text(
                      "Welcome, $userName 👋",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "Good Morning",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                    ),
                  ],
                ),

                child: const Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Available Balance",
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "₹25,000",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "A/C •••• 5678",
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  top: 10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(15),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceAround,

                  children: [

                    quickButton(
                      Icons.send,
                      "Transfer",
                    ),

                    quickButton(
                      Icons.payment,
                      "Pay",
                    ),

                    quickButton(
                      Icons.account_balance,
                      "Loan",
                    ),

                    quickButton(
                      Icons.credit_card,
                      "Cards",
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  top: 10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Recent Transactions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              transactionTile(
                "Credit",
                "₹500",
                Icons.arrow_downward,
                Colors.green,
              ),

              transactionTile(
                "Debit",
                "₹200",
                Icons.arrow_upward,
                Colors.red,
              ),

              transactionTile(
                "Credit",
                "₹1000",
                Icons.arrow_downward,
                Colors.green,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  static Widget quickButton(
      IconData icon,
      String text) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor:
          const Color(0xFF0F9D8A),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(text),
      ],
    );
  }

  static Widget transactionTile(
      String title,
      String amount,
      IconData icon,
      Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 5,
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: color,
        ),
        title: Text(title),
        trailing: Text(amount),
      ),
    );
  }
}