import 'package:workmanager/workmanager.dart';

class WorkManagerService {
  static void initialize() {
    Workmanager().initialize(
      _callbackDispatcher,
      isInDebugMode: true, // Set to false in production
    );
  }

  static void _callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      print("Background Task Running: $task");
      return Future.value(true);
    });
  }
}
