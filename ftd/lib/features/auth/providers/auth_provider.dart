import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/driver_session.dart';
import '../../../core/network/odoo_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/utils/constants.dart';

// ─── Session State ────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final DriverSession session;
  const AuthAuthenticated(this.session);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// ─── Auth Notifier ────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(odooClientProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final OdooClient _odoo;
  final SecureStorageService _storage;

  AuthNotifier(this._odoo, this._storage) : super(const AuthInitial()) {
    _restoreSession();
  }

  // ─── Restore session on app start ─────────────────────────────────────────

  Future<void> _restoreSession() async {
    final sessionId = await _storage.read(AppConstants.keySessionId);
    final userId = await _storage.read(AppConstants.keyUserId);
    final name = await _storage.read(AppConstants.keyDriverName);
    final deviceId = await _storage.read(AppConstants.keyDeviceId);

    if (sessionId != null && sessionId.isNotEmpty && userId != null && name != null) {
      await _odoo.loadSessionCookie(sessionId);
      state = AuthAuthenticated(DriverSession(
        userId: int.parse(userId),
        partnerId: 0,
        name: name,
        login: '',
        sessionId: sessionId,
        traccarDeviceId: deviceId,
      ));
    } else {
      await _storage.deleteAll();
      state = const AuthUnauthenticated();
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  Future<void> login(String login, String password) async {
    state = const AuthLoading();
    try {
      final result = await _odoo.authenticate(login, password);
      var session = DriverSession.fromOdooResult(result);

      // Fetch delivery.driver record to get the Traccar device ID
      final drivers = await _odoo.searchRead(
        model: 'delivery.driver',
        domain: [['user_id', '=', session.userId]],
        fields: ['id', 'name'],
        limit: 1,
      );
      final traccarDeviceId = drivers.isNotEmpty
          ? 'driver-${drivers.first['id'].toString().padLeft(3, '0')}'
          : session.defaultDeviceId;
      session = session.copyWith(traccarDeviceId: traccarDeviceId);

      // Persist session
      await _storage.write(AppConstants.keySessionId, session.sessionId);
      await _storage.write(AppConstants.keyUserId, session.userId.toString());
      await _storage.write(AppConstants.keyDriverName, session.name);
      await _storage.write(AppConstants.keyDeviceId, traccarDeviceId);

      state = AuthAuthenticated(session);
    } catch (e) {
      state = AuthError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _odoo.logout();
    await _storage.deleteAll();
    state = const AuthUnauthenticated();
  }

  DriverSession? get currentSession {
    final s = state;
    return s is AuthAuthenticated ? s.session : null;
  }
}
