import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopicCard extends StatelessWidget {
  final String emoji;
  final String tamilLabel;
  final String subLabel;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.emoji,
    required this.tamilLabel,
    required this.subLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 8),
              Text(
                tamilLabel,
                style: GoogleFonts.notoSansTamil(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subLabel,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
