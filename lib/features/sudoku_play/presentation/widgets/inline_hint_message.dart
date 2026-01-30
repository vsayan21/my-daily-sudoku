import 'package:flutter/material.dart';

/// Inline hint feedback message shown below the action bar.
class InlineHintMessage extends StatelessWidget {
  /// Creates an inline hint message widget.
  const InlineHintMessage({
    super.key,
    required this.message,
    this.height = 22,
  });

  /// Message to display, or null to hide it.
  final String? message;

  /// Fixed height to keep layout stable.
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
        );

    return SizedBox(
      height: height,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: message == null
            ? const SizedBox(
                key: ValueKey('inline-hint-empty'),
              )
            : Align(
                key: ValueKey(message),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        message!,
                        style: textStyle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
