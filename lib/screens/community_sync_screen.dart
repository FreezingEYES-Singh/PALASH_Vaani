import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class CommunitySyncScreen extends StatelessWidget {
  const CommunitySyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4D2B),
        title: const Text('सामुदायिक सुधार व CRC सिंक (Sync Hub)', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Explanation Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.hub, color: Color(0xFF1E4D2B), size: 22),
                      SizedBox(width: 8),
                      Text(
                        'ऑफलाइन सुधार व सीआरसी सिंक (Offline Loop)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'सुदूर गाँव में इंटरनेट न होने पर शिक्षक द्वारा दर्ज किए गए भाषाई सुधार स्थानीय डेटाबेस में सुरक्षित रहते हैं। महीने में एक बार क्लस्टर रिसोर्स सेंटर (CRC) बैठक में वाई-फाई से जुड़ने पर यह स्वचालित रूप से राज्य भाषाविद् टीम को प्रेषित हो जाता है।',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  // Sync Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E4D2B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: appState.isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.sync, color: Colors.white, size: 20),
                      label: Text(
                        appState.isProcessing ? 'सीआरसी सर्वर से सिंक हो रहा है...' : 'सीआरसी सर्वर से अभी सिंक करें (Sync With CRC)',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      onPressed: appState.isProcessing
                          ? null
                          : () async {
                              final count = await appState.syncWithCRC();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF1E4D2B),
                                  content: Text('सफलतापूर्वक $count सुधार CRC सर्वर पर सिंक किए गए! नया भाषा पैक अद्यतित।'),
                                ),
                              );
                            },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pending Offline Feedback Records
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ऑफलाइन सहेजे गए सुधार (Local Pending Records)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${appState.feedbackList.length} Records',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF856404)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (appState.feedbackList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green.shade400, size: 40),
                    const SizedBox(height: 10),
                    const Text('कोई लंबित सुधार नहीं है।', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('कक्षा संवाद में किसी भी वाक्य पर 🚩 फ्लैग दबाकर सुधार दर्ज करें।', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appState.feedbackList.length,
                itemBuilder: (context, index) {
                  final record = appState.feedbackList[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('भाषा: ${record.language} • ${record.district}', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0F2FE),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Offline Queued', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0369A1))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('हिंदी: "${record.sourceHindi}"', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('सुझाव: "${record.correctedTribal}"', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E4D2B))),
                        if (record.teacherNotes.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('नोट: ${record.teacherNotes}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic)),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
