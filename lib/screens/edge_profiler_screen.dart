import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class EdgeProfilerScreen extends StatelessWidget {
  const EdgeProfilerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text('हार्डवेयर व मेमोरी प्रोफ़ाइलर (Edge AI)', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tablet_android, color: Color(0xFF10B981), size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TARGET HARDWARE SPECIFICATION',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '2 GB RAM • Android 9.0+ (Pie)',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Quad-Core ARM Cortex-A53 • Zero Cloud Dependency',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // RAM Allocation Budget Card
            const Text(
              'RAM BUDGET ALLOCATION (2,048 MB TOTAL)',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      height: 14,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1200,
                            child: Container(color: const Color(0xFF475569)),
                          ),
                          Expanded(
                            flex: appState.appActiveRamMb,
                            child: Container(color: const Color(0xFF10B981)),
                          ),
                          Expanded(
                            flex: 463,
                            child: Container(color: const Color(0xFF3B82F6)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  _buildRamRow('Android 9 OS & Core Services', '1,200 MB', const Color(0xFF94A3B8)),
                  const Divider(color: Color(0xFF334155), height: 12),
                  _buildRamRow('PALASH-Vaani Active Footprint', '${appState.appActiveRamMb} MB', const Color(0xFF10B981), isBold: true),
                  const Divider(color: Color(0xFF334155), height: 12),
                  _buildRamRow('Safety Headroom (Prevents Android OOM)', '463 MB', const Color(0xFF3B82F6)),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // On-Device Quantized Models Footprint
            const Text(
              'ON-DEVICE QUANTIZED INT8 MODELS (FLASH DISK)',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  _buildModelRow(
                    name: 'IndicConformer Streaming ASR (Hindi / Santali)',
                    size: '85 MB',
                    format: 'INT8 GGUF',
                    status: 'Loaded on Demand',
                  ),
                  const Divider(color: Color(0xFF334155)),
                  _buildModelRow(
                    name: 'Distilled AdiBhashaa MT (Hindi ➔ Santhali/Ho)',
                    size: '115 MB',
                    format: 'INT8 ONNX',
                    status: 'Resident / Cached',
                  ),
                  const Divider(color: Color(0xFF334155)),
                  _buildModelRow(
                    name: 'Piper-ONNX Speech Synthesis (16 kHz Tribal Voice)',
                    size: '75 MB',
                    format: 'INT8 VITS',
                    status: 'Dynamic Paged',
                  ),
                  const Divider(color: Color(0xFF334155)),
                  _buildModelRow(
                    name: 'PALASH SCERT Curriculum Database & Audio Cache',
                    size: '14 MB',
                    format: 'SQLite / Drift',
                    status: 'Pre-Indexed',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // District Dialect Selector & Offline Controls
            const Text(
              'DEPLOYMENT SETTINGS (झारखंड जिला बोली चयन)',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Offline Mode Enforcement', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Simulates 100% disconnected remote tribal school', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    trailing: Switch(
                      value: appState.isOffline,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (_) => appState.toggleOfflineMode(),
                    ),
                  ),
                  const Divider(color: Color(0xFF334155)),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Active District Dialect Pack', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: Text(appState.selectedDistrict, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11)),
                    trailing: DropdownButton<String>(
                      dropdownColor: const Color(0xFF1E293B),
                      value: appState.selectedDistrict,
                      underline: const SizedBox(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      items: const [
                        DropdownMenuItem(value: 'Dumka (Santhal Pargana)', child: Text('Dumka (Santhal Pargana)')),
                        DropdownMenuItem(value: 'West Singhbhum (Kolhan / Ho)', child: Text('West Singhbhum (Kolhan)')),
                        DropdownMenuItem(value: 'Khunti (Mundari Belt)', child: Text('Khunti (Mundari)')),
                        DropdownMenuItem(value: 'Simdega (Kharia / Munda)', child: Text('Simdega')),
                      ],
                      onChanged: (val) {
                        if (val != null) appState.setDistrict(val);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRamRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: const Color(0xFFCBD5E1), fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
        Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildModelRow({
    required String name,
    required String size,
    required String format,
    required String status,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                Text('$format • $status', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(size, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
