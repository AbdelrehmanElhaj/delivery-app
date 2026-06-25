import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/utils/constants.dart';
import '../database/app_database.dart';
import '../traccar/ping_queue.dart';
import '../traccar/traccar_sender.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  final queue = ref.watch(pingQueueProvider);
  return LocationService(queue);
});

class LocationService {
  final PingQueue _queue;
  StreamSubscription<Position>? _positionSub;
  bool _isTracking = false;

  LocationService(this._queue);

  bool get isTracking => _isTracking;

  // ─── Permissions ──────────────────────────────────────────────────────────

  Future<bool> requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return false;

    if (kIsWeb) return true;

    // Android 10+: background location
    final bgStatus = await Permission.locationAlways.request();
    if (!bgStatus.isGranted) return false;

    // Android 13+: notification
    await Permission.notification.request();

    return true;
  }

  Future<bool> get hasPermissions async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return false;
    if (kIsWeb) return true;
    return await Permission.locationAlways.isGranted;
  }

  // ─── Foreground tracking ──────────────────────────────────────────────────

  Future<void> startForegroundTracking(String deviceId,
      {void Function(bool success, int pending)? onResult}) async {
    if (_isTracking) return;

    final locationSettings = kIsWeb
        ? const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          )
        : AndroidSettings(
            accuracy: LocationAccuracy.high,
            intervalDuration:
                const Duration(seconds: AppConstants.trackingIntervalSeconds),
            distanceFilter: 10,
            foregroundNotificationConfig: const ForegroundNotificationConfig(
              notificationChannelName: 'Food Truck Driver Tracking',
              notificationTitle: 'Food Truck Driver',
              notificationText: 'Location tracking is active',
              enableWakeLock: true,
              enableWifiLock: true,
            ),
          );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) async {
      final pending = await _queue.send(
        position: position,
        deviceId: deviceId,
      );
      final success = pending == 0;
      onResult?.call(success, pending);
      print('[Location] Sent: ${position.latitude},${position.longitude} '
          '— ${success ? "OK" : "QUEUED ($pending pending)"}');
    });

    _isTracking = true;
  }

  void stopForegroundTracking() {
    _positionSub?.cancel();
    _positionSub = null;
    _isTracking = false;
  }

  // ─── Get current position once ────────────────────────────────────────────

  Future<Position> getCurrentPosition() {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }
}

// ─── Background Service (survives app kill) ───────────────────────────────────

Future<void> initBackgroundService() async {
  if (kIsWeb) return;

  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onBackgroundServiceStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'ftd_tracking',
      initialNotificationTitle: 'Food Truck Driver',
      initialNotificationContent: 'Tracking active',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onBackgroundServiceStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onBackgroundServiceStart(ServiceInstance service) async {
  // Retrieve deviceId passed when starting the service
  String? deviceId;

  service.on('setDeviceId').listen((data) {
    deviceId = data?['deviceId'] as String?;
  });

  service.on('stop').listen((_) {
    service.stopSelf();
  });

  final sender = TraccarSender();
  final db = AppDatabase();
  final queue = PingQueue(sender, db);

  Timer.periodic(
    const Duration(seconds: AppConstants.trackingIntervalSeconds),
    (_) async {
      if (deviceId == null) return;
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        final pending = await queue.send(
          position: position,
          deviceId: deviceId!,
        );

        service.invoke('position', {
          'lat': position.latitude,
          'lon': position.longitude,
          'timestamp': DateTime.now().toIso8601String(),
          'pending': pending,
        });
      } catch (e) {
        print('[BG] Error: $e');
      }
    },
  );
}
