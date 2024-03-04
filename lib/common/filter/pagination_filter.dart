class PaginationFilter {
  late int page = 1;
  final int _limit = 15;
  bool hasNext = true;

  PaginationFilter({
    required int page
  });

  @override
  String toString() => 'PaginationFilter(page: $page, limit: $limit)';

  @override
  bool operator == (Object other) {
    if (identical(this, other)) return true;

    return other is PaginationFilter && other.page == page && other.limit == limit;
  }

  @override
  int get hashCode => page.hashCode ^ limit.hashCode;

  int get limit => _limit;
}