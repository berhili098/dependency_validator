import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

/// A validator that extracts package imports from Dart source files.
/// This class provides utilities to analyze import and export directives
/// in Dart files and extract the package names being referenced.
class ImportExportValidator {
  /// Analyzes a Dart file and returns a set of package names that are
  /// imported or exported in that file.
  /// 
  /// [file] The Dart source file to analyze
  /// 
  /// Returns a Set of package names found in import/export directives
  /// 
  /// Throws ArgumentError if the file cannot be parsed
  static Set<String> getPackageImports(File file) {
    try {
      // Parse the file content into an AST (Abstract Syntax Tree)
      final parsed = parseString(content: file.readAsStringSync(), path: file.path);
      // Create a visitor to traverse the AST
      final visitor = _ImportExportVisitor();
      // Visit all nodes in the AST
      parsed.unit.visitChildren(visitor);
      return visitor.packageNames;
    } on ArgumentError catch (e) {
      print('Error parsing: ${file.path}');
      print(e.message);
      exit(1);
    }
  }
}

/// An AST visitor that collects package names from import and export directives.
/// This visitor implements the logic to extract package names from URI-based
/// directives in the Dart source code.
class _ImportExportVisitor extends GeneralizingAstVisitor {
  /// Set of package names found during AST traversal
  final Set<String> packageNames = {};

  @override
  void visitDirective(Directive node) {
    // Only process URI-based directives (imports and exports)
    if (node is! UriBasedDirective) return;
    
    // Get the URI string from the directive
    final uri = node.uri.stringValue;
    // Skip if URI is null or not a package import
    if (uri == null || !uri.startsWith('package:')) return;

    // Extract the package name from the URI
    // Example: package:foo/bar.dart -> ['foo', 'bar.dart'] -> 'foo'
    final packageParts = uri.substring('package:'.length).split('/');
    if (packageParts.isNotEmpty) {
      packageNames.add(packageParts.first);
    }
  }
}