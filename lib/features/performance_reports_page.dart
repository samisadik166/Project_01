import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/progress_repository.dart';
import '../model/progress_report.dart';
import '../utils/app_colors.dart';
import '../widgets/parental_gate.dart';
import '../widgets/progress_report_view.dart';

class PerformanceReportsPage extends StatefulWidget {
  final String childId;
  final ProgressRepository? repository;

  const PerformanceReportsPage({
    super.key,
    required this.childId,
    this.repository,
  });

  @override
  State<PerformanceReportsPage> createState() => _PerformanceReportsPageState();
}

class _PerformanceReportsPageState extends State<PerformanceReportsPage> {
  static final _defaultRepository = FirestoreProgressRepository();
  ProgressRepository get _repository => widget.repository ?? _defaultRepository;

  ProgressDateRange _dateRange = ProgressDateRange.week;
  Future<ProgressReport>? _reportFuture;
  bool _gatePassed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkParentGate());
  }

  Future<void> _checkParentGate() async {
    final passed = await showParentalGate(context);
    if (!mounted) return;
    if (!passed) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _gatePassed = true;
      _loadReport();
    });
  }

  void _loadReport() {
    _reportFuture = _repository.loadReport(
      childId: widget.childId,
      dateRange: _dateRange,
    );
  }

  void _changeDateRange(ProgressDateRange range) {
    setState(() {
      _dateRange = range;
      _loadReport();
    });
  }

  Future<void> _exportPdf(ProgressReport report) async {
    final document = pw.Document();
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Little Learners Progress Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.pink700,
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Text('${report.childName}  •  Age ${report.age}'),
            pw.Text('Period: ${_dateRange.label}'),
            pw.Divider(),
            pw.Wrap(
              spacing: 18,
              runSpacing: 8,
              children: [
                pw.Text('Total stars: ${report.totalStars}'),
                pw.Text('Badges earned: ${report.badgesEarned}'),
                pw.Text('Activities: ${report.activitiesCompleted}'),
                pw.Text('Learning streak: ${report.learningStreak} days'),
              ],
            ),
            pw.SizedBox(height: 22),
            pw.Text(
              'Learning progress',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            ...report.subjects.map(
              (subject) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 5),
                child: pw.Row(
                  children: [
                    pw.Expanded(child: pw.Text(subject.subject)),
                    pw.Text(
                      '${subject.percentage}%  •  ${subject.encouragement}',
                    ),
                  ],
                ),
              ),
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              'Weekly activity',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Mon ${report.weeklyActivity[0]}   Tue ${report.weeklyActivity[1]}   '
              'Wed ${report.weeklyActivity[2]}   Thu ${report.weeklyActivity[3]}   '
              'Fri ${report.weeklyActivity[4]}   Sat ${report.weeklyActivity[5]}   '
              'Sun ${report.weeklyActivity[6]}',
            ),
            pw.Spacer(),
            pw.Text(
              'Keep going! Every little step is a big achievement.',
              style: pw.TextStyle(
                fontSize: 14,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.teal700,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      await Printing.sharePdf(
        bytes: await document.save(),
        filename: 'little_learners_${report.childName}_report.pdf',
      );
    } catch (error) {
      debugPrint('Could not export the progress report PDF: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create the report PDF.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Report'),
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
      ),
      body: !_gatePassed
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<ProgressReport>(
              future: _reportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.pink),
                  );
                }
                if (snapshot.hasError) {
                  return _ReportLoadError(onRetry: () => setState(_loadReport));
                }
                final report = snapshot.data;
                if (report == null) {
                  return _ReportLoadError(onRetry: () => setState(_loadReport));
                }
                return ProgressReportView(
                  report: report,
                  dateRange: _dateRange,
                  onDateRangeChanged: _changeDateRange,
                  onExport: () => _exportPdf(report),
                );
              },
            ),
    );
  }
}

class _ReportLoadError extends StatelessWidget {
  final VoidCallback onRetry;

  const _ReportLoadError({required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'We could not load the report just now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}
