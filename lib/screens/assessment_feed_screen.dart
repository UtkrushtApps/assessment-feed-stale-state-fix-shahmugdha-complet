import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/assessment.dart';
import '../state/assessment_feed_notifier.dart';

class AssessmentFeedScreen extends StatelessWidget {
  const AssessmentFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<AssessmentFeedNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Assessments'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BUG (Problem 4): _buildFilterChipRow is a private method on this widget.
          // Any notifyListeners() call — including loading state toggles — rebuilds this
          // entire screen, including the chip row, even when chip data has not changed.
          // Extract this into a standalone StatelessWidget in lib/widgets/filter_chip_row.dart.
          _buildFilterChipRow(context, notifier),
          const Divider(height: 1),
          Expanded(
            child: _buildBody(notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChipRow(
    BuildContext context,
    AssessmentFeedNotifier notifier,
  ) {
    const domains = AssessmentDomain.values;
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: domains.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final domain = domains[index];
          return FilterChip(
            label: Text(domain.label),
            selected: notifier.selectedDomain == domain,
            onSelected: (_) => notifier.loadForDomain(domain),
          );
        },
      ),
    );
  }

  Widget _buildBody(AssessmentFeedNotifier notifier) {
    if (notifier.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (notifier.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                notifier.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.loadForDomain(notifier.selectedDomain),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (notifier.results.isEmpty) {
      return const Center(child: Text('No assessments found.'));
    }
    return ListView.builder(
      itemCount: notifier.results.length,
      itemBuilder: (context, index) {
        final assessment = notifier.results[index];
        return _AssessmentTile(assessment: assessment);
      },
    );
  }
}

class _AssessmentTile extends StatelessWidget {
  const _AssessmentTile({required this.assessment});

  final Assessment assessment;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(assessment.title),
      subtitle: Text(
        '${assessment.domain.label} • ${assessment.durationMinutes} min',
      ),
      trailing: _StatusBadge(status: assessment.status),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AssessmentStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      AssessmentStatus.upcoming => (
          'Upcoming',
          Colors.blue.shade100,
          Colors.blue.shade800,
        ),
      AssessmentStatus.inProgress => (
          'In Progress',
          Colors.orange.shade100,
          Colors.orange.shade800,
        ),
      AssessmentStatus.completed => (
          'Completed',
          Colors.green.shade100,
          Colors.green.shade800,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
