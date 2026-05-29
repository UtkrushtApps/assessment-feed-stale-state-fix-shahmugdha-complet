import 'package:flutter_test/flutter_test.dart';

import 'package:assessment_feed/api/fake_api_client.dart';
import 'package:assessment_feed/models/assessment.dart';
import 'package:assessment_feed/repositories/assessment_repository.dart';
import 'package:assessment_feed/state/assessment_feed_notifier.dart';

// ---------------------------------------------------------------------------
// Minimal fake repository used only in tests — no real async delay.
// ---------------------------------------------------------------------------

class _FakeRepository extends FakeAssessmentRepository {
  _FakeRepository(this._responses)
      : super(apiClient: FakeApiClient());

  final Map<AssessmentDomain, List<Assessment>> _responses;
  int callCount = 0;

  @override
  Future<List<Assessment>> loadForDomain(AssessmentDomain domain) async {
    callCount++;
    return _responses[domain] ?? [];
  }
}

const _flutterAssessments = [
  Assessment(
    id: 'f1',
    title: 'Flutter Test',
    domain: AssessmentDomain.flutter,
    status: AssessmentStatus.upcoming,
    durationMinutes: 60,
  ),
];

const _aiAssessments = [
  Assessment(
    id: 'a1',
    title: 'AI Test',
    domain: AssessmentDomain.aiMl,
    status: AssessmentStatus.completed,
    durationMinutes: 45,
  ),
];

void main() {
  group('AssessmentFeedNotifier', () {
    test('initial load populates results for AssessmentDomain.all', () async {
      final repo = _FakeRepository({
        AssessmentDomain.all: [..._flutterAssessments, ..._aiAssessments],
      });
      final notifier = AssessmentFeedNotifier(repository: repo);
      // Allow the initial loadForDomain(all) triggered in the constructor to settle.
      await Future.microtask(() {});
      expect(notifier.results.length, 2);
      expect(notifier.isLoading, isFalse);
      expect(notifier.errorMessage, isNull);
    });

    test('switching domain updates selectedDomain and results', () async {
      final repo = _FakeRepository({
        AssessmentDomain.all: [],
        AssessmentDomain.flutter: _flutterAssessments,
      });
      final notifier = AssessmentFeedNotifier(repository: repo);
      await Future.microtask(() {});

      await notifier.loadForDomain(AssessmentDomain.flutter);

      expect(notifier.selectedDomain, AssessmentDomain.flutter);
      expect(notifier.results, _flutterAssessments);
    });

    test('previous results remain visible while a new load is in progress', () async {
      // After fix: results should NOT be cleared to [] when loading starts.
      var loadCompleter = false;
      final repo = _DelayableRepository(onLoad: (_) async {
        while (!loadCompleter) {
          await Future.delayed(const Duration(milliseconds: 10));
        }
        return _aiAssessments;
      }, initialData: _flutterAssessments);

      final notifier = AssessmentFeedNotifier(repository: repo);
      await Future.microtask(() {});
      // Initial load has settled with flutter assessments.
      expect(notifier.results, _flutterAssessments);

      // Start a new load that won't complete yet.
      final future = notifier.loadForDomain(AssessmentDomain.aiMl);
      await Future.microtask(() {});

      // While loading, the previous results should still be present.
      expect(
        notifier.results,
        _flutterAssessments,
        reason: 'Previous results should remain visible during a new load',
      );
      expect(notifier.isLoading, isTrue);

      // Now let the load complete.
      loadCompleter = true;
      await future;

      expect(notifier.results, _aiAssessments);
      expect(notifier.isLoading, isFalse);
    });

    test('only the last requested domain result is applied when calls overlap',
        () async {
      // Simulate: flutter request takes 200ms, aiMl request takes 50ms.
      // aiMl is requested second and should resolve first.
      // After fix: final state must reflect aiMl results, not flutter.
      final repo = _LatencyRepository({
        AssessmentDomain.all: (data: const [], delayMs: 0),
        AssessmentDomain.flutter:
            (data: _flutterAssessments, delayMs: 200),
        AssessmentDomain.aiMl: (data: _aiAssessments, delayMs: 50),
      });

      final notifier = AssessmentFeedNotifier(repository: repo);
      await Future.microtask(() {}); // settle initial

      // Fire both — do not await the first.
      unawaited(notifier.loadForDomain(AssessmentDomain.flutter));
      await Future.delayed(const Duration(milliseconds: 10));
      await notifier.loadForDomain(AssessmentDomain.aiMl);

      expect(
        notifier.results,
        _aiAssessments,
        reason:
            'The last-requested domain result must win, even if an earlier '
            'request resolves after it.',
      );
    });
  });

  group('FakeAssessmentRepository cache', () {
    test('second call within TTL does not hit the API client', () async {
      final client = _CountingApiClient();
      final repo = FakeAssessmentRepository(apiClient: client);

      await repo.loadForDomain(AssessmentDomain.flutter);
      await repo.loadForDomain(AssessmentDomain.flutter);

      expect(
        client.callCount,
        1,
        reason: 'Second call within TTL should use cache, not the API client',
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Helpers used only in tests
// ---------------------------------------------------------------------------

void unawaited(Future<void> future) {
  // Intentionally not awaited — used to trigger concurrent requests.
  future.ignore();
}

typedef _LoadCallback = Future<List<Assessment>> Function(
    AssessmentDomain domain);

class _DelayableRepository extends FakeAssessmentRepository {
  _DelayableRepository({
    required _LoadCallback onLoad,
    required List<Assessment> initialData,
  })  : _onLoad = onLoad,
        _initialData = initialData,
        super(apiClient: FakeApiClient());

  final _LoadCallback _onLoad;
  final List<Assessment> _initialData;
  bool _firstCall = true;

  @override
  Future<List<Assessment>> loadForDomain(AssessmentDomain domain) async {
    if (_firstCall) {
      _firstCall = false;
      return _initialData;
    }
    return _onLoad(domain);
  }
}

class _LatencyRepository extends FakeAssessmentRepository {
  _LatencyRepository(this._config) : super(apiClient: FakeApiClient());

  final Map<
      AssessmentDomain,
      ({
        List<Assessment> data,
        int delayMs,
      })> _config;

  @override
  Future<List<Assessment>> loadForDomain(AssessmentDomain domain) async {
    final entry = _config[domain];
    if (entry == null) return [];
    await Future.delayed(Duration(milliseconds: entry.delayMs));
    return entry.data;
  }
}

class _CountingApiClient extends FakeApiClient {
  int callCount = 0;

  @override
  Future<List<Assessment>> fetchAssessments(AssessmentDomain domain) async {
    callCount++;
    return [];
  }
}
