import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SnackbarNotification {
  static void showSuccess(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 2)}) {
    _showSnackbar(context, message, Colors.green, duration);
  }

  static void showError(BuildContext context, String message,
      {Duration duration = const Duration(seconds: 2)}) {
    _showSnackbar(context, message, Colors.red, duration);
  }

  static void showException(BuildContext context, Exception exception,
      {Duration duration = const Duration(seconds: 3)}) {
    _showSnackbar(
        context, 'Error: ${exception.toString()}', Colors.orange, duration);
  }

  static void _showSnackbar(BuildContext context, String message,
      Color backgroundColor, Duration duration) {
    if (context.mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(color: Colors.white)),
            backgroundColor: backgroundColor,
            duration: duration,
          ),
        );
      });
    }
  }
}
