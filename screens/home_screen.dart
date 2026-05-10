import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../services/chat_service.dart';
import '../services/speech_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/topic_card.dart';
import '../widgets/mic_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _pulseController;
  bool _showChat = false;

  // Topic quick-buttons
  final List<Map<String, String>> _topics = [
    {'id': 'govt', 'emoji': '🏛️', 'tamil': 'அரசு திட்டங்கள்', 'sub': 'Government Schemes'},
    {'id': 'health', 'emoji': '🏥', 'tamil': 'உடல் நலம்', 'sub': 'Health'},
    {'id': 'farming', 'emoji': '🌾', 'tamil': 'விவசாயம்', 'sub': 'Farming'},
    {'id': 'education', 'emoji': '📚', 'tamil': 'கல்வி', 'sub': 'Education'},
    {'id': 'rights', 'emoji': '⚖️', 'tamil': 'உரிமைகள்', 'sub': 'Rights'},
    {'id': 'emergency', 'emoji': '🚨', 'tamil': 'அவசர உதவி', 'sub': 'Emergency'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    _textController.clear();
    setState(() => _showChat = true);

    final chatService = context.read<ChatService>();
    await chatService.sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );

    if (image == null) return;

    final bytes = await File(image.path).readAsBytes();
    final base64Image = base64Encode(bytes);

    setState(() => _showChat = true);

    if (!mounted) return;
    await context.read<ChatService>().sendImageMessage(
      base64Image,
      'இந்த படத்தில் என்ன இருக்கிறது? தமிழில் சொல்லுங்கள்.',
    );
    _scrollToBottom();
  }

  Future<void> _onTopicTap(String topicId) async {
    setState(() => _showChat = true);
    final chatService = context.read<ChatService>();

    final topicQuestions = {
      'govt': 'தமிழ்நாட்டில் உள்ள முக்கிய அரசு திட்டங்கள் என்ன? எப்படி விண்ணப்பிப்பது?',
      'health': 'ஆரோக்கியமான வாழ்க்கைக்கான முக்கிய குறிப்புகள் என்ன?',
      'farming': 'தமிழ்நாடு விவசாயிகளுக்கான உதவி திட்டங்கள் என்ன?',
      'education': 'மாணவர்களுக்கான உதவித்தொகை திட்டங்கள் எவை?',
      'rights': 'ஒரு குடிமகனின் அடிப்படை உரிமைகள் என்ன?',
      'emergency': 'அவசர காலங்களில் அழைக்க வேண்டிய எண்கள் என்ன?',
    };

    await chatService.sendMessage(topicQuestions[topicId] ?? 'உதவி வேண்டும்');
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D0D0D),
              Color(0xFF1A0A00),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _showChat ? _buildChatView() : _buildHomeView(),
              ),
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Logo
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE85D04), Color(0xFFFAA307)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('வ', style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
            ),
          ).animate().fadeIn().scale(),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'வாணி சேது',
                style: GoogleFonts.notoSansTamil(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Consumer<ChatService>(
                builder: (_, chat, __) => Text(
                  chat.isConnected ? '● இணைக்கப்பட்டுள்ளது' : '● இணைப்பு இல்லை',
                  style: TextStyle(
                    color: chat.isConnected
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF5252),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Clear chat / Home button
          if (_showChat)
            IconButton(
              icon: const Icon(Icons.home_rounded, color: Color(0xFFFAA307)),
              onPressed: () {
                setState(() => _showChat = false);
                context.read<ChatService>().clearChat();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE85D04), Color(0xFFFAA307)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE85D04).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'வணக்கம்! 🙏',
                  style: GoogleFonts.notoSansTamil(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'உங்கள் கேள்விகளுக்கு தமிழில் பதில் கூறுகிறோம்',
                  style: GoogleFonts.notoSansTamil(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'இணையம் இல்லாமலும் வேலை செய்கிறது',
                      style: GoogleFonts.notoSansTamil(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1),

          const SizedBox(height: 28),

          // Topic grid
          Text(
            'என்ன உதவி வேண்டும்?',
            style: GoogleFonts.notoSansTamil(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              final topic = _topics[index];
              return TopicCard(
                emoji: topic['emoji']!,
                tamilLabel: topic['tamil']!,
                subLabel: topic['sub']!,
                onTap: () => _onTopicTap(topic['id']!),
              ).animate(delay: Duration(milliseconds: index * 80))
               .fadeIn()
               .scale(begin: const Offset(0.8, 0.8));
            },
          ),

          const SizedBox(height: 20),

          // Scan document card
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFE85D04).withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE85D04).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('📄', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ஆவணம் படிக்க',
                          style: GoogleFonts.notoSansTamil(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'படிக்க தெரியாத ஆவணங்களை புகைப்படம் எடுங்கள்',
                          style: GoogleFonts.notoSansTamil(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.camera_alt_rounded,
                    color: Color(0xFFE85D04)),
                ],
              ),
            ),
          ).animate(delay: 500.ms).fadeIn(),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return Consumer<ChatService>(
      builder: (context, chatService, _) {
        _scrollToBottom();
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: chatService.messages.length +
              (chatService.isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == chatService.messages.length) {
              // Loading indicator
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFE85D04),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'யோசிக்கிறேன்...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            final message = chatService.messages[index];
            return ChatBubble(
              message: message,
              onSpeak: (text) {
                context.read<SpeechService>().speak(text);
              },
            ).animate().fadeIn(duration: 300.ms).slideX(
              begin: message.isUser ? 0.1 : -0.1,
            );
          },
        );
      },
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          // Camera button
          IconButton(
            icon: const Icon(Icons.camera_alt_rounded,
              color: Color(0xFF888888), size: 22),
            onPressed: _pickImage,
          ),

          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF333333),
                ),
              ),
              child: TextField(
                controller: _textController,
                style: GoogleFonts.notoSansTamil(
                  color: Colors.white,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'தமிழில் கேளுங்கள்...',
                  hintStyle: GoogleFonts.notoSansTamil(
                    color: const Color(0xFF555555),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: 3,
                minLines: 1,
                onSubmitted: _sendMessage,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Mic button
          MicButton(
            onResult: (text) {
              if (text.isNotEmpty) {
                _sendMessage(text);
              }
            },
          ),

          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: () => _sendMessage(_textController.text),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE85D04), Color(0xFFFAA307)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
