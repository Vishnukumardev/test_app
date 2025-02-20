import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workmanager/workmanager.dart';

import '../data/providers/user_provider.dart';
import '../database/app_database.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import 'network_service.dart';

const String syncTask = "sync_offline_users";

class WorkManagerService {
  static Future<void> initialize() async {
    Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: true, // Set to false in production
    );
  }

  static void registerSyncTask() {
    Workmanager().registerOneOffTask(
      "sync_users_task",
      syncTask,
      constraints: Constraints(
        networkType: NetworkType.connected, // Only run when connected
      ),
    );
  }

  @pragma('vm:entry-point')
  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      final container = ProviderContainer();
      final database = container.read(databaseProvider);
      final apiService = container.read(apiServiceProvider);
      final isConnected =
          container.read(connectivityServiceProvider).isConnectedSync();

      if (task == syncTask && isConnected) {
        await _syncOfflineUsers(database, apiService);
      }

      container.dispose(); // Dispose of the container after execution
      return Future.value(true);
    });
  }

  static Future<void> _syncOfflineUsers(
      AppDatabase database, ApiService apiService) async {
    final unsyncedUsers = await database.getUnsyncedUsers();

    for (var user in unsyncedUsers) {
      try {
        final response = await apiService.post(
          addUsersEndpoint,
          body: {"name": user.name, "job": user.job},
        );

        if (response != null && response['id'] != null) {
          await database.markUserAsSynced(user.id, response['id']);
          print("User ${user.name} synced with ID: ${response['id']}");
        }
      } catch (e) {
        print("Failed to sync user ${user.id}: $e");
      }
    }
  }
}
