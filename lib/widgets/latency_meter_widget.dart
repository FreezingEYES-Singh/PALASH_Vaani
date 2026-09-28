import 'package:flutter/material.dart';

class LatencyMeterWidget extends StatelessWidget {
  final int asrMs;
  final int mtMs;
  final int ttsMs;
  final int totalMs;
  final bool isFastPath;

  const LatencyMeterWidget({
    super.key,
    required this.asrMs,
    required this.mtMs,
    required this.ttsMs,
    required this.totalMs,
    this.isFastPath = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWithinTarget = totalMs <= 3000;
    final targetFraction = (totalMs / 3000.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark slate
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWithinTarget ? const Color(0xFF10B981).withOpacity(0.4) : Colors.red.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed, size: 18, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  const Text(
                    'LATENCY BUDGET (SUB-3S TARGET)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isWithinTarget ? const Color(0xFF065F46) : Colors.red.shade900,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isWithinTarget ? '✓ ${totalMs}ms (< 3.0s)' : '⚠️ Exceeded',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Latency Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: targetFraction,
              backgroundColor: const Color(0xFF1E293B),
              valueColor: AlwaysStoppedAnimation<Color>(
                isWithinTarget ? const Color(0xFF10B981) : Colors.red,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),

          // Component breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetricChip('Streaming ASR', '${asrMs}ms', const Color(0xFF60A5FA)),
              _buildMetricChip(
                isFastPath ? 'FLN Cache MT' : 'Distilled MT',
                '${mtMs}ms',
                isFastPath ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
              ),
              _buildMetricChip('Piper TTS', '${ttsMs}ms', const Color(0xFFA78BFA)),
              _buildMetricChip('Total Pipeline', '${totalMs}ms', const Color(0xFF10B981)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 9)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
