import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_app/routes/router.dart';
import 'package:test_app/services/network_service.dart';
import 'package:test_app/services/work_manager_service.dart';

@pragma('vm:entry-point')
void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await WorkManagerService.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Run in a separate thread using Future.microtask
    Future.microtask(() {
      ref
          .read(connectivityServiceProvider)
          .onConnectivityChanged
          .listen((status) {
        print(
            "Network Status (Background Task): $status"); // Print connectivity changes
      });
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
