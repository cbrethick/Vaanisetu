import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/speech_service.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MicButton extends StatelessWidget {
  final Function(String) onResult;

  const MicButton({
    super.key,
    required this.onResult,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SpeechService>(
      builder: (context, speech, _) {
        final isListening = speech.isListening;

        return GestureDetector(
          onTapDown: (_) => speech.startListening(onResult: onResult),
          onTapUp: (_) => speech.stopListening(),
          onTapCancel: () => speech.stopListening(),
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: isListening ? const Color(0xFFE85D04) : const Color(0xFF1E1E1E),
              shape: BoxShape.circle,
              border: Border.all(
                color: isListening ? const Color(0xFFFAA307) : const Color(0xFF333333),
                width: 2,
              ),
              boxShadow: isListening
                  ? [
                      BoxShadow(
                        color: const Color(0xFFE85D04).withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: Icon(
              isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: isListening ? Colors.white : const Color(0xFF888888),
              size: 28,
            ),
          ),
        ).animate(
          target: isListening ? 1 : 0,
          onComplete: (controller) {
            if (isListening) controller.repeat(reverse: true);
          },
        ).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 600.ms,
          curve: Curves.easeInOut,
        );
      },
    );
  }
}
