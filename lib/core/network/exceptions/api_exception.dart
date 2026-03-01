import '../models/problem_details.dart';

/// Base class for all API-layer exceptions.
abstract class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final ProblemDetails? problem;

  const ApiException({
    required this.message,
    this.statusCode,
    this.problem,
  });

  /// Returns the most descriptive message available.
  String get userMessage => problem?.firstError ?? message;

  @override
  String toString() => '$runtimeType(status: $statusCode, message: $message)';
}

/// 400 Bad Request — validation / business rule errors.
class BadRequestException extends ApiException {
  const BadRequestException({
    required super.message,
    super.statusCode = 400,
    super.problem,
  });
}

/// 401 Unauthorized — missing or expired credentials.
class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Sessão expirada. Faça login novamente.',
    super.statusCode = 401,
    super.problem,
  });
}

/// 403 Forbidden — authenticated but lacks permission.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Você não tem permissão para esta ação.',
    super.statusCode = 403,
    super.problem,
  });
}

/// 404 Not Found.
class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Recurso não encontrado.',
    super.statusCode = 404,
    super.problem,
  });
}

/// 409 Conflict.
class ConflictException extends ApiException {
  const ConflictException({
    required super.message,
    super.statusCode = 409,
    super.problem,
  });
}

/// 422 Unprocessable Entity — semantic validation.
class UnprocessableException extends ApiException {
  const UnprocessableException({
    required super.message,
    super.statusCode = 422,
    super.problem,
  });
}

/// 5xx Server errors.
class ServerException extends ApiException {
  const ServerException({
    super.message = 'Erro interno no servidor. Tente novamente mais tarde.',
    super.statusCode,
    super.problem,
  });
}

/// No internet / connection timeout / DNS failure.
class NetworkException extends ApiException {
  const NetworkException({
    super.message = 'Sem conexão com a internet. Verifique sua rede.',
    super.statusCode,
    super.problem,
  });
}

/// Request timed out.
class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'A requisição demorou muito. Tente novamente.',
    super.statusCode,
    super.problem,
  });
}

/// Catch-all for unmapped status codes.
class UnknownApiException extends ApiException {
  const UnknownApiException({
    required super.message,
    super.statusCode,
    super.problem,
  });
}