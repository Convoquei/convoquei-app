class StateListPaged<T> {
  const StateListPaged({
    this.items = const [],
    this.page = 0,
    this.hasNextPage = true,
    this.isInitialLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<T> items;
  final int page;
  final bool hasNextPage;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final Object? error;

  StateListPaged<T> copyWith({
    List<T>? items,
    int? page,
    bool? hasNextPage,
    bool? isInitialLoading,
    bool? isLoadingMore,
    Object? error,
  }) {
    return StateListPaged<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }

  StateListPaged<T> reset() => StateListPaged<T>();
}