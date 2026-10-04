import 'package:flutter/widgets.dart';

import '/src/data/grouping/models/grouping.dart';
import '/src/data/pagination/models/paging_state.dart';
import '/src/data/pagination/typedefs/item_id_getter.dart';
import '/src/data/presentation/models/list_scroll_config.dart';
import '/src/data/presentation/typedefs/error_builder.dart';
import '/src/data/presentation/typedefs/item_builder.dart';
import '/src/data/presentation/typedefs/no_results_builder.dart';
import '/src/data/refresh/models/refresh.dart';
import 'defaults/neutral_empty_indicator.dart';
import 'defaults/neutral_error_indicator.dart';
import 'defaults/neutral_loading_indicator.dart';
import 'defaults/neutral_no_more_items_indicator.dart';
import 'defaults/neutral_no_results_indicator.dart';
import 'keyed_paged_list_view.dart';

/// The async list, with every surface filled by our neutral default or the consumer's override.
class PagedView<T extends Object> extends StatelessWidget {
  /// Drives which surface renders.
  final PagingState<T> state;

  /// Asks for the next page, from a row near the end.
  final VoidCallback onNearEnd;

  /// Asks again for the page that failed, from an error surface's retry.
  final VoidCallback onRetry;

  /// Builds each item.
  final ItemBuilder<T> itemBuilder;

  /// Keys each row by its item.
  final ItemIdGetter<T> itemIdGetter;

  /// Splits the visible items into sections. [NoGrouping] (the default) renders a flat list.
  final Grouping<T> grouping;

  /// Scroll and layout configuration.
  final ListScrollConfig scroll;

  /// Whether the list takes a pull, which decides the physics it scrolls with.
  final Refresh refresh;

  /// Whether the current results are a search: picks the no-results surface over the empty one.
  final bool isSearchMode;

  /// The committed query, handed to [noResultsBuilder] when [isSearchMode] and nothing matched.
  final String query;

  /// Builds separators between items. Null for none.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Overrides for the neutral default surfaces. Null keeps the default.
  final WidgetBuilder? firstPageLoadingBuilder;

  /// See [firstPageLoadingBuilder].
  final WidgetBuilder? newPageLoadingBuilder;

  /// See [firstPageLoadingBuilder].
  final ErrorBuilder? firstPageErrorBuilder;

  /// See [firstPageLoadingBuilder].
  final ErrorBuilder? newPageErrorBuilder;

  /// See [firstPageLoadingBuilder]. Shown when the source has no items in normal mode.
  final WidgetBuilder? emptyBuilder;

  /// See [firstPageLoadingBuilder]. Shown when a search yields nothing in search mode.
  final NoResultsBuilder? noResultsBuilder;

  /// See [firstPageLoadingBuilder].
  final WidgetBuilder? noMoreItemsBuilder;

  /// Creates it.
  const PagedView({
    required this.state,

    required this.onNearEnd,

    required this.onRetry,

    required this.itemBuilder,

    required this.itemIdGetter,

    required this.grouping,

    required this.scroll,

    required this.refresh,

    required this.isSearchMode,

    required this.query,

    this.separatorBuilder,

    this.firstPageLoadingBuilder,

    this.newPageLoadingBuilder,

    this.firstPageErrorBuilder,

    this.newPageErrorBuilder,

    this.emptyBuilder,

    this.noResultsBuilder,

    this.noMoreItemsBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) => KeyedPagedListView(
    state: state,
    itemBuilder: _effectiveItemBuilder(),
    itemIdGetter: itemIdGetter,
    surfaces: _surfaces(),
    onNearEnd: onNearEnd,
    separatorBuilder: separatorBuilder,
    controller: scroll.controller,
    scrollDirection: scroll.scrollDirection,
    reverse: scroll.reverse,
    physics: refresh.scrollPhysics(scroll.physics),
    padding: scroll.padding,
    scrollCacheExtent: scroll.cacheExtent,
  );

  /// The item builder the rows use. The group look-back only walks the pages when grouping is on, since
  /// [Grouping.decorate] takes it as a callback.
  ItemBuilder<T> _effectiveItemBuilder() => grouping.decorate(
    itemBuilder,
    flattenItems: () => state.pages?.expand((page) => page.items) ?? const Iterable.empty(),
    axis: scroll.scrollDirection,
  );

  /// Every surface. The error ones read `state.error!`, non-null because only an error status builds
  /// them.
  PagedSurfaces _surfaces() => (
    firstPageLoading: (context) =>
        firstPageLoadingBuilder?.call(context) ?? const NeutralLoadingIndicator(),
    firstPageError: (_) =>
        _ResolvedError(error: state.error!, onRetry: onRetry, builder: firstPageErrorBuilder),
    noItemsFound: (context) => isSearchMode
        ? (noResultsBuilder?.call(context, query) ?? const NeutralNoResultsIndicator())
        : (emptyBuilder?.call(context) ?? const NeutralEmptyIndicator()),
    newPageLoading: (context) =>
        newPageLoadingBuilder?.call(context) ?? const NeutralLoadingIndicator(isCompact: true),
    newPageError: (_) => _ResolvedError(
      error: state.error!,
      onRetry: onRetry,
      builder: newPageErrorBuilder,
      isCompact: true,
    ),
    noMoreItems: (context) =>
        noMoreItemsBuilder?.call(context) ?? const NeutralNoMoreItemsIndicator(),
  );
}

/// The consumer's [ErrorBuilder] if there is one, else the neutral default.
class _ResolvedError extends StatelessWidget {
  final Exception error;
  final VoidCallback onRetry;
  final ErrorBuilder? builder;
  final bool isCompact;
  const _ResolvedError({
    required this.error,
    required this.onRetry,
    this.builder,
    this.isCompact = false,
  });
  @override
  Widget build(BuildContext context) {
    final errorBuilder = builder;

    return errorBuilder != null
        ? errorBuilder(context, error, onRetry)
        : NeutralErrorIndicator(error: error, onRetry: onRetry, isCompact: isCompact);
  }
}
