import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/delivery_order.dart';
import '../../data/delivery_stop.dart';
import '../../providers/orders_provider.dart';
import '../../providers/stops_provider.dart';
import '../../../../shared/theme/app_theme.dart';

class OrderDetailScreen extends ConsumerWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);

    return ordersAsync.when(
      loading: () => const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: AppTheme.primary))),
      error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: Center(child: Text(e.toString()))),
      data: (orders) {
        final order = orders.firstWhere(
          (o) => o.id == orderId,
          orElse: () => throw Exception('Order not found'),
        );
        return _OrderDetailView(order: order);
      },
    );
  }
}

class _OrderDetailView extends ConsumerWidget {
  final DeliveryOrder order;
  const _OrderDetailView({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(order.name),
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'View map',
            onPressed: () => context.push(
                '/orders/${order.id}/map?name=${Uri.encodeComponent(order.name)}'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          _StatusCard(state: order.state),
          const SizedBox(height: 16),

          // Info card
          _InfoCard(order: order),
          const SizedBox(height: 16),

          // Stops card
          _StopsCard(orderId: order.id),
          const SizedBox(height: 24),

          // Action buttons
          if (order.nextState != null) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline),
              label: Text(order.nextStateLabel!),
              onPressed: () => _updateStatus(context, ref, order.nextState!),
            ),
            const SizedBox(height: 12),
          ],

          // Fail button (only for active orders)
          if (order.isActive)
            OutlinedButton.icon(
              icon: const Icon(Icons.cancel_outlined, color: AppTheme.error),
              label: const Text('Report Failure',
                  style: TextStyle(color: AppTheme.error)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppTheme.error),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showFailureDialog(context, ref),
            ),
        ],
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context, WidgetRef ref, String newState) async {
    try {
      await ref.read(ordersProvider.notifier).updateStatus(order.id, newState);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newState.statusLabel}'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (newState == 'done') context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showFailureDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Report Failure',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Describe what happened...',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(ordersProvider.notifier)
                  .markFailed(order.id, ctrl.text);
              if (context.mounted) context.pop();
            },
            child: const Text('Submit',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String state;
  const _StatusCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final color = state.statusColor;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(_statusIcon(state), color: color, size: 28),
          const SizedBox(width: 12),
          Text(state.statusLabel,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  IconData _statusIcon(String state) {
    switch (state) {
      case 'draft':
        return Icons.edit_outlined;
      case 'confirmed':
        return Icons.assignment_outlined;
      case 'in_progress':
        return Icons.local_shipping_outlined;
      case 'done':
        return Icons.check_circle_outline;
      case 'failed':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }
}

class _InfoCard extends StatelessWidget {
  final DeliveryOrder order;
  const _InfoCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: [
          _Row(Icons.person_outline, 'Customer', order.customerName),
          if (order.tripName != null && order.tripName!.isNotEmpty) ...[
            const Divider(color: AppTheme.divider, height: 24),
            _Row(Icons.route_outlined, 'Trip', order.tripName!),
          ],
          const Divider(color: AppTheme.divider, height: 24),
          _Row(Icons.local_shipping_outlined, 'Mode',
              order.mode == 'pickup' ? 'Pickup' : 'Delivery'),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            const Divider(color: AppTheme.divider, height: 24),
            _Row(Icons.notes_outlined, 'Notes', order.notes!),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stops ────────────────────────────────────────────────────────────────────

class _StopsCard extends ConsumerWidget {
  final int orderId;
  const _StopsCard({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stopsAsync = ref.watch(stopsProvider(orderId));

    return stopsAsync.when(
      loading: () => const Center(
          child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: CircularProgressIndicator(
            strokeWidth: 2, color: AppTheme.primary),
      )),
      error: (_, __) => const SizedBox.shrink(),
      data: (stops) {
        if (stops.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('STOPS',
                  style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              const SizedBox(height: 12),
              ...stops.asMap().entries.map((e) => _StopItem(
                    stop: e.value,
                    isLast: e.key == stops.length - 1,
                    orderId: orderId,
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _StopItem extends ConsumerWidget {
  final DeliveryStop stop;
  final bool isLast;
  final int orderId;
  const _StopItem({required this.stop, required this.isLast, required this.orderId});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _stopColor(stop.status);
    return InkWell(
      onTap: stop.isActive
          ? () => _showStopActions(context, ref)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: _StopRow(stop: stop, isLast: isLast, color: color),
    );
  }

  void _showStopActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _StopActionSheet(
        stop: stop,
        orderId: orderId,
        onAction: (action) async {
          Navigator.pop(context);
          if (action == 'failed') {
            _showStopFailureDialog(context, ref);
          } else {
            await _doUpdate(context, ref, action);
          }
        },
      ),
    );
  }

  Future<void> _doUpdate(
      BuildContext context, WidgetRef ref, String newStatus) async {
    try {
      await ref
          .read(stopsProvider(orderId).notifier)
          .updateStopStatus(stop.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Stop marked $newStatus'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }

  void _showStopFailureDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Report Stop Failure',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Describe what happened...',
            hintStyle: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref
                    .read(stopsProvider(orderId).notifier)
                    .markStopFailed(stop.id, ctrl.text);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed: $e'),
                    backgroundColor: AppTheme.error,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }
            },
            child:
                const Text('Submit', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  final DeliveryStop stop;
  final bool isLast;
  final Color color;
  const _StopRow({required this.stop, required this.isLast, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline column
        SizedBox(
          width: 28,
          child: Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color),
                ),
                child: Center(
                  child: Text('${stop.sequence}',
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              if (!isLast)
                Container(width: 1, height: 32, color: AppTheme.divider),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(stop.partnerName,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(stop.statusLabel, color),
                  ],
                ),
                if (stop.eta != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined,
                          size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('ETA ${_fmt(stop.eta!)}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                      if (stop.actualArrival != null) ...[
                        const Text('  ·  ',
                            style: TextStyle(color: AppTheme.textSecondary)),
                        const Icon(Icons.check_circle_outline,
                            size: 12, color: AppTheme.success),
                        const SizedBox(width: 4),
                        Text(_fmt(stop.actualArrival!),
                            style: const TextStyle(
                                color: AppTheme.success, fontSize: 12)),
                      ],
                    ],
                  ),
                ],
                if (stop.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(stop.notes!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ],
                if (stop.photoCount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.photo_outlined,
                          size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('${stop.photoCount} photo${stop.photoCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime dt) {
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Stop action sheet ────────────────────────────────────────────────────────

class _StopActionSheet extends StatelessWidget {
  final DeliveryStop stop;
  final int orderId;
  final void Function(String action) onAction;

  const _StopActionSheet({
    required this.stop,
    required this.orderId,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(stop.partnerName,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('Stop #${stop.sequence}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            if (stop.nextStatusLabel != null) ...[
              _ActionButton(
                icon: Icons.check_circle_outline,
                label: stop.nextStatusLabel!,
                color: AppTheme.success,
                onTap: () => onAction(stop.nextStatus!),
              ),
              const SizedBox(height: 10),
            ],
            _ActionButton(
              icon: Icons.cancel_outlined,
              label: 'Report Failure',
              color: AppTheme.error,
              onTap: () => onAction('failed'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
