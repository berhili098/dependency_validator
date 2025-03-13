import 'dart:io';

import 'package:dependency_validator/src/utils.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:logging/logging.dart';

/// Validates dependencies in a pubspec.yaml file for version pins.
/// A pin is any dependency version constraint that prevents automatic updates
/// of patch or minor versions.
class PinValidator {
  /// List of package names to ignore during pin validation.
  /// These packages won't trigger warnings even if they have pinned versions.
  final List<String> ignoredPackages;
  
  /// Creates a new pin validator with optional ignored packages.
  /// 
  /// [ignoredPackages] - List of package names to exclude from pin validation
  PinValidator({this.ignoredPackages = const []});

  /// Validates the dependencies in a pubspec file for version pins.
  /// 
  /// [pubspec] - The parsed pubspec.yaml file to validate
  /// 
  /// Sets exitCode to 1 if any non-ignored dependencies are found to be pinned.
  /// Logs warnings for any pinned dependencies that are found.
  void validate(Pubspec pubspec) {
    final infractions = [
      ...getDependenciesWithPins(pubspec.dependencies, ignoredPackages: ignoredPackages),
      ...getDependenciesWithPins(pubspec.devDependencies, ignoredPackages: ignoredPackages)
    ];

    if (infractions.isNotEmpty) {
      log(Level.WARNING, 'These packages are pinned in pubspec.yaml:', infractions);
      exitCode = 1;  // Indicates validation failure
    }
  }
}