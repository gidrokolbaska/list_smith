part of '../refresh.dart';

/// Pull-to-refresh off: no gesture, no indicator. Pass it to `.async`'s `refresh` to opt out.
final class NoRefresh extends Refresh {
  /// Creates it.
  const NoRefresh();

  @internal
  @override
  ScrollPhysics? scrollPhysics(ScrollPhysics? physics) => physics;

  @override
  String toString() => 'NoRefresh()';
}
