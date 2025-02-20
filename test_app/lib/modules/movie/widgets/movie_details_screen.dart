import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/providers/movie_provider.dart';
import '../../../services/network_service.dart';
import '../../../utils/constants.dart';

class MovieDetailsScreen extends ConsumerStatefulWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  ConsumerState<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends ConsumerState<MovieDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(moviesDetailsProvider.notifier)
          .fetchMoviesDetails(id: widget.movieId);
    });
  }

  Future<bool> _onWillPop() async {
    context.go('/movies'); // Navigate back to UserListScreen
    return false; // Prevent default back navigation
  }

  @override
  Widget build(BuildContext context) {
    final movieDetails = ref.watch(moviesDetailsProvider);
    final isConnected =
        ref.watch(connectivityServiceProvider).isConnectedSync();

    return PopScope(
      canPop: false, // Prevents default back navigation
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/movies'); // Navigate to UserListScreen
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Movie Details')),
        body: movieDetails.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text(error.toString())),
          data: (movie) => Padding(
            padding: const EdgeInsets.all(16.0),
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
                Text(movie.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: CachedNetworkImage(
                      imageUrl: "$baseImageUrlEndpoint${movie.posterPath}",
                      fit: BoxFit.contain,
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text("Rating: ${movie.voteAverage.toStringAsFixed(1)}"),
                const SizedBox(height: 10),
                Text(movie.overview),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
