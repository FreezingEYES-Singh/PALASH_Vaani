import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DualScriptText extends StatelessWidget {
  final String olChikiText;
  final String phoneticDevanagari;
  final String? latinPhonetic;
  final double fontSize;
  final Color? olChikiColor;
  final Color? devaColor;
  final bool isCenter;

  const DualScriptText({
    super.key,
    required this.olChikiText,
    required this.phoneticDevanagari,
    this.latinPhonetic,
    this.fontSize = 22,
    this.olChikiColor,
    this.devaColor,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final crossAlign = isCenter ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: crossAlign,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Native Ol Chiki Script
        Text(
          olChikiText,
          textAlign: isCenter ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.notoSansOlChiki(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: olChikiColor ?? const Color(0xFF1E4D2B), // Forest Green
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),

        // Phonetic Devanagari Pronunciation Guide for Hindi Teacher
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3CD), // Warm amber tint
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFFFD56B), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.record_voice_over, size: 13, color: Color(0xFF996500)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  phoneticDevanagari,
                  textAlign: isCenter ? TextAlign.center : TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: fontSize * 0.65,
                    fontWeight: FontWeight.w600,
                    color: devaColor ?? const Color(0xFF7A4F01),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (latinPhonetic != null && latinPhonetic!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            latinPhonetic!,
            textAlign: isCenter ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              fontSize: fontSize * 0.55,
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }
}
