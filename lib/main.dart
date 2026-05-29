import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/fake_api_client.dart';
import 'repositories/assessment_repository.dart';
import 'screens/assessment_feed_screen.dart';
import 'state/assessment_feed_notifier.dart';

void main() {
  runApp(const AssessmentApp());
}

class AssessmentApp extends StatelessWidget {
  const AssessmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AssessmentFeedNotifier(
        repository: FakeAssessmentRepository(
          apiClient: FakeApiClient(),
        ),
      ),
      child: MaterialApp(
        title: 'Assessment Feed',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          useMaterial3: true,
        ),
        home: const AssessmentFeedScreen(),
      ),
    );
  }
}
