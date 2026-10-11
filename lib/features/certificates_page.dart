import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/progress_repository.dart';
import '../model/certificate_milestone.dart';
import '../model/progress_report.dart';
import '../utils/app_colors.dart';
import '../widgets/achievement_certificate.dart';

class CertificatesPage extends StatefulWidget {
  final String childId;
  final ProgressRepository? repository;

  const CertificatesPage({super.key, required this.childId, this.repository});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends State<CertificatesPage> {
  static final _defaultRepository = FirestoreProgressRepository();
  ProgressRepository get _repository => widget.repository ?? _defaultRepository;
  late Future<ProgressReport> _reportFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _reportFuture = _repository.loadReport(
      childId: widget.childId,
      dateRange: ProgressDateRange.allTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificates'),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ProgressReport>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'We could not load certificates just now.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: AppColors.darkGray),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => setState(_load),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }
          final report = snapshot.data;
          if (report == null) {
            return const Center(child: Text('No certificate information yet.'));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Your achievements',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Keep learning to unlock a certificate!',
                style: TextStyle(fontSize: 17, color: AppColors.darkGray),
              ),
              const SizedBox(height: 18),
              for (final milestone in certificateMilestones)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _MilestoneCard(
                    milestone: milestone,
                    unlocked: milestone.isUnlocked(report),
                    onTap: () {
                      if (!milestone.isUnlocked(report)) return;
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CertificatePreviewPage(
                            childName: report.childName,
                            milestone: milestone,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final CertificateMilestone milestone;
  final bool unlocked;
  final VoidCallback onTap;

  const _MilestoneCard({
    required this.milestone,
    required this.unlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? AppColors.teal : Colors.blueGrey.shade300;
    return Material(
      color: unlocked ? Colors.white : const Color(0xFFE9ECEF),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: unlocked ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Text(
                unlocked ? milestone.emoji : '🔒',
                style: TextStyle(fontSize: 46, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      milestone.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: unlocked
                            ? AppColors.darkGray
                            : Colors.blueGrey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unlocked
                          ? milestone.achievement
                          : milestone.goalDescription,
                      style: TextStyle(
                        fontSize: 15,
                        color: unlocked
                            ? AppColors.darkGray
                            : Colors.blueGrey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                unlocked
                    ? Icons.workspace_premium_rounded
                    : Icons.lock_outline_rounded,
                color: color,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CertificatePreviewPage extends StatelessWidget {
  final String childName;
  final CertificateMilestone milestone;
  final DateTime? completedAt;

  const CertificatePreviewPage({
    super.key,
    required this.childName,
    required this.milestone,
    this.completedAt,
  });

  DateTime get _date => completedAt ?? DateTime.now();

  Future<Uint8List> _makePdf() async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.pink, width: 5),
          ),
          padding: const pw.EdgeInsets.all(18),
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.amber, width: 2),
            ),
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: [
                pw.Text('★   ★   ★', style: const pw.TextStyle(fontSize: 24)),
                pw.Text(
                  'Certificate of Achievement',
                  style: pw.TextStyle(
                    fontSize: 30,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple,
                  ),
                ),
                pw.Text(
                  childName,
                  style: pw.TextStyle(
                    fontSize: 34,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.Text(
                  milestone.achievement,
                  style: const pw.TextStyle(fontSize: 20),
                ),
                pw.Text(
                  '${_date.day}/${_date.month}/${_date.year}',
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _pdfSignature('Parent / Teacher'),
                    _pdfSignature('Little Learner'),
                  ],
                ),
                pw.Text('★   ★   ★', style: const pw.TextStyle(fontSize: 24)),
              ],
            ),
          ),
        ),
      ),
    );
    return document.save();
  }

  pw.Widget _pdfSignature(String label) => pw.SizedBox(
    width: 180,
    child: pw.Column(
      children: [
        pw.Divider(color: PdfColors.black),
        pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
      ],
    ),
  );

  Future<void> _savePdf(BuildContext context) async {
    try {
      final bytes = await _makePdf();
      await Printing.layoutPdf(
        name: 'certificate_${milestone.id}.pdf',
        onLayout: (_) async => bytes,
      );
    } catch (error) {
      if (context.mounted) _showError(context, error);
    }
  }

  Future<void> _print(BuildContext context) => _savePdf(context);

  Future<void> _share(BuildContext context) async {
    try {
      await Printing.sharePdf(
        bytes: await _makePdf(),
        filename: 'certificate_${milestone.id}.pdf',
      );
    } catch (error) {
      if (context.mounted) _showError(context, error);
    }
  }

  void _showError(BuildContext context, Object error) {
    debugPrint('Could not export certificate: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not prepare the certificate PDF.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certificate preview'),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 900,
                    maxHeight: constraints.maxHeight * 0.62,
                  ),
                  child: AchievementCertificate(
                    childName: childName,
                    milestone: milestone,
                    date: _date,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => _savePdf(context),
                    icon: const Icon(Icons.save_alt_rounded),
                    label: const Text('Save as PDF'),
                  ),
                  FilledButton.icon(
                    onPressed: () => _print(context),
                    icon: const Icon(Icons.print_rounded),
                    label: const Text('Print'),
                  ),
                  FilledButton.icon(
                    onPressed: () => _share(context),
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
