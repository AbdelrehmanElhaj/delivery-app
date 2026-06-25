import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/orders_provider.dart';
import '../widgets/order_card.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../tracking/presentation/widgets/tracking_status_bar.dart';
import '../../../../shared/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final session = ref.watch(authProvider.notifier).currentSession;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Food Truck Driver'),
            if (session != null)
              Text(
                session.name,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w400),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign out',
            onPressed: () => _confirmLogout(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Tracking status
          const TrackingStatusBar(),

          // Orders list
          Expanded(
            child: ordersAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, _) => _ErrorView(
                message: e.toString(),
                onRetry: () => ref.read(ordersProvider.notifier).refresh(),
              ),
              data: (orders) {
                if (orders.isEmpty) return const _EmptyView();

                final active =
                    orders.where((o) => o.isActive).toList();
                final done = orders.where((o) => !o.isActive).toList();

                return RefreshIndicator(
                  color: AppTheme.primary,
                  onRefresh: () =>
                      ref.read(ordersProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 32),
                    children: [
                      if (active.isNotEmpty) ...[
                        _SectionHeader(
                            title: 'Active', count: active.length),
                        ...active.map((o) => OrderCard(order: o)),
                      ],
                      if (done.isNotEmpty) ...[
                        _SectionHeader(title: 'Completed', count: done.length),
                        ...done.map((o) => OrderCard(order: o)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text('Sign out?',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text('Tracking will stop.',
            style: TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Sign out',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends ConsumerWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.read(authProvider.notifier).currentSession;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_rounded,
                size: 56, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('No orders assigned',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            if (session != null) ...[
              const SizedBox(height: 4),
              Text('${session.name} · uid ${session.userId}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
            ],
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
              label: const Text('Refresh',
                  style: TextStyle(color: AppTheme.textSecondary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.divider),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => ref.read(ordersProvider.notifier).refresh(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
