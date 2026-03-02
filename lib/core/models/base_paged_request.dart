abstract class BasePagedRequest {
  final int page;
  final int size;

  BasePagedRequest({
    required this.page,
    required this.size,
  });

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'size': size,
    };
  }
}