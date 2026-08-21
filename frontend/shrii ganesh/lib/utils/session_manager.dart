import 'dart:async';
import 'package:flutter/material.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  Timer? _timer;
  Timer? _countdownTimer;
  
  // 10 minutes = 600 seconds
  final int timeoutSeconds = 300;
  
  final ValueNotifier<int> remainingSeconds = ValueNotifier<int>(600);
  
  VoidCallback? _onTimeout;

  void initialize(VoidCallback onTimeout) {
    _onTimeout = onTimeout;
    resetSession();
  }

  void resetSession() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    
    remainingSeconds.value = timeoutSeconds;
    
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      }
    });

    _timer = Timer(Duration(seconds: timeoutSeconds), () {
      _countdownTimer?.cancel();
      if (_onTimeout != null) {
        _onTimeout!();
      }
    });
  }
  
  void stopSession() {
    _timer?.cancel();
    _countdownTimer?.cancel();
  }
}
