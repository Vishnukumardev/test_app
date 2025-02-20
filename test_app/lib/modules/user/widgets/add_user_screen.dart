import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers/user_provider.dart';
import '../../../services/network_service.dart';

class AddUserScreen extends ConsumerWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController jobController = TextEditingController();
    final addUserState = ref.watch(addUserProvider);
    final isConnected =
        ref.watch(connectivityServiceProvider).isConnectedSync();
    void _submitUser() async {
      final name = nameController.text.trim();
      final job = jobController.text.trim();

      if (name.isEmpty || job.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter both name and job")),
        );
        return;
      }

      await ref.read(addUserProvider.notifier).addUser(name, job, true);

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text("User Created"),
            content: const Text("The user has been successfully added."),
            actions: [
              TextButton(
                onPressed: () async {
                  await ref
                      .read(userListProvider.notifier)
                      .fetchUsers(initial: true);
                  await ref
                      .read(userListProvider.notifier)
                      .fetchUsers(initial: false);
                  context.go("/users"); // Navigate to Users screen
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }

    return PopScope(
      canPop: false, // Prevents default back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/users'); // Navigate to UserListScreen
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Add User")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isConnected)
                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    padding: const EdgeInsets.all(10),
                    child: const Center(
                      child: Text(
                        "No Internet Connection",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                const Text(
                  "Create a New User",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: jobController,
                  decoration: InputDecoration(
                    labelText: "Job",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: addUserState.isLoading ? null : _submitUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: addUserState.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Add User",
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
