# Assessment Feed — Stale State Fix

## Task Overview

You have been handed a partially broken **Browse Assessments** screen from a skills marketplace mobile app. The screen is runnable and works in the happy path, but has four concrete bugs that need to be fixed before the next production release.

The bugs relate to:
- stale async responses overwriting correct state,
- an in-memory TTL cache that exists but is never consulted,
- previous results being discarded during a reload,
- a filter chip widget causing unnecessarily broad rebuilds.

Your job is to fix all four problems in the existing code. You should not build anything from scratch — everything you need is already present in skeleton or partial form.

---

## Objectives

1. **Stale response guard** — Rapidly tapping different domain chips must always display results for the last tapped chip, never for a slower earlier request.
2. **Cache usage** — Re-selecting a recently loaded domain within 30 seconds must not fire a new API call.
3. **Non-destructive loading** — The current list must remain visible while a new domain is being fetched; the list must not go blank during a load.
4. **Widget extraction** — `FilterChipRow` must be a standalone `StatelessWidget` in `lib/widgets/filter_chip_row.dart` receiving only what it needs as constructor parameters.

---

## How to Verify

```bash
# Run the app
flutter run

# Run tests
flutter test

# Check for lint/analysis issues
flutter analyze
```

**Manual checks:**
- Tap domain chips quickly in sequence. After settling, the displayed list must match the last chip you tapped.
- Tap the same chip twice within 30 seconds. The debug console must print the API fetch log only once (the second tap hits the cache).
- While a domain is loading, the previous results should still be visible below any loading indicator.

---

## Helpful Tips

- The `FakeApiClient` already prints a debug line when a real fetch fires. Use this to verify cache behaviour without adding instrumentation.
- For the stale response problem, think about what information you have at the moment you *start* a request versus the moment the response *arrives*. A simple counter or a stored "current domain" comparison are both valid approaches.
- The cache logic lives entirely inside `FakeAssessmentRepository`. You only need to add the read-before-fetch and write-after-fetch calls around the existing API call.
- Keeping previous results visible does not require a second list or complex state. Consider what `isLoading` currently does to the UI and whether it needs to.
- `FilterChipRow` does not need access to the notifier directly — the parent can pass in the selected domain and an `onSelected` callback.