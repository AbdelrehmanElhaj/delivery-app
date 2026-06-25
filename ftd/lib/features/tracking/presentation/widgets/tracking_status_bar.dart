import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tracking_provider.dart';
import '../../../../shared/theme/app_theme.dart';

class TrackingStatusBar extends ConsumerWidget {
  const TrackingStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: tracking.isTracking
            ? AppTheme.success.withOpacity(0.12)
            : AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tracking.isTracking
              ? AppTheme.success.withOpacity(0.4)
              : AppTheme.divider,
        ),
      ),
      child: Row(
        children: [
          // Pulsing indicator
          _TrackingDot(active: tracking.isTracking),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tracking.isTracking ? 'Live Tracking' : 'Tracking Off',
                  style: TextStyle(
                    color: tracking.isTracking
                        ? AppTheme.success
                        : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                if (tracking.lastPing != null && tracking.isTracking)
                  Text(
                    'Last ping: ${_formatTime(tracking.lastPing!)}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11),
                  ),
                if (tracking.pendingCount > 0)
                  Text(
                    '${tracking.pendingCount} ping${tracking.pendingCount == 1 ? '' : 's'} queued',
                    style: const TextStyle(
                        color: AppTheme.warning, fontSize: 11),
                  ),
              ],
            ),
          ),

          // Toggle switch
          if (!tracking.hasPermission)
            TextButton(
              onPressed: () =>
                  ref.read(trackingProvider.notifier).requestPermissions(),
              child: const Text('Enable',
                  style: TextStyle(color: AppTheme.primary, fontSize: 13)),
            )
          else
            Switch.adaptive(
              value: tracking.isTracking,
              onChanged: (_) =>
                  ref.read(trackingProvider.notifier).toggleTracking(),
              activeColor: AppTheme.success,
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    return '${diff.inMinutes}m ago';
  }
}

class _TrackingDot extends StatefulWidget {
  final bool active;
  const _TrackingDot({required this.active});

  @override
  State<_TrackingDot> createState() => _TrackingDotState();
}

class _TrackingDotState extends State<_TrackingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? AppTheme.success : AppTheme.textSecondary;
    if (!widget.active) {
      return Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle));
    }
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
