import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/app_constants.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
TokenStorage tokenStorage(Ref ref) => TokenStorage();

@Riverpod(keepAlive: true)
ApiClient apiClient(Ref ref) => ApiClient(
      tokenStorage: ref.watch(tokenStorageProvider),
      ref: ref,
      baseUrl: AppConstants.baseUrl,
    );

@Riverpod(keepAlive: true)
GlobalKey<NavigatorState> navigatorKey(Ref ref) => GlobalKey<NavigatorState>();
