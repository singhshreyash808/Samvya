import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/voice_assistant_service.dart';
import '../services/api_service.dart';

class VoiceAssistantOverlay extends StatefulWidget {
  final Function(int)? onNavigate;

  const VoiceAssistantOverlay({super.key, this.onNavigate});

  @override
  State<VoiceAssistantOverlay> createState() => _VoiceAssistantOverlayState();

  static void show(BuildContext context, {Function(int)? onNavigate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceAssistantOverlay(onNavigate: onNavigate),
    );
  }
}

class _VoiceAssistantOverlayState extends State<VoiceAssistantOverlay> {
  final VoiceAssistantService _voiceService = VoiceAssistantService();
  final ApiService _apiService = ApiService();
  
  String _recognizedText = "";
  String _responseText = "";
  bool _isListening = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initVoiceService();
  }

  Future<void> _initVoiceService() async {
    await _voiceService.init();
    _startListening();
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _recognizedText = "";
      _responseText = "";
    });
    
    _voiceService.startListening((text) {
      setState(() {
        _recognizedText = text;
      });
    });
  }
  
  Future<void> _stopAndProcess() async {
    await _voiceService.stopListening();
    setState(() {
      _isListening = false;
      _isLoading = true;
    });

    if (_recognizedText.isNotEmpty) {
      final result = await _apiService.queryAssistant(_recognizedText, context.locale.languageCode);
      String responseText = result["response"] ?? "I'm sorry, I couldn't understand that.";

      setState(() {
        _responseText = responseText;
        _isLoading = false;
      });
      await _voiceService.speak(responseText, languageCode: context.locale.languageCode);

      if (result["action"] == "navigate" && widget.onNavigate != null) {
        String target = result["target"] ?? "";
        int index = -1;
        if (target == "home") index = 0;
        else if (target == "money") index = 1;
        else if (target == "scan") index = 2;
        else if (target == "schemes") index = 3;
        else if (target == "profile") index = 4;

        if (index != -1) {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) Navigator.pop(context);
            widget.onNavigate!(index);
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
        _responseText = "I didn't catch that.";
      });
    }
  }

  @override
  void dispose() {
    _voiceService.stopListening();
    _voiceService.stopSpeaking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      height: 350,
      child: Column(
        children: [
          Text(
            "assistant_voice".tr(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: _isLoading 
                ? const CircularProgressIndicator(color: Color(0xff0F9D8A))
                : Text(
                  _responseText.isNotEmpty ? _responseText : _recognizedText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _isListening ? _stopAndProcess : _startListening,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: _isListening ? Colors.red : const Color(0xff0F9D8A),
              child: Icon(
                _isListening ? Icons.stop : Icons.mic,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _isListening ? "assistant_listening".tr() : "Tap to speak",
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
