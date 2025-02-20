import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_app/utils/constants.dart';

import '../../data/providers/movie_provider.dart';
import '../../services/network_service.dart';
import '../../widgets/snack_bar.dart';

class MoviesListScreen extends ConsumerStatefulWidget {
  const MoviesListScreen({super.key});

  @override
  ConsumerState<MoviesListScreen> createState() => _MoviesListScreenState();
}

class _MoviesListScreenState extends ConsumerState<MoviesListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Listen to connectivity changes
    ref
        .read(connectivityServiceProvider)
        .onConnectivityChanged
        .listen((status) {
      setState(() => isConnected = status);
      if (!status) {
        SnackbarNotification.showError(context, "No Internet Connection");
      } else {
        SnackbarNotification.showSuccess(context, "Back Online");
        ref.read(moviesListProvider.notifier).fetchMovies(initial: true);
      }
    });

    // Initial fetch with connectivity check
    Future.microtask(() async {
      final currentStatus =
          await ref.read(connectivityServiceProvider).isConnected();
      setState(() => isConnected = currentStatus);

      if (!currentStatus) {
        SnackbarNotification.showError(context, "No Internet Connection");
      } else {
        ref.read(moviesListProvider.notifier).fetchMovies();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      final moviesNotifier = ref.read(moviesListProvider.notifier);
      if (moviesNotifier.hasMore) {
        moviesNotifier.fetchMovies();
      } else {
        SnackbarNotification.showError(context, "No more movies available.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected =
        ref.watch(connectivityServiceProvider).isConnectedSync();

    final moviesAsync = ref.watch(moviesListProvider);
    print("Connection Status : ${isConnected}");

    return PopScope(
      canPop: false, // Prevents default back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/users'); // Navigate to UserListScreen
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Movies List')),
        body: Column(
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
            Expanded(
              child: moviesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Refresh List", textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(moviesListProvider.notifier)
                              .fetchMovies(initial: true);
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
                data: (movies) {
                  if (movies.isEmpty) {
                    Future.microtask(() {
                      SnackbarNotification.showError(
                          context, 'No movies available.');
                    });
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: movies.length + 1,
                    itemBuilder: (context, index) {
                      if (index < movies.length) {
                        final movie = movies[index];
                        return GestureDetector(
                          onTap: () {
                            context.go('/movie_details/${movie.id}');
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ListTile(
                              leading: CachedNetworkImage(
                                imageUrl:
                                    "$baseImageUrlEndpoint${movie.backdropPath}",
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.movie),
                              ),
                              title: Text(movie.title),
                              subtitle: Text(
                                  "Rating: ${movie.voteAverage.toStringAsFixed(1)}"),
                            ),
                          ),
                        );
                      } else if (ref
                          .read(moviesListProvider.notifier)
                          .hasMore) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
