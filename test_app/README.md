# Test App

A Flutter app that displays a list of users, allows adding users, and shows trending movies. Built with **Riverpod** for state management and follows best practices.

## Features

### User List Screen

- Fetches and displays a **paginated list of users** from [ReqRes API](https://reqres.in/api/users?page={page}).
- Shows **first name, last name, and avatar image**.
- Implements **pagination** to load more users as the user scrolls.
- Clicking a user navigates to the **Movie List Screen**.

### Add User Functionality

- Floating Action Button (**FAB**) to navigate to the **Add User Screen**.
- Users can **input name and job** to create a new user.
- If online, posts new user to [ReqRes API](https://reqres.in/api/users).
- If offline, stores user data in Drift (SQLite).
- Uses **WorkManager** to sync offline users when online.
- Updates the user ID after successful syncing.
- WorkManager functionality not yet tested.

### Movie List Screen

- Fetches and displays a **paginated list of trending movies** from [TMDB API](https://api.themoviedb.org/3/trending/movie/day?language=en-US\&page={page}\&api_key=YOUR_API_KEY).
- Displays **movie poster, title, and release date**.
- Implements **infinite scroll pagination**.
- Clicking a movie navigates to the **Movie Detail Screen**.

### Movie Detail Screen

- Fetches **detailed movie info** from [TMDB API](https://api.themoviedb.org/3/movie/{movie_id}?api_key=YOUR_API_KEY).
- Displays **title, description, release date, and poster image**.

---

## Architecture & Best Practices

This project follows **clean architecture principles** and uses **Riverpod** for state management.

### Technologies Used

- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Networking**: HTTP, Connectivity Plus
- **Image Caching**: CachedNetworkImage
- **Local Storage**: Drift (SQLite)
- **Background Tasks**: WorkManager

---

## Dependencies Used

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  go_router: ^14.8.0
  connectivity_plus: ^6.1.3
  http: ^1.3.0
  cached_network_image: ^3.4.1
  workmanager: ^0.5.2
  drift: ^2.25.1
  path_provider: ^2.1.5
  sqlite3_flutter_libs: ^0.5.0
  path: ^1.8.0

dev_dependencies:
  drift_dev: ^2.23.0
  build_runner: ^2.4.13
```

---

## Setup & Installation

### Clone the Repository

```sh
git clone https://github.com/your-repo/test-app.git
cd test-app
```

### Get Dependencies

```sh
flutter pub get
```

### Run the App

```sh
flutter run
```

## License

This project is licensed under the **MIT License**.


