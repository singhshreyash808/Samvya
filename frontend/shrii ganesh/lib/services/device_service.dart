import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

class DeviceService {
  static const FlutterSecureStorage _storage =
  FlutterSecureStorage();

  /// Requests location permission and returns current coordinates.
  /// Returns null silently if permission is denied or location unavailable.
  static Future<Map<String, double>?> getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return {'latitude': pos.latitude, 'longitude': pos.longitude};
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getDeviceInfo() async {

    final deviceInfo = DeviceInfoPlugin();

    final packageInfo =
    await PackageInfo.fromPlatform();

    String? uuid = await _storage.read(
      key: "device_uuid",
    );

    if (uuid == null) {

      uuid = const Uuid().v4();

      await _storage.write(
        key: "device_uuid",
        value: uuid,
      );

    }

    String fcmToken = "";

    try {

      fcmToken =
          await FirebaseMessaging.instance.getToken() ?? "";

    } catch (_) {}

    if (Platform.isAndroid) {

      final android =
      await deviceInfo.androidInfo;

      final location = await getLocation();

      return {

        "device_uuid": uuid,

        "device_name":
        "${android.brand} ${android.model}",

        "brand": android.brand,

        "model": android.model,

        "android_version":
        android.version.release,

        "app_version":
        packageInfo.version,

        "fcm_token": fcmToken,

        "latitude": location?['latitude'],

        "longitude": location?['longitude'],

      };

    }

    return {

      "device_uuid": uuid,

      "device_name": "Unknown",

      "brand": "Unknown",

      "model": "Unknown",

      "android_version": "Unknown",

      "app_version": packageInfo.version,

      "fcm_token": fcmToken,

      "latitude": null,

      "longitude": null,

    };
  }
}