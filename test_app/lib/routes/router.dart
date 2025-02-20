import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../modules/movie/movies_list_screen.dart';
import '../modules/movie/widgets/movie_details_screen.dart';
import '../modules/user/user_list_screen.dart';
import '../modules/user/widgets/add_user_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/users',
  routes: [
    GoRoute(
      path: '/users',
      builder: (BuildContext context, GoRouterState state) =>
          const UserListScreen(),
    ),
    GoRoute(
      path: '/movies',
      builder: (BuildContext context, GoRouterState state) =>
          const MoviesListScreen(),
    ),
    GoRoute(
      path: "/movie_details/:id",
      builder: (BuildContext context, GoRouterState state) {
        final movieId = int.parse(state.pathParameters['id']!);
        return MovieDetailsScreen(movieId: movieId);
      },
    ),
    GoRoute(
        path: "/add_user",
        builder: (BuildContext context, GoRouterState state) =>
            const AddUserScreen())
  ],
);
