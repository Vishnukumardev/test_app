import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_app/utils/constants.dart';

import '../../services/api_service.dart';
import '../../services/network_service.dart';
import '../models/movie_details_model.dart';
import '../models/movie_list_model.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  final connectivityService = ref.read(connectivityServiceProvider);
  return ApiService(connectivityService);
});

final moviesListProvider =
    StateNotifierProvider<MoviesListNotifier, AsyncValue<List<Result>>>((ref) {
  final apiService = ref.read(apiServiceProvider);
  final connectivityService = ref.read(connectivityServiceProvider);
  return MoviesListNotifier(apiService, connectivityService);
});

class MoviesListNotifier extends StateNotifier<AsyncValue<List<Result>>> {
  final ApiService _apiService;
  final ConnectivityService _connectivityService;
  int _page = 1;
  bool hasMore = true;

  MoviesListNotifier(this._apiService, this._connectivityService)
      : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected) {
        fetchMovies(initial: true);
      }
    });

    fetchMovies();
  }

  Future<void> fetchMovies({bool initial = false}) async {
    if (!hasMore) return;

    if (!(await _connectivityService.isConnected())) {
      return;
    }

    if (initial) {
      state = const AsyncValue.loading();
      _page = 1; // Reset pagination when fetching initially
      hasMore = true;
    }

    try {
      final response = await _apiService
          .get("$getUsersMovieListEndpoint&page=$_page&api_key=$movie_api_key");

      final movieModel = MovieListModel.fromJson(response);
      final List<Result> movieList = movieModel.results;

      hasMore = movieList.isNotEmpty;
      state = AsyncValue.data(
          [...(initial ? [] : state.value ?? []), ...movieList]); // Append

      _page++;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

final moviesDetailsProvider =
    StateNotifierProvider<MovieDetailsNotifier, AsyncValue<MovieDetailsModel>>(
        (ref) {
  final apiService = ref.read(apiServiceProvider);
  final connectivityService = ref.read(connectivityServiceProvider);
  return MovieDetailsNotifier(apiService, connectivityService);
});

class MovieDetailsNotifier
    extends StateNotifier<AsyncValue<MovieDetailsModel>> {
  final ApiService _apiService;
  final ConnectivityService _connectivityService;

  MovieDetailsNotifier(this._apiService, this._connectivityService)
      : super(const AsyncValue.loading());

  Future<void> fetchMoviesDetails({required int id}) async {
    if (!(await _connectivityService.isConnected())) {
      state =
          const AsyncValue.error("No Internet Connection", StackTrace.empty);
      return;
    }

    // Set Loading state before making API call
    state = const AsyncValue.loading();
    print("$getMovieDetailsEndpoint$id?api_key=$movie_api_key");
    try {
      final response = await _apiService
          .get("$getMovieDetailsEndpoint$id?api_key=$movie_api_key");

      final movieModel = MovieDetailsModel.fromJson(response);

      state = AsyncValue.data(movieModel);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
