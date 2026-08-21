import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/local_storage_service.dart';
import 'verify_profile_mpin_screen.dart';
import 'edit_profile_screen.dart';


class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {

  String fullName = "";
  String email = "";
  String mobile = "";
  String address = "Not Added";
  String village = "Not Added";
  String district = "Not Added";
  String state = "Not Added";
  String pinCode = "Not Added";
  String accountNumber = "";
  double balance = 0;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {

    fullName = await LocalStorageService.getName();

    email = await LocalStorageService.getEmail();

    mobile = await LocalStorageService.getMobile();

    address = await LocalStorageService.getAddress();

    village = await LocalStorageService.getVillage();

    district = await LocalStorageService.getDistrict();

    state = await LocalStorageService.getState();

    pinCode = await LocalStorageService.getPinCode();

    accountNumber =
    await LocalStorageService.getAccountNumber();

    balance =
    await LocalStorageService.getBalance();

    setState(() {});
  }

  Widget buildTile(
      IconData icon,
      String title,
      String value,
      ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        vertical: 6,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xff0F9D8A),
        ),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: Text("profile.my_profile".tr()),
        backgroundColor: const Color(0xff0F9D8A),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (Locale locale) {
              context.setLocale(locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(
                value: Locale('en'),
                child: Text('English'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('hi'),
                child: Text('हिंदी (Hindi)'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('or'),
                child: Text('ଓଡ଼ିଆ (Odia)'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('ta'),
                child: Text('தமிழ் (Tamil)'),
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(16),

        child: Column(

          children: [

            CircleAvatar(
              radius: 55,
              backgroundColor: const Color(0xff0F9D8A),
              child: Text(
                fullName.isEmpty
                    ? "U"
                    : fullName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              fullName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              email,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            buildTile(
              Icons.person,
              "Full Name",
              fullName,
            ),

            buildTile(
              Icons.phone,
              "Mobile Number",
              mobile,
            ),

            buildTile(
              Icons.email,
              "Email",
              email,
            ),

            buildTile(
              Icons.location_on,
              "Address",
              address,
            ),

            buildTile(
              Icons.home,
              "Village",
              village,
            ),

            buildTile(
              Icons.location_city,
              "District",
              district,
            ),

            buildTile(
              Icons.map,
              "State",
              state,
            ),

            buildTile(
              Icons.pin_drop,
              "PIN Code",
              pinCode,
            ),

            buildTile(
              Icons.account_balance,
              "Account Number",
              accountNumber,
            ),

            buildTile(
              Icons.currency_rupee,
              "Balance",
              "₹ ${balance.toStringAsFixed(2)}",
            ),

            buildTile(
              Icons.verified,
              "KYC Status",
              "Verified",
            ),

            const SizedBox(height: 30),

            SizedBox(

              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xff0F9D8A),
                ),

                icon: const Icon(Icons.edit),

                label: const Text(
                  "Edit Profile",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const VerifyProfileMpinScreen(),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}