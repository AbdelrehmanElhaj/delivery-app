import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

final osrmServiceProvider = Provider<OsrmService>((_) => OsrmService());

class OsrmService {
  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ));

  // Returns ordered road-following waypoints for the given stops.
  // OSRM uses lon,lat order; LatLng is lat,lng — mind the swap.
  Future<List<LatLng>> fetchRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return waypoints;

    final coords =
        waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');

    final res = await _dio.get(
      'https://router.project-osrm.org/route/v1/driving/$coords',
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
      },
    );

    final routes = res.data['routes'] as List?;
    if (routes == null || routes.isEmpty) return waypoints;

    final coords2d =
        (routes[0]['geometry']['coordinates'] as List).cast<List>();

    return coords2d
        .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();
  }
}
