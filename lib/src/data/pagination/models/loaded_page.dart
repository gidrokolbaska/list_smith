import 'package:meta/meta.dart';

/// One loaded page: the items the server sent, and the edit counter when its fetch went out, so an
/// edit can tell pages read before it from pages read after.
///
/// A class rather than a record, since a record costs the de-dup pass about half again.
@immutable
final class LoadedPage<T extends Object> {
  /// The items, as the server sent them.
  final List<T> items;

  /// The edit counter when this page's fetch went out.
  final int readStamp;

  /// Creates it.
  const LoadedPage({required this.items, required this.readStamp});
}
