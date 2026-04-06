import 'package:convoquei_app/features/organizations/events/models/organization_event_details_model.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// Esquema de deep link do app.
const _kDeepLinkScheme = 'convoquei://app';

abstract final class EventShareService {
  static Future<void> share({
    required String organizationId,
    required String eventId,
    required OrganizationEventDetailsModel details,
  }) async {
    final message = _buildMessage(
      organizationId: organizationId,
      eventId: eventId,
      details: details,
    );

    await Share.share(message);
  }

  static String _buildMessage({
    required String organizationId,
    required String eventId,
    required OrganizationEventDetailsModel details,
  }) {
    final dateFormat = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    final timeFormat = DateFormat('HH:mm', 'pt_BR');

    final startDate = dateFormat.format(details.startAt);
    final startTime = timeFormat.format(details.startAt);
    final endTime = timeFormat.format(details.endAt);

    final deepLink = '$_kDeepLinkScheme/orgs/$organizationId/events/$eventId';

    final buffer = StringBuffer();
    buffer.writeln('📣 *${details.name}*');
    buffer.writeln();
    buffer.writeln('📅 ${_capitalize(startDate)}');
    buffer.writeln('🕐 $startTime – $endTime');
    buffer.writeln('📍 ${details.location}');

    if (details.description.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(details.description);
    }

    buffer.writeln();
    buffer.writeln('Abra no Convoquei 👇');
    buffer.write(deepLink);

    return buffer.toString();
  }

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
