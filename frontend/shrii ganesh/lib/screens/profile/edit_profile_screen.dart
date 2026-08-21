import 'package:flutter/material.dart';
import '../../services/local_storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final villageController = TextEditingController();
  final districtController = TextEditingController();
  final stateController = TextEditingController();
  final pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {

    nameController.text =
    await LocalStorageService.getName();

    mobileController.text =
    await LocalStorageService.getMobile();

    addressController.text =
    await LocalStorageService.getAddress();

    villageController.text =
    await LocalStorageService.getVillage();

    districtController.text =
    await LocalStorageService.getDistrict();

    stateController.text =
    await LocalStorageService.getState();

    pinController.text =
    await LocalStorageService.getPinCode();
  }

  Future<void> saveProfile() async {

    await LocalStorageService.updateProfile(
      name: nameController.text.trim(),
      mobile: mobileController.text.trim(),
      email: await LocalStorageService.getEmail(),
      address: addressController.text.trim(),
      village: villageController.text.trim(),
      district: districtController.text.trim(),
      state: stateController.text.trim(),
      pinCode: pinController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile Updated Successfully"),
      ),
    );

    Navigator.pop(context);
  }

  Widget buildField(
      TextEditingController controller,
      String label,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: const Color(0xff0F9D8A),
          ),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    villageController.dispose();
    districtController.dispose();
    stateController.dispose();
    pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xff0F9D8A),
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 20),

            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xff0F9D8A),
              child: Text(
                nameController.text.isEmpty
                    ? "U"
                    : nameController.text[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 35,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),

            buildField(
              nameController,
              "Full Name",
              Icons.person,
            ),

            buildField(
              mobileController,
              "Mobile Number",
              Icons.phone,
            ),

            buildField(
              addressController,
              "Address",
              Icons.location_on,
            ),

            buildField(
              villageController,
              "Village",
              Icons.home,
            ),

            buildField(
              districtController,
              "District",
              Icons.location_city,
            ),

            buildField(
              stateController,
              "State",
              Icons.map,
            ),

            buildField(
              pinController,
              "PIN Code",
              Icons.pin_drop,
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

                onPressed: saveProfile,

                icon: const Icon(Icons.save),

                label: const Text(
                  "SAVE PROFILE",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}