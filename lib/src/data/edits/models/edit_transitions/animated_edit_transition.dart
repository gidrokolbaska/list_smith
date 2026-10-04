part of '../edit_transition.dart';

/// Edit transitions on. Built through [EditTransition.new].
final class AnimatedEditTransition extends EditTransition {
  ///fdfd
  final Duration duration;

  /// Wraps a row while it animates.
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  /// Creates it.
  const AnimatedEditTransition._({
    /// How long a row takes to come in or go out.
    required this.duration,

    /// Wraps a row while it animates.
    required this.transitionBuilder,
  }) : super._();

  @override
  String toString() => 'EditTransition(duration: $duration)';
}
