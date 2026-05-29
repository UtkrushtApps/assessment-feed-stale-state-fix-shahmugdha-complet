import 'package:flutter/foundation.dart';

import '../models/assessment.dart';
import '../repositories/assessment_repository.dart';

class AssessmentFeedNotifier extends ChangeNotifier {
  AssessmentFeedNotifier({required this.repository}) {
    loadForDomain(AssessmentDomain.all);
  }

  final FakeAssessmentRepository repository;

  AssessmentDomain selectedDomain = AssessmentDomain.all;
  List<Assessment> results = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadForDomain(AssessmentDomain domain) async {
    selectedDomain = domain;

    // BUG (Problem 3): Clears results immediately, causing the list to go blank on every load.
    results = [];
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    // BUG (Problem 1): No guard against stale responses.
    // If loadForDomain is called again before this await resolves,
    // the slower earlier response will overwrite the newer one.
    try {
      final data = await repository.loadForDomain(domain);
      results = data;
    } catch (e) {
      errorMessage = 'Failed to load assessments. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
