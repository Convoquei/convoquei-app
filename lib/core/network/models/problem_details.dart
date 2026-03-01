class ProblemDetails {
  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String? instance;
  final Map<String, List<String>>? errors;

  const ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
    this.errors,
  });

  factory ProblemDetails.fromJson(Map<String, dynamic> json) {
    return ProblemDetails(
      type: json['type'] as String?,
      title: json['title'] as String?,
      status: json['status'] as int?,
      detail: json['detail'] as String?,
      instance: json['instance'] as String?,
      errors: json['errors'] != null
          ? (json['errors'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, List<String>.from(value as List)),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (type != null) 'type': type,
        if (title != null) 'title': title,
        if (status != null) 'status': status,
        if (detail != null) 'detail': detail,
        if (instance != null) 'instance': instance,
        if (errors != null) 'errors': errors,
      };

  /// Returns the first validation error message found, or [detail], or [title].
  String? get firstError {
    if (errors != null && errors!.isNotEmpty) {
      return errors!.values.first.firstOrNull;
    }
    return detail ?? title;
  }

  /// All validation error messages flattened into a single list.
  List<String> get allErrors =>
      errors?.values.expand((msgs) => msgs).toList() ?? [];

  @override
  String toString() =>
      'ProblemDetails(status: $status, title: $title, detail: $detail)';
}