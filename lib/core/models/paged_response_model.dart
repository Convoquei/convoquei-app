
class PagedResponseModel<T> {
  final List<T> items;
  final int page;
  final int size;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PagedResponseModel({
    required this.items,
    required this.page,
    required this.size,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PagedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResponseModel<T>(
      items: (json['items'] as List).map((item) => fromJsonT(item)).toList(),
      page: json['page'],
      size: json['size'],
      totalItems: json['totalItems'],
      totalPages: json['totalPages'],
      hasNextPage: json['hasNextPage'],
      hasPreviousPage: json['hasPreviousPage'],
    );
  }

  PagedResponseModel<T> copyWith({
    List<T>? items,
    int? page,
    int? size,
    int? totalItems,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
  }) {
    return PagedResponseModel<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      size: size ?? this.size,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
    );
  }
}
