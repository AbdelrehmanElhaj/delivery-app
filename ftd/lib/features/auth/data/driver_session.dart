import 'package:equatable/equatable.dart';

class DriverSession extends Equatable {
  final int userId;
  final int partnerId;
  final String name;
  final String login;
  final String sessionId;
  final String? traccarDeviceId;

  const DriverSession({
    required this.userId,
    required this.partnerId,
    required this.name,
    required this.login,
    required this.sessionId,
    this.traccarDeviceId,
  });

  factory DriverSession.fromOdooResult(Map<String, dynamic> result) {
    return DriverSession(
      userId: result['uid'] as int,
      partnerId: result['partner_id'] as int,
      name: result['name'] as String,
      login: result['username'] as String,
      sessionId: result['session_id'] as String? ?? '',
    );
  }

  DriverSession copyWith({String? traccarDeviceId, String? sessionId}) {
    return DriverSession(
      userId: userId,
      partnerId: partnerId,
      name: name,
      login: login,
      sessionId: sessionId ?? this.sessionId,
      traccarDeviceId: traccarDeviceId ?? this.traccarDeviceId,
    );
  }

  // Fallback Traccar device ID — overridden by delivery.driver record ID after login
  String get defaultDeviceId => 'driver-${userId.toString().padLeft(3, '0')}';

  @override
  List<Object?> get props =>
      [userId, partnerId, name, login, sessionId, traccarDeviceId];
}
