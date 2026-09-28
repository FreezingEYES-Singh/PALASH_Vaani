import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/worksheet_template.dart';

class PdfExportService {
  /// Generates and triggers printable A4 bilingual worksheet with authentic fonts
  static Future<void> printWorksheet(WorksheetTemplate template) async {
    final pdf = pw.Document();

    // Load Devanagari & Ol Chiki fonts with offline asset priority
    pw.Font fontDeva;
    pw.Font fontOlChiki;

    try {
      final devaBytes = await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf');
      fontDeva = pw.Font.ttf(devaBytes);
    } catch (_) {
      fontDeva = await PdfGoogleFonts.notoSansDevanagariRegular();
    }

    try {
      final olChikiBytes = await rootBundle.load('assets/fonts/NotoSansOlChiki-Regular.ttf');
      fontOlChiki = pw.Font.ttf(olChikiBytes);
    } catch (_) {
      fontOlChiki = await PdfGoogleFonts.notoSansOlChikiRegular();
    }

    final fallbackList = [fontOlChiki, fontDeva];

    final titleStyle = pw.TextStyle(
      font: fontDeva,
      fontFallback: fallbackList,
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey900,
    );

    final tribalTitleStyle = pw.TextStyle(
      font: fontOlChiki,
      fontFallback: fallbackList,
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.green900,
    );

    final regularStyle = pw.TextStyle(
      font: fontDeva,
      fontFallback: fallbackList,
      fontSize: 9,
      color: PdfColors.grey800,
    );

    final boldStyle = pw.TextStyle(
      font: fontDeva,
      fontFallback: fallbackList,
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.black,
    );

    final tribalPromptStyle = pw.TextStyle(
      font: fontOlChiki,
      fontFallback: fallbackList,
      fontSize: 10,
      color: PdfColors.green900,
      fontWeight: pw.FontWeight.bold,
    );

    final answerBoxStyle = pw.TextStyle(
      font: fontOlChiki,
      fontFallback: fallbackList,
      fontSize: 12,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.grey900,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: fontDeva,
          bold: fontDeva,
          fontFallback: fallbackList,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.green800, width: 2),
                  borderRadius: pw.BorderRadius.circular(8),
                  color: PdfColors.green50,
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'GOVERNMENT OF JHARKHAND - PALASH MTB-MLE',
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green900,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'NIPUN Bharat Foundational Literacy & Numeracy (FLN)',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Competency Code: ${template.nipunOutcomeCode}',
                          style: const pw.TextStyle(
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.orange700,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        'GRADE: ${template.grade.name.toUpperCase()}',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // Student Details Bar
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Student Name / छात्र का नाम: ____________________', style: regularStyle),
                    pw.Text('Roll No: ______', style: regularStyle),
                    pw.Text('Date / दिनांक: __________', style: regularStyle),
                  ],
                ),
              ),

              pw.SizedBox(height: 12),

              // Title Section
              pw.Text(
                'अभ्यास पत्रक: ${template.titleHindi}',
                style: titleStyle,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Santhali / Ol Chiki: ${template.titleSanthali}',
                style: tribalTitleStyle,
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'NIPUN Learning Outcome: ${template.nipunOutcomeText}',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),

              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 8),

              // Exercise Items
              pw.Expanded(
                child: pw.ListView.builder(
                  itemCount: template.items.length,
                  itemBuilder: (context, index) {
                    final item = template.items[index];
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 10),
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Item index badge
                          pw.Container(
                            width: 24,
                            height: 24,
                            alignment: pw.Alignment.center,
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.grey200,
                              shape: pw.BoxShape.circle,
                            ),
                            child: pw.Text('${index + 1}', style: boldStyle),
                          ),
                          pw.SizedBox(width: 14),

                          // Text Prompts (Hindi + Ol Chiki + Phonetic guide)
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  item.promptHindi,
                                  style: boldStyle,
                                ),
                                pw.SizedBox(height: 2),
                                pw.Text(
                                  'Tribal Prompt: ${item.promptTribal}',
                                  style: tribalPromptStyle,
                                ),
                                pw.Text(
                                  'Phonetic Guide: ${item.phoneticPrompt}',
                                  style: regularStyle,
                                ),
                              ],
                            ),
                          ),

                          // Answer Box with dotted tracing/writing border
                          pw.Container(
                            width: 130,
                            height: 38,
                            alignment: pw.Alignment.center,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey500, style: pw.BorderStyle.dashed),
                              borderRadius: pw.BorderRadius.circular(4),
                              color: PdfColors.grey50,
                            ),
                            child: pw.Text(
                              item.answerKey,
                              style: answerBoxStyle,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Teacher Evaluation Footer
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Teacher Signature / शिक्षक हस्ताक्षर: __________', style: regularStyle),
                    pw.Text('Grade / मूल्यांकन: [ A ]  [ B ]  [ C ]', style: boldStyle),
                    pw.Text('PALASH-Vaani Bilingual Generator', style: regularStyle),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: '${template.id}_bilingual_worksheet.pdf',
    );
  }
}
