// Do not modify this file.

import 'dart:math';
import '../models/assessment.dart';

const _kData = [
  Assessment(
    id: '1',
    title: 'Flutter Intermediate Certification',
    domain: AssessmentDomain.flutter,
    status: AssessmentStatus.upcoming,
    durationMinutes: 60,
  ),
  Assessment(
    id: '2',
    title: 'Advanced Dart Patterns',
    domain: AssessmentDomain.flutter,
    status: AssessmentStatus.upcoming,
    durationMinutes: 40,
  ),
  Assessment(
    id: '3',
    title: 'AI/ML Fundamentals',
    domain: AssessmentDomain.aiMl,
    status: AssessmentStatus.completed,
    durationMinutes: 45,
  ),
  Assessment(
    id: '4',
    title: 'Prompt Engineering Basics',
    domain: AssessmentDomain.aiMl,
    status: AssessmentStatus.upcoming,
    durationMinutes: 30,
  ),
  Assessment(
    id: '5',
    title: 'DevOps & CI/CD Pipelines',
    domain: AssessmentDomain.devOps,
    status: AssessmentStatus.upcoming,
    durationMinutes: 50,
  ),
  Assessment(
    id: '6',
    title: 'Container Orchestration Essentials',
    domain: AssessmentDomain.devOps,
    status: AssessmentStatus.inProgress,
    durationMinutes: 55,
  ),
  Assessment(
    id: '7',
    title: 'React & Fullstack Fundamentals',
    domain: AssessmentDomain.fullstack,
    status: AssessmentStatus.completed,
    durationMinutes: 75,
  ),
  Assessment(
    id: '8',
    title: 'System Design for Scale',
    domain: AssessmentDomain.distributedSystems,
    status: AssessmentStatus.upcoming,
    durationMinutes: 90,
  ),
];

/// Simulates a remote API with variable latency.
/// Prints a debug line whenever a real fetch fires so cache behaviour is observable.
class FakeApiClient {
  final _random = Random();

  Future<List<Assessment>> fetchAssessments(AssessmentDomain domain) async {
    // Variable delay: between 300ms and 1100ms to make stale-response races observable.
    final delayMs = 300 + _random.nextInt(800);
    debugLog('[FakeApiClient] Fetching domain=${domain.label} (delay=${delayMs}ms)');
    await Future.delayed(Duration(milliseconds: delayMs));

    if (domain == AssessmentDomain.all) return List.of(_kData);
    return _kData.where((a) => a.domain == domain).toList();
  }

  // Simple debug helper — avoids a dart:developer import requirement.
  void debugLog(String message) {
    // ignore: avoid_print
    print(message);
  }
}
