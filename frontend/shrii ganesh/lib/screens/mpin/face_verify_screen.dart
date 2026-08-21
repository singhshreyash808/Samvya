import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import '../../services/local_storage_service.dart';
import '../dashboard/main_dashboard.dart';

class FaceVerifyScreen extends StatefulWidget {
  const FaceVerifyScreen({super.key});

  @override
  State<FaceVerifyScreen> createState() => _FaceVerifyScreenState();
}

class _FaceVerifyScreenState extends State<FaceVerifyScreen> {
  bool _isScanning = true;
  bool _isSuccess = false;
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );
        _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {});
        }
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
    _simulateFaceVerification();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _simulateFaceVerification() {
    // Simulate a 3 second face scan
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _isSuccess = true;
      });

      // Reset MPIN failed attempts
      await LocalStorageService.resetFailedAttempts();

      // Navigate to dashboard after short delay
      Timer(const Duration(seconds: 1), () {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainDashboard()),
          (route) => false,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      "mpin.face_verify_title".tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 48), // balance back button
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mock Camera View
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isScanning ? const Color(0xff0F9D8A) : (_isSuccess ? Colors.green : Colors.red),
                          width: 4,
                        ),
                        color: Colors.white10,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_cameraController != null && _cameraController!.value.isInitialized)
                            ClipOval(
                              child: SizedBox(
                                width: 250,
                                height: 250,
                                child: CameraPreview(_cameraController!),
                              ),
                            )
                          else
                            Icon(
                              Icons.face,
                              size: 120,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          if (_isScanning)
                            const CircularProgressIndicator(
                              color: Color(0xff0F9D8A),
                              strokeWidth: 6,
                            ),
                          if (!_isScanning && _isSuccess)
                            const Icon(
                              Icons.check_circle,
                              size: 100,
                              color: Colors.green,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _isScanning 
                          ? "mpin.scanning_face".tr() 
                          : (_isSuccess ? "mpin.verify_success".tr() : "mpin.verify_failed".tr()),
                      style: TextStyle(
                        color: _isSuccess ? Colors.green : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isScanning 
                          ? "mpin.position_face".tr() 
                          : "mpin.logging_in".tr(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
