import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers/user_provider.dart';

class AddUserScreen extends ConsumerWidget {
  const AddUserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController jobController = TextEditingController();

    void _submitUser() async {
      final name = nameController.text.trim();
      final job = jobController.text.trim();

      if (name.isEmpty || job.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter both name and job")),
        );
        return;
      }

      await ref.read(userListProvider.notifier).addUser(name, job);

      // Show success dialog
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

    return Scaffold(
      appBar: AppBar(title: const Text("Add User")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: jobController,
              decoration: const InputDecoration(labelText: "Job"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitUser,
              child: const Text("Add User"),
            ),
          ],
        ),
      ),
    );
  }
}
