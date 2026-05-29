import '../api/fake_api_client.dart';
import '../models/assessment.dart';

class CacheEntry {
  CacheEntry({required this.assessments, required this.fetchedAt});

  final List<Assessment> assessments;
  final DateTime fetchedAt;

  static const int ttlSeconds = 30;

  bool get isValid =>
      DateTime.now().difference(fetchedAt).inSeconds < ttlSeconds;
}

class FakeAssessmentRepository {
  FakeAssessmentRepository({required this.apiClient});

  final FakeApiClient apiClient;

  // In-memory cache keyed by domain name.
  final Map<String, CacheEntry> _cache = {};

  /// Loads assessments for [domain].
  /// BUG: currently never checks the cache — always calls the API client.
  Future<List<Assessment>> loadForDomain(AssessmentDomain domain) async {
    // TODO (Problem 2): Check _cache[domain.label] before calling the API.
    // If a valid (non-expired) CacheEntry exists, return its assessments immediately.
    // After a successful API call, store the result in _cache[domain.label].

    final results = await apiClient.fetchAssessments(domain);
    return results;
  }
}
