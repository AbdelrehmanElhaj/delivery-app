import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../database/app_database.dart';
import 'traccar_sender.dart';

final pingQueueProvider = Provider<PingQueue>((ref) {
  return PingQueue(
    ref.watch(traccarSenderProvider),
    ref.watch(appDatabaseProvider),
  );
});

class PingQueue {
  final TraccarSender _sender;
  final AppDatabase _db;
  bool _flushing = false;

  PingQueue(this._sender, this._db);

  /// Send a position. Flushes any queued pings first; queues on failure.
  /// Returns the number of pings still pending after this call.
  Future<int> send({
    required Position position,
    required String deviceId,
  }) async {
    if (!_flushing) await _flush(deviceId);

    final ok = await _sender.send(position: position, deviceId: deviceId);

    if (!ok) {
      await _db.enqueue(PendingPingsCompanion.insert(
        deviceId: deviceId,
        lat: position.latitude,
        lon: position.longitude,
        timestamp: position.timestamp.millisecondsSinceEpoch ~/ 1000,
        speed: position.speed * 3.6,
        bearing: position.heading,
        altitude: position.altitude,
        accuracy: position.accuracy,
      ));
      print('[Queue] Stored ping — now ${await _db.countPending(deviceId)} pending');
    }

    return _db.countPending(deviceId);
  }

  Future<void> _flush(String deviceId) async {
    _flushing = true;
    try {
      final pending = await _db.pendingFor(deviceId);
      if (pending.isEmpty) return;
      print('[Queue] Flushing ${pending.length} pending ping(s)');
      for (final ping in pending) {
        final ok = await _sender.sendStored(
          deviceId: ping.deviceId,
          lat: ping.lat,
          lon: ping.lon,
          timestampSeconds: ping.timestamp,
          speed: ping.speed,
          bearing: ping.bearing,
          altitude: ping.altitude,
          accuracy: ping.accuracy,
        );
        if (ok) {
          await _db.dequeue(ping.id);
        } else {
          break; // still offline — stop trying
        }
      }
    } finally {
      _flushing = false;
    }
  }
}
