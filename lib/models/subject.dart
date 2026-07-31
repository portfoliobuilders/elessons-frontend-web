import 'package:flutter/widgets.dart';

/// A CBSE subject offered on the platform.
@immutable
class Subject {
  const Subject({
    required this.code,
    required this.name,
    required this.modules,
    required this.lessons,
    required this.priceFrom,
  });

  final String code; // e.g. "SST", "ENG", "SCI"
  final String name;
  final int modules;
  final int lessons;
  final int priceFrom; // INR
}
