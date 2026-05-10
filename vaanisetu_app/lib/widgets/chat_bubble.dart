import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onSpeak;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                _buildMessageContent(),
                const SizedBox(height: 4),
                _buildActionRow(),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: message.isUser
            ? const LinearGradient(colors: [Color(0xFF333333), Color(0xFF444444)])
            : const LinearGradient(colors: [Color(0xFFE85D04), Color(0xFFFAA307)]),
      ),
      child: Center(
        child: Text(
          message.isUser ? 'நீ' : 'வ',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: message.isUser ? const Color(0xFFE85D04) : const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(message.isUser ? 16 : 0),
          bottomRight: Radius.circular(message.isUser ? 0 : 16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.imageBase64 != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  Uri.parse('data:image/png;base64,${message.imageBase64}').data!.contentAsBytes(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Text(
            message.text,
            style: GoogleFonts.notoSansTamil(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    if (message.isUser) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up_rounded, size: 16, color: Colors.grey),
          onPressed: () => onSpeak(message.text),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
        ),
        const SizedBox(width: 8),
        Text(
          _formatTime(message.timestamp),
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
