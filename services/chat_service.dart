import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageBase64;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.imageBase64,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'role': isUser ? 'user' : 'assistant',
    'content': text,
  };
}

class ChatService extends ChangeNotifier {
  // ── Change this to your Mac's IP when testing on real Android device
  // For emulator use: http://10.0.2.2:8000
  // For real device: http://YOUR_MAC_IP:8000 (e.g. http://192.168.1.5:8000)
  static const String _baseUrl = 'http://10.0.2.2:8000';

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isConnected = false;
  String _currentTypingText = '';

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String get currentTypingText => _currentTypingText;

  ChatService() {
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      _isConnected = response.statusCode == 200;
    } catch (_) {
      _isConnected = false;
    }
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(text: text, isUser: true);
    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    try {
      // Build conversation history
      final history = _messages
          .take(_messages.length - 1)
          .map((m) => m.toJson())
          .toList();

      final response = await http.post(
        Uri.parse('$_baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'language': 'tamil',
          'conversation_history': history,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final aiMsg = ChatMessage(
          text: data['response'],
          isUser: false,
        );
        _messages.add(aiMsg);
      } else {
        _addErrorMessage();
      }
    } catch (e) {
      debugPrint('Chat error: $e');
      _addErrorMessage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendImageMessage(String base64Image, String question) async {
    // Add user message showing they sent an image
    _messages.add(ChatMessage(
      text: question,
      isUser: true,
      imageBase64: base64Image,
    ));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/analyze-image'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image_base64': base64Image,
          'question': question,
        }),
      ).timeout(const Duration(seconds: 90));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        _messages.add(ChatMessage(
          text: data['response'],
          isUser: false,
        ));
      } else {
        _addErrorMessage();
      }
    } catch (e) {
      _addErrorMessage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getQuickAnswer(String topicId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/quick-question?topic_id=$topicId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['response'];
      }
    } catch (_) {}
    return null;
  }

  void _addErrorMessage() {
    _messages.add(ChatMessage(
      text: 'மன்னிக்கவும், இப்போது பதில் சொல்ல முடியவில்லை. '
            'கொஞ்சம் நேரம் கழித்து முயற்சிக்கவும்.',
      isUser: false,
    ));
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }
}
