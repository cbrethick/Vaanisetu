import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechService extends ChangeNotifier {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _speechAvailable = false;
  String _recognizedText = '';
  double _confidence = 0.0;

  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get speechAvailable => _speechAvailable;
  String get recognizedText => _recognizedText;
  double get confidence => _confidence;

  SpeechService() {
    _initSpeech();
    _initTTS();
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speechToText.initialize(
      onError: (error) {
        debugPrint('STT Error: $error');
        _isListening = false;
        notifyListeners();
      },
      onStatus: (status) {
        debugPrint('STT Status: $status');
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          notifyListeners();
        }
      },
    );
    notifyListeners();
  }

  Future<void> _initTTS() async {
    // Try Tamil locale, fall back to Indian English
    await _flutterTts.setLanguage('ta-IN');
    await _flutterTts.setSpeechRate(0.5);   // Slower for clarity
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isSpeaking = true;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      _isSpeaking = false;
      notifyListeners();
    });
  }

  /// Start listening for Tamil speech
  Future<void> startListening({Function(String)? onResult}) async {
    if (!_speechAvailable || _isListening) return;

    _recognizedText = '';
    _isListening = true;
    notifyListeners();

    await _speechToText.listen(
      onResult: (result) {
        _recognizedText = result.recognizedWords;
        _confidence = result.confidence;

        if (result.finalResult && onResult != null) {
          onResult(_recognizedText);
        }
        notifyListeners();
      },
      // Tamil locale — works on most Android devices with Tamil keyboard installed
      localeId: 'ta_IN',
      listenMode: ListenMode.confirmation,
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(seconds: 30),
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    notifyListeners();
  }

  /// Speak text in Tamil
  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    // Stop any ongoing speech
    if (_isSpeaking) {
      await stop();
    }

    // Clean text for TTS (remove markdown, special chars)
    final cleanText = text
        .replaceAll('**', '')
        .replaceAll('*', '')
        .replaceAll('#', '')
        .replaceAll('`', '')
        .trim();

    await _flutterTts.speak(cleanText);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  /// Toggle listening
  Future<String?> toggleListening() async {
    if (_isListening) {
      await stopListening();
      return _recognizedText;
    } else {
      await startListening();
      return null;
    }
  }

  @override
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    super.dispose();
  }
}
