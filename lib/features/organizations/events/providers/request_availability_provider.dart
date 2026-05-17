import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'request_availability_provider.g.dart';

// TODO: integrar endpoint quando backend disponibilizar.
// Estado não persiste entre reentradas da tela (decisão consciente do stub).
@riverpod
class RequestAvailability extends _$RequestAvailability {
  static const _cooldown = Duration(hours: 6);

  @override
  Map<String, DateTime> build() => {};

  void request(String membershipId) {
    state = {...state, membershipId: DateTime.now()};
  }

  bool hasCooldown(String membershipId) {
    final ts = state[membershipId];
    if (ts == null) return false;
    return DateTime.now().difference(ts) < _cooldown;
  }
}
