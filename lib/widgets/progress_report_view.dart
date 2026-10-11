import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../model/progress_report.dart';
import '../utils/app_colors.dart';

class ProgressReportView extends StatelessWidget {
  final ProgressReport report;
  final ProgressDateRange dateRange;
  final ValueChanged<ProgressDateRange> onDateRangeChanged;
  final VoidCallback onExport;

  const ProgressReportView({
    super.key,
    required this.report,
    required this.dateRange,
    required this.onDateRangeChanged,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _ChildReportHeader(
          report: report,
          dateRange: dateRange,
          onDateRangeChanged: onDateRangeChanged,
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 580 ? 4 : 2;
            final cards = [
              _SummaryCard(
                title: 'Stars',
                value: '${report.totalStars}',
                icon: Icons.star_rounded,
                color: AppColors.yellow,
              ),
              _SummaryCard(
                title: 'Badges',
                value: '${report.badgesEarned}',
                icon: Icons.workspace_premium_rounded,
                color: AppColors.pink,
              ),
              _SummaryCard(
                title: 'Activities',
                value: '${report.activitiesCompleted}',
                icon: Icons.check_circle_rounded,
                color: AppColors.teal,
              ),
              _SummaryCard(
                title: 'Day streak',
                value: '${report.learningStreak}',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.purple,
              ),
            ];
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: columns == 2 ? 1.45 : 1.15,
              children: cards,
            );
          },
        ),
        const SizedBox(height: 22),
        _SectionTitle(title: 'Learning progress'),
        const SizedBox(height: 10),
        _WhiteCard(
          child: Column(
            children: [
              for (var index = 0; index < report.subjects.length; index++) ...[
                _SubjectProgressRow(subject: report.subjects[index]),
                if (index < report.subjects.length - 1)
                  const SizedBox(height: 18),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        _SectionTitle(title: 'This week'),
        const SizedBox(height: 10),
        _WhiteCard(
          child: SizedBox(
            height: 200,
            child: WeeklyActivityChart(values: report.weeklyActivity),
          ),
        ),
        const SizedBox(height: 22),
        _KeepGoingCard(report: report),
        if (report.activitiesCompleted == 0) ...[
          const SizedBox(height: 16),
          const _WhiteCard(
            child: Text(
              'Your learning journey starts here. Try an activity and your progress will appear in this report!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                height: 1.4,
                color: AppColors.darkGray,
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onExport,
          icon: const Icon(Icons.picture_as_pdf_rounded),
          label: const Text(
            'Export report as PDF',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.pink,
            minimumSize: const Size.fromHeight(60),
          ),
        ),
      ],
    );
  }
}

class _ChildReportHeader extends StatelessWidget {
  final ProgressReport report;
  final ProgressDateRange dateRange;
  final ValueChanged<ProgressDateRange> onDateRangeChanged;

  const _ChildReportHeader({
    required this.report,
    required this.dateRange,
    required this.onDateRangeChanged,
  });

  String _avatar(String id) {
    switch (id) {
      case 'cat_1':
        return '🐱';
      case 'rocket_1':
        return '🚀';
      case 'star_1':
        return '⭐';
      case 'bear_1':
      default:
        return '🐻';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.yellow.withValues(alpha: 0.25),
                child: Text(_avatar(report.avatarId), style: const TextStyle(fontSize: 38)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.childName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.darkGray,
                      ),
                    ),
                    Text(
                      report.age > 0 ? 'Age ${report.age}' : 'Little learner',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<ProgressDateRange>(
            initialValue: dateRange,
            decoration: const InputDecoration(
              labelText: 'Report period',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            items: ProgressDateRange.values
                .map(
                  (range) => DropdownMenuItem(
                    value: range,
                    child: Text(range.label),
                  ),
                )
                .toList(),
            onChanged: (range) {
              if (range != null) onDateRangeChanged(range);
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(title, style: const TextStyle(color: AppColors.darkGray)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: AppColors.darkGray,
    ),
  );
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 9,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: child,
  );
}

class _SubjectProgressRow extends StatelessWidget {
  final SubjectProgress subject;

  const _SubjectProgressRow({required this.subject});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                subject.subject,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGray,
                ),
              ),
            ),
            Text(
              '${subject.percentage}%',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: subject.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: subject.percentage / 100,
            minHeight: 14,
            color: subject.color,
            backgroundColor: subject.color.withValues(alpha: 0.16),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subject.encouragement,
          style: const TextStyle(fontSize: 13, color: AppColors.darkGray),
        ),
      ],
    );
  }
}

class WeeklyActivityChart extends StatelessWidget {
  final List<int> values;

  const WeeklyActivityChart({super.key, required this.values});

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: (values.fold<int>(0, (maximum, count) => count > maximum ? count : maximum) + 1)
            .toDouble(),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= _dayLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _dayLabels[index],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGray,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(
          _dayLabels.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: index < values.length ? values[index].toDouble() : 0,
                color: AppColors.teal,
                width: 24,
                borderRadius: BorderRadius.circular(8),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: (values.fold<int>(
                        0,
                        (maximum, count) => count > maximum ? count : maximum,
                      ) +
                      1).toDouble(),
                  color: AppColors.teal.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeepGoingCard extends StatelessWidget {
  final ProgressReport report;

  const _KeepGoingCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final leastPracticed = report.subjects.reduce(
      (left, right) =>
          left.percentage <= right.percentage ? left : right,
    );
    final suggestion = switch (leastPracticed.subject) {
      'Alphabet' => 'Try tracing a new letter together.',
      'Numbers' => 'Try tracing a number together.',
      'Quizzes' => 'Pick a short quiz to explore.',
      'Drawing' => 'Make a colorful picture together.',
      _ => 'Choose a fun game to play together.',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE6F0), Color(0xFFE5FBF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🌟', style: TextStyle(fontSize: 42)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keep going!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  suggestion,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
