import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/location/location_service.dart';
import 'shared/theme/app_theme.dart';
import 'shared/utils/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background service
  await initBackgroundService();

  runApp(
    const ProviderScope(
      child: FoodTruckDriverApp(),
    ),
  );
}

class FoodTruckDriverApp extends ConsumerWidget {
  const FoodTruckDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Food Truck Driver',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
