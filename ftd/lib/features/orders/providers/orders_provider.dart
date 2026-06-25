import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/delivery_order.dart';
import '../../../core/network/odoo_client.dart';
import '../../auth/providers/auth_provider.dart';

final ordersProvider =
    AsyncNotifierProvider<OrdersNotifier, List<DeliveryOrder>>(
        OrdersNotifier.new);

class OrdersNotifier extends AsyncNotifier<List<DeliveryOrder>> {
  @override
  Future<List<DeliveryOrder>> build() async {
    return _fetchOrders();
  }

  Future<List<DeliveryOrder>> _fetchOrders() async {
    final odoo = ref.read(odooClientProvider);
    final session = ref.read(authProvider.notifier).currentSession;
    if (session == null) return [];

    final records = await odoo.searchRead(
      model: 'delivery.order',
      domain: [
        ['trip_id.driver_id.user_id', '=', session.userId],
        ['state', 'not in', ['done', 'failed']],
      ],
      fields: [
        'id',
        'name',
        'partner_id',
        'state',
        'mode',
        'scheduled_date',
        'notes',
        'trip_id',
      ],
      order: 'scheduled_date asc',
    );

    return records.map(DeliveryOrder.fromOdoo).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchOrders);
  }

  // ─── Update order status via Odoo action method ───────────────────────────

  Future<void> updateStatus(int orderId, String newState) async {
    final odoo = ref.read(odooClientProvider);
    final order = state.value?.firstWhere((o) => o.id == orderId);
    if (order == null) return;

    final action = order.nextAction;
    if (action == null) return;

    // Optimistic update
    state = state.whenData((orders) => orders
        .map((o) => o.id == orderId ? o.copyWith(state: newState) : o)
        .toList());

    try {
      await odoo.call(
        model: 'delivery.order',
        method: action,
        args: [[orderId]],
      );
    } catch (e) {
      await refresh();
      rethrow;
    }
  }

  // ─── Mark failed ──────────────────────────────────────────────────────────

  Future<void> markFailed(int orderId, String reason) async {
    final odoo = ref.read(odooClientProvider);

    state = state.whenData((orders) => orders
        .map((o) => o.id == orderId ? o.copyWith(state: 'failed') : o)
        .toList());

    try {
      await odoo.call(
        model: 'delivery.order',
        method: 'action_failed',
        args: [[orderId]],
      );
    } catch (e) {
      await refresh();
      rethrow;
    }
  }
}
