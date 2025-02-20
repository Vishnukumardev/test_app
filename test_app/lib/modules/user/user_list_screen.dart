import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/widgets/snack_bar.dart';

import '../../data/models/user_list_model.dart';
import '../../data/providers/user_provider.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      final userListNotifier = ref.read(userListProvider.notifier);
      if (userListNotifier.hasMore) {
        userListNotifier.fetchUsers();
      } else {
        SnackbarNotification.showError(context, "No More Users");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userListAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User List')),
      body: Column(
        children: [
          Expanded(
            child: userListAsync.when(
              loading: () => _buildLoadingState(ref),
              error: (error, stack) => _buildErrorState(ref),
              data: (users) => _buildUserList(ref, users),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go("/add_user");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLoadingState(WidgetRef ref) {
    final previousUsers = ref.read(userListProvider).asData?.value ?? [];
    if (previousUsers.isNotEmpty) {
      return _buildUserList(ref, previousUsers); // Show cached users
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Failed to load users",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(userListProvider.notifier).retry();
            },
            child: const Text("Refresh"),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList(WidgetRef ref, List<Data> users) {
    final userListNotifier = ref.watch(userListProvider.notifier);

    return ListView.builder(
      controller: _scrollController,
      itemCount: users.length + 1, // Extra item for loader
      itemBuilder: (context, index) {
        if (index < users.length) {
          final Data user = users[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(user.avatar),
            ),
            title: Text(user.firstName),
            subtitle: Text(user.email),
            onTap: () {
              context.go('/movies');
            },
          );
        } else if (userListNotifier.hasMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(), // Show loader at bottom
            ),
          );
        } else {
          return const SizedBox.shrink(); // No more items
        }
      },
    );
  }
}
