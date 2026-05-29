// Do not modify this file.

enum AssessmentDomain {
  all,
  flutter,
  aiMl,
  devOps,
  fullstack,
  distributedSystems,
}

extension AssessmentDomainLabel on AssessmentDomain {
  String get label => switch (this) {
        AssessmentDomain.all => 'All',
        AssessmentDomain.flutter => 'Flutter',
        AssessmentDomain.aiMl => 'AI / ML',
        AssessmentDomain.devOps => 'DevOps',
        AssessmentDomain.fullstack => 'Fullstack',
        AssessmentDomain.distributedSystems => 'Distributed Systems',
      };
}

enum AssessmentStatus { upcoming, inProgress, completed }

class Assessment {
  const Assessment({
    required this.id,
    required this.title,
    required this.domain,
    required this.status,
    required this.durationMinutes,
  });

  final String id;
  final String title;
  final AssessmentDomain domain;
  final AssessmentStatus status;
  final int durationMinutes;
}
