part of '../edit_transition.dart';

/// No edit transitions: an edit shows at once. The default.
final class NoEditTransition extends EditTransition {
  /// Creates it.
  const NoEditTransition() : super._();

  @override
  String toString() => 'NoEditTransition()';
}
