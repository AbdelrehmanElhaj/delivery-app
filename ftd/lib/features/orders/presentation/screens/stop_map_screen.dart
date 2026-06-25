import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/delivery_stop.dart';
import '../../providers/stops_provider.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/routing/osrm_service.dart';
import '../../../../shared/theme/app_theme.dart';

class StopMapScreen extends ConsumerStatefulWidget {
  final int orderId;
  final String orderName;

  const StopMapScreen({
    super.key,
    required this.orderId,
    required this.orderName,
  });

  @override
  ConsumerState<StopMapScreen> createState() => _StopMapScreenState();
}

class _StopMapScreenState extends ConsumerState<StopMapScreen> {
  final _mapController = MapController();
  Position? _driverPosition;
  List<LatLng>? _routePoints;
  bool _routeLoading = false;
  List<DeliveryStop>? _locatedStops;

  @override
  void initState() {
    super.initState();
    _fetchDriverPosition();
  }

  Future<void> _fetchDriverPosition() async {
    try {
      final pos = await ref.read(locationServiceProvider).getCurrentPosition();
      if (mounted) {
        setState(() => _driverPosition = pos);
        _maybeStartRoute();
      }
    } catch (_) {}
  }

  void _onStopsReady(List<DeliveryStop> located) {
    if (_locatedStops == located) return;
    _locatedStops = located;
    _maybeStartRoute();
  }

  Future<void> _maybeStartRoute() async {
    if (_routePoints != null || _routeLoading) return;
    final stops = _locatedStops;
    if (stops == null) return;

    final waypoints = <LatLng>[
      if (_driverPosition != null)
        LatLng(_driverPosition!.latitude, _driverPosition!.longitude),
      ...stops.map((s) => LatLng(s.lat!, s.lng!)),
    ];
    if (waypoints.length < 2) return;

    setState(() => _routeLoading = true);
    try {
      final route = await ref.read(osrmServiceProvider).fetchRoute(waypoints);
      if (mounted) setState(() => _routePoints = route);
    } catch (_) {
      if (mounted) setState(() => _routePoints = waypoints);
    } finally {
      if (mounted) setState(() => _routeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stopsAsync = ref.watch(stopsProvider(widget.orderId));

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text(widget.orderName),
        leading: const BackButton(),
      ),
      body: stopsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (stops) {
          final located = stops.where((s) => s.hasCoordinates).toList();
          if (located.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 48, color: AppTheme.textSecondary),
                  SizedBox(height: 12),
                  Text('No location data for stops',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }

          // Kick off route once we have the stops (driver position may arrive later)
          _onStopsReady(located);

          return Stack(
            children: [
              _MapView(
                stops: located,
                driverPosition: _driverPosition,
                mapController: _mapController,
                routePoints: _routePoints,
              ),
              if (_routeLoading)
                Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppTheme.primary),
                          ),
                          SizedBox(width: 8),
                          Text('Loading route…',
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MapView extends StatelessWidget {
  final List<DeliveryStop> stops;
  final Position? driverPosition;
  final MapController mapController;
  final List<LatLng>? routePoints;

  const _MapView({
    required this.stops,
    required this.driverPosition,
    required this.mapController,
    required this.routePoints,
  });

  @override
  Widget build(BuildContext context) {
    final stopPoints = stops.map((s) => LatLng(s.lat!, s.lng!)).toList();
    final allPoints = [
      ...stopPoints,
      if (driverPosition != null)
        LatLng(driverPosition!.latitude, driverPosition!.longitude),
    ];

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: stopPoints.first,
        initialZoom: 13,
        onMapReady: () {
          if (allPoints.length >= 2) {
            mapController.fitCamera(
              CameraFit.bounds(
                bounds: LatLngBounds.fromPoints(allPoints),
                padding: const EdgeInsets.all(64),
              ),
            );
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.hdrelhaj.dms',
        ),
        if (routePoints != null && routePoints!.length >= 2)
          PolylineLayer<Object>(
            polylines: [
              Polyline<Object>(
                points: routePoints!,
                color: AppTheme.primary,
                strokeWidth: 4,
                borderColor: AppTheme.primary.withAlpha(60),
                borderStrokeWidth: 2,
              ),
            ],
          ),
        MarkerLayer(
          markers: stops.map((stop) {
            return Marker(
              point: LatLng(stop.lat!, stop.lng!),
              width: 36,
              height: 36,
              child: _StopPin(stop: stop),
            );
          }).toList(),
        ),
        if (driverPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                    driverPosition!.latitude, driverPosition!.longitude),
                width: 22,
                height: 22,
                child: _DriverDot(),
              ),
            ],
          ),
      ],
    );
  }
}

class _StopPin extends StatelessWidget {
  final DeliveryStop stop;
  const _StopPin({required this.stop});

  @override
  Widget build(BuildContext context) {
    final color = _stopColor(stop.status);
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
              color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Center(
        child: Text(
          '${stop.sequence}',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Color _stopColor(String status) {
    switch (status) {
      case 'done':
        return AppTheme.success;
      case 'arrived':
        return AppTheme.primary;
      case 'failed':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }
}

class _DriverDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 6)
        ],
      ),
    );
  }
}
