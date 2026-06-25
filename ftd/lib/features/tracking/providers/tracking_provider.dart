import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/location/location_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../shared/utils/constants.dart';
import '../../auth/providers/auth_provider.dart';

final trackingProvider =
    StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier(
    ref.watch(locationServiceProvider),
    ref.watch(secureStorageProvider),
    ref,
  );
});

class TrackingState {
  final bool isTracking;
  final bool hasPermission;
  final String? lastError;
  final DateTime? lastPing;
  final int pendingCount;

  const TrackingState({
    this.isTracking = false,
    this.hasPermission = false,
    this.lastError,
    this.lastPing,
    this.pendingCount = 0,
  });

  TrackingState copyWith({
    bool? isTracking,
    bool? hasPermission,
    String? lastError,
    DateTime? lastPing,
    int? pendingCount,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      hasPermission: hasPermission ?? this.hasPermission,
      lastError: lastError,
      lastPing: lastPing ?? this.lastPing,
      pendingCount: pendingCount ?? this.pendingCount,
    );
  }
}

class TrackingNotifier extends StateNotifier<TrackingState> {
  final LocationService _locationService;
  final SecureStorageService _storage;
  final Ref _ref;

  TrackingNotifier(this._locationService, this._storage, this._ref)
      : super(const TrackingState()) {
    _init();
  }

  Future<void> _init() async {
    final hasPermission = await _locationService.hasPermissions;
    final wasTracking =
        await _storage.read(AppConstants.keyIsTracking) == 'true';

    state = state.copyWith(hasPermission: hasPermission);

    if (hasPermission && wasTracking) {
      await startTracking();
    }
  }

  Future<void> requestPermissions() async {
    final granted = await _locationService.requestPermissions();
    state = state.copyWith(hasPermission: granted);
  }

  Future<void> startTracking() async {
    final session = _ref.read(authProvider.notifier).currentSession;
    if (session == null) return;

    final deviceId = session.traccarDeviceId ?? session.defaultDeviceId;

    await _locationService.startForegroundTracking(deviceId,
        onResult: (success, pending) {
      if (mounted) {
        state = state.copyWith(
          lastPing: success ? DateTime.now() : state.lastPing,
          pendingCount: pending,
        );
      }
    });
    await _storage.write(AppConstants.keyIsTracking, 'true');

    state = state.copyWith(
      isTracking: true,
      lastError: null,
      lastPing: DateTime.now(),
    );
  }

  void stopTracking() {
    _locationService.stopForegroundTracking();
    _storage.write(AppConstants.keyIsTracking, 'false');
    state = state.copyWith(isTracking: false);
  }

  void toggleTracking() {
    if (state.isTracking) {
      stopTracking();
    } else {
      startTracking();
    }
  }
}
