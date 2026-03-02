import 'package:flutter/foundation.dart';

import 'network/exceptions/api_exception.dart';

abstract class LoadingController extends ChangeNotifier {
  bool _isLoading = false;
  Object? _error;

  bool get isLoading => _isLoading;
  Object? get error => _error;

  Future<void> run(
    Future<void> Function() action, {
    ValueSetter<bool>? loading,
  }) async {
    _isLoading = true;
    loading?.call(true);
    _error = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      loading?.call(false);
      notifyListeners();
    }
  }

  String buildErrorFetchAPI(Object? err) =>
      err is ApiException ? err.userMessage : "Ocorreu um erro inesperado. Tente novamente mais tarde.";
}
