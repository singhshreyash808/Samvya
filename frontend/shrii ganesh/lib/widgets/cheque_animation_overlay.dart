import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Shows a custom full-screen overlay animation of a cheque flying across the screen.
class ChequeAnimationOverlay {
  static void show(BuildContext context, String amountStr, VoidCallback onComplete) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry? overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _ChequeAnimationWidget(
        amountStr: amountStr,
        onComplete: () {
          overlayEntry?.remove();
          onComplete();
        },
      ),
    );
    
    overlayState.insert(overlayEntry);
  }
}

class _ChequeAnimationWidget extends StatefulWidget {
  final String amountStr;
  final VoidCallback onComplete;

  const _ChequeAnimationWidget({
    required this.amountStr,
    required this.onComplete,
  });

  @override
  State<_ChequeAnimationWidget> createState() => _ChequeAnimationWidgetState();
}

class _ChequeAnimationWidgetState extends State<_ChequeAnimationWidget> with TickerProviderStateMixin {
  late AnimationController _slideInController;
  late AnimationController _flyOutController;
  late AnimationController _stampController;
  
  late Animation<Offset> _slideInAnimation;
  late Animation<Offset> _flyOutAnimation;
  late Animation<double> _stampScaleAnimation;
  late Animation<double> _stampOpacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // 1. Slide in from left
    _slideInController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideInAnimation = Tween<Offset>(begin: const Offset(-1.5, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideInController, curve: Curves.easeOutBack),
    );

    // 2. Stamp the amount
    _stampController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _stampScaleAnimation = Tween<double>(begin: 3.0, end: 1.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.bounceOut),
    );
    _stampOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _stampController, curve: Curves.easeIn),
    );

    // 3. Fly out to top right
    _flyOutController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _flyOutAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(1.5, -1.5)).animate(
      CurvedAnimation(parent: _flyOutController, curve: Curves.easeInBack),
    );

    _runAnimationSequence();
  }

  Future<void> _runAnimationSequence() async {
    // Slide cheque in
    await _slideInController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Stamp the amount on the cheque
    await _stampController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Fly the cheque out
    await _flyOutController.forward();
    
    widget.onComplete();
  }

  @override
  void dispose() {
    _slideInController.dispose();
    _flyOutController.dispose();
    _stampController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54, // Dim background
      child: Center(
        child: SlideTransition(
          position: _flyOutController.isAnimating ? _flyOutAnimation : _slideInAnimation,
          child: Transform.rotate(
            angle: -math.pi / 24, // Slight tilt for realism
            child: Container(
              width: 320,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F7F1), // Creamy cheque paper color
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade400, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(5, 5))
                ],
              ),
              child: Stack(
                children: [
                  // Cheque background pattern (watermark simulation)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05,
                      child: Icon(Icons.account_balance, size: 100, color: Colors.blue.shade900),
                    ),
                  ),
                  
                  // Cheque Header
                  Positioned(
                    top: 16, left: 20,
                    child: Text(
                      "SAMVYA BANK",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue.shade900),
                    ),
                  ),
                  Positioned(
                    top: 16, right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue.shade900),
                      ),
                      child: const Text("CHEQUE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  // Signature line
                  Positioned(
                    bottom: 20, right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(width: 100, height: 1, color: Colors.black),
                        const SizedBox(height: 4),
                        const Text("Authorized Signatory", style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),

                  // The Stamped Amount
                  Positioned(
                    top: 60, right: 20,
                    child: AnimatedBuilder(
                      animation: _stampController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _stampScaleAnimation.value,
                          child: Opacity(
                            opacity: _stampOpacityAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red.shade700, width: 2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "₹${widget.amountStr}",
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Courier',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Pay to line
                  Positioned(
                    top: 70, left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Pay to:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(height: 4),
                        Container(width: 140, height: 1, color: Colors.black),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
