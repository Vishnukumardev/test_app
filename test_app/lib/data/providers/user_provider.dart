import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/api_service.dart';
import '../../services/network_service.dart';
import '../../utils/constants.dart';
import '../models/user_list_model.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final connectivityService = ref.read(connectivityServiceProvider);
  return ApiService(connectivityService);
});

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
    _fetchInitialUsers(); // Fetch twice initially
  }

  Future<void> _fetchInitialUsers() async {
    await fetchUsers(initial: true); // First fetch
    await fetchUsers(initial: false); // Second fetch
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

        // Increment page
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
    await fetchUsers(initial: false); // Ensure two initial fetches
  }

  Future<void> addUser(String name, String job) async {
    try {
      final response = await _apiService.post(
        addUsersEndpoint,
        body: {"name": name, "job": job},
      );

      final newUser = Data.fromJson(response);
      state = AsyncValue.data([newUser, ...state.value ?? []]);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
