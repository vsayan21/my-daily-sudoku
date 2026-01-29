import 'package:flutter/material.dart';

/// Displays hint feedback messages.
class HintFeedbackOverlay {
  /// Shows a short message using a snack bar.
  static void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1600),
      ),
    );
  }
}
