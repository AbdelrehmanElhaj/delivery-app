import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../shared/utils/constants.dart';

final traccarSenderProvider = Provider<TraccarSender>((ref) {
  return TraccarSender();
});

class TraccarSender {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppConstants.traccarBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Send position via OsmAnd HTTP protocol (proxied through nginx → port 5055)
  Future<bool> send({
    required Position position,
    required String deviceId,
  }) async {
    try {
      await _dio.get(
        AppConstants.traccarOsmandPath,
        queryParameters: {
          'id': deviceId,
          'lat': position.latitude.toStringAsFixed(6),
          'lon': position.longitude.toStringAsFixed(6),
          'timestamp':
              (position.timestamp.millisecondsSinceEpoch ~/ 1000).toString(),
          'speed': (position.speed * 3.6).toStringAsFixed(1), // m/s → km/h
          'bearing': position.heading.toStringAsFixed(1),
          'altitude': position.altitude.toStringAsFixed(1),
          'accuracy': position.accuracy.toStringAsFixed(1),
        },
      );
      return true;
    } on DioException catch (e) {
      print('[Traccar] Send failed: ${e.message}');
      return false;
    }
  }

  /// Replay a previously stored ping (used by PingQueue flush).
  Future<bool> sendStored({
    required String deviceId,
    required double lat,
    required double lon,
    required int timestampSeconds,
    required double speed,
    required double bearing,
    required double altitude,
    required double accuracy,
  }) async {
    try {
      await _dio.get(
        AppConstants.traccarOsmandPath,
        queryParameters: {
          'id': deviceId,
          'lat': lat.toStringAsFixed(6),
          'lon': lon.toStringAsFixed(6),
          'timestamp': timestampSeconds.toString(),
          'speed': speed.toStringAsFixed(1),
          'bearing': bearing.toStringAsFixed(1),
          'altitude': altitude.toStringAsFixed(1),
          'accuracy': accuracy.toStringAsFixed(1),
        },
      );
      return true;
    } on DioException {
      return false;
    }
  }
}
