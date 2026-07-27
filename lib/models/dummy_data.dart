class DummySubject {
  final String id;
  final String title;
  final String description;
  final String teacherName;
  final String teacherImage;
  final int modulesCount;
  final int lessonsCount;
  final String duration;
  final double price;
  final double progress;
  final String imagePath;

  const DummySubject({
    required this.id,
    required this.title,
    required this.description,
    required this.teacherName,
    required this.teacherImage,
    required this.modulesCount,
    required this.lessonsCount,
    required this.duration,
    required this.price,
    required this.progress,
    required this.imagePath,
  });
}

class DummyModule {
  final String id;
  final String title;
  final int totalLessons;
  final double progress;
  final bool isLocked;

  const DummyModule({
    required this.id,
    required this.title,
    required this.totalLessons,
    required this.progress,
    required this.isLocked,
  });
}

class DummyLesson {
  final String id;
  final String title;
  final String duration;
  final bool isCompleted;
  final bool isLocked;
  final bool hasNotes;

  const DummyLesson({
    required this.id,
    required this.title,
    required this.duration,
    required this.isCompleted,
    required this.isLocked,
    required this.hasNotes,
  });
}

class DummyData {
  static const DummySubject englishSubject = DummySubject(
    id: 's_english',
    title: 'English Literature',
    description: 'Master English literature with comprehensive modules covering classic texts, grammar, and creative writing skills.',
    teacherName: 'Sarah Jenkins',
    teacherImage: 'SJ',
    modulesCount: 12,
    lessonsCount: 48,
    duration: '24h 30m',
    price: 1499.0,
    progress: 0.35,
    imagePath: 'EN',
  );

  static const List<DummyModule> englishModules = [
    DummyModule(
      id: 'm1',
      title: 'Introduction to Classic Literature',
      totalLessons: 5,
      progress: 1.0,
      isLocked: false,
    ),
    DummyModule(
      id: 'm2',
      title: 'Advanced Grammar Concepts',
      totalLessons: 8,
      progress: 0.5,
      isLocked: false,
    ),
    DummyModule(
      id: 'm3',
      title: 'Creative Writing Workshop',
      totalLessons: 6,
      progress: 0.0,
      isLocked: false,
    ),
    DummyModule(
      id: 'm4',
      title: 'Poetry Analysis',
      totalLessons: 7,
      progress: 0.0,
      isLocked: true,
    ),
    DummyModule(
      id: 'm5',
      title: 'Shakespearean Plays',
      totalLessons: 10,
      progress: 0.0,
      isLocked: true,
    ),
  ];

  static const List<DummyLesson> literatureLessons = [
    DummyLesson(
      id: 'l1',
      title: 'The Origins of English Literature',
      duration: '45m',
      isCompleted: true,
      isLocked: false,
      hasNotes: true,
    ),
    DummyLesson(
      id: 'l2',
      title: 'Understanding Beowulf',
      duration: '52m',
      isCompleted: true,
      isLocked: false,
      hasNotes: true,
    ),
    DummyLesson(
      id: 'l3',
      title: 'Chaucer and The Canterbury Tales',
      duration: '60m',
      isCompleted: false,
      isLocked: false,
      hasNotes: true,
    ),
    DummyLesson(
      id: 'l4',
      title: 'The Renaissance Period',
      duration: '55m',
      isCompleted: false,
      isLocked: true,
      hasNotes: false,
    ),
    DummyLesson(
      id: 'l5',
      title: 'Elizabethan Theatre',
      duration: '48m',
      isCompleted: false,
      isLocked: true,
      hasNotes: false,
    ),
  ];
}
