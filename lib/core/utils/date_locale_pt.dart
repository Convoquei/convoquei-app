/// Constantes de localização de datas em português brasileiro.
abstract final class DateLocalePt {
  static const List<String> monthNames = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  static const List<String> weekdayNames = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];
}

DateTime parseInstant(String value) {
  return DateTime.parse(value).toLocal();
}

String toApiInstant(DateTime date) {
  return date.toUtc().toIso8601String();
}

DateTime startOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime endOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}