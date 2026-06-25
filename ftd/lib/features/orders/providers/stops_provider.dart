import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/delivery_stop.dart';
import '../../../core/network/odoo_client.dart';

final stopsProvider =
    AsyncNotifierProvider.family<StopsNotifier, List<DeliveryStop>, int>(
  StopsNotifier.new,
);

class StopsNotifier extends FamilyAsyncNotifier<List<DeliveryStop>, int> {
  @override
  Future<List<DeliveryStop>> build(int orderId) async {
    return _fetch(orderId);
  }

  Future<List<DeliveryStop>> _fetch(int orderId) async {
    final odoo = ref.read(odooClientProvider);
    final records = await odoo.searchRead(
      model: 'delivery.stop',
      domain: [
        ['order_id', '=', orderId]
      ],
      fields: [
        'id',
        'sequence',
        'partner_id',
        'partner_lat',
        'partner_lng',
        'status',
        'eta',
        'actual_arrival',
        'notes',
        'photo_count',
      ],
      order: 'sequence asc',
    );
    return records.map(DeliveryStop.fromOdoo).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  Future<void> updateStopStatus(int stopId, String newStatus) async {
    final odoo = ref.read(odooClientProvider);
    final stop = state.value?.firstWhere((s) => s.id == stopId);
    if (stop == null) return;

    final action = stop.nextAction;
    if (action == null) return;

    // Optimistic update
    final now = newStatus == 'arrived' ? DateTime.now().toUtc() : null;
    state = state.whenData((stops) => stops
        .map((s) => s.id == stopId
            ? s.copyWith(
                status: newStatus,
                actualArrival: now ?? s.actualArrival,
              )
            : s)
        .toList());

    try {
      await odoo.call(
        model: 'delivery.stop',
        method: action,
        args: [[stopId]],
      );
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  Future<void> markStopFailed(int stopId, String reason) async {
    final odoo = ref.read(odooClientProvider);

    state = state.whenData((stops) => stops
        .map((s) => s.id == stopId ? s.copyWith(status: 'failed') : s)
        .toList());

    try {
      await odoo.call(
        model: 'delivery.stop',
        method: 'action_failed',
        args: [[stopId]],
        kwargs: {'reason': reason},
      );
    } catch (e) {
      await refresh();
      rethrow;
    }
  }
}
