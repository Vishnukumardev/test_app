import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart';
import '../../services/api_service.dart';
import '../../services/network_service.dart';
import '../../services/work_manager_service.dart';
import '../../utils/constants.dart';
import '../models/user_list_model.dart';

final databaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final userListProvider =
    StateNotifierProvider<UserListNotifier, AsyncValue<List<Data>>>((ref) {
  return UserListNotifier(ref.read(apiServiceProvider));
});

class UserListNotifier extends StateNotifier<AsyncValue<List<Data>>> {
  final ApiService _apiService;
  int _page = 1;
  bool hasMore = true;
  bool _isFetching = false;

  UserListNotifier(this._apiService) : super(const AsyncValue.loading()) {
    _fetchInitialUsers();
  }

  Future<void> _fetchInitialUsers() async {
    await fetchUsers(initial: true);
    await fetchUsers(initial: false);
  }

  Future<void> fetchUsers({bool initial = false}) async {
    if (_isFetching || !hasMore) return;

    _isFetching = true;

    try {
      final response = await _apiService.get("$getUsersListEndpoint=$_page");
      final userModel = UserListModel.fromJson(response);
      final List<Data> userList = userModel.data;
      print("Page : $_page");
      if (userList.isEmpty) {
        hasMore = false;
      } else {
        state = AsyncValue.data([...state.value ?? [], ...userList]);

        _page++;
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }

    _isFetching = false;
  }

  Future<void> retry() async {
    _page = 1;
    hasMore = true;
    state = const AsyncValue.loading();
    await fetchUsers(initial: true);
    await fetchUsers(initial: false);
  }
}

final addUserProvider =
    StateNotifierProvider<AddUserNotifier, AsyncValue<User?>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final database = ref.watch(databaseProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return AddUserNotifier(apiService, database, connectivity);
});

class AddUserNotifier extends StateNotifier<AsyncValue<User?>> {
  final ApiService _apiService;
  final AppDatabase _database;
  final ConnectivityService _connectivity;

  AddUserNotifier(this._apiService, this._database, this._connectivity)
      : super(const AsyncValue.data(null));

  Future<void> addUser(String name, String job, bool bool) async {
    state = const AsyncValue.loading();
    final isConnected = _connectivity.isConnectedSync();

    if (isConnected) {
      try {
        final response = await _apiService
            .post(addUsersEndpoint, body: {"name": name, "job": job});
        final newUser = User(
          id: response['id'],
          name: name,
          job: job,
          isSynced: true,
        );

        state = AsyncValue.data(newUser);
      } catch (e) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    } else {
      final newUser = UsersCompanion(
        name: Value(name),
        job: Value(job),
        isSynced: const Value(false),
      );

      await _database.insertUser(newUser);
      WorkManagerService.registerSyncTask();
      state = AsyncValue.data(null);
    }
  }
}
