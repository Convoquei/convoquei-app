import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(),
);

final apiClientProvider = Provider<ApiClient>(
      (ref) => ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    ref: ref,
    baseUrl: AppConstants.baseUrl,
  ),
);

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>(
      (ref) => GlobalKey<NavigatorState>(),
);
