import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/delivery_order.dart';
import '../../../../shared/theme/app_theme.dart';

class OrderCard extends StatelessWidget {
  final DeliveryOrder order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/orders/${order.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Order number
                  Text(
                    order.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  // Status badge
                  _StatusBadge(status: order.state),
                ],
              ),
              const SizedBox(height: 10),

              // Customer
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 15, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(order.customerName,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 6),

              if (order.tripName != null && order.tripName!.isNotEmpty) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.route_outlined,
                        size: 15, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        order.tripName!,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              if (order.scheduledDate != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 15, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(order.scheduledDate!),
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.chevron_right,
                    color: AppTheme.textSecondary, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = status.statusColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        status.statusLabel,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
