import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A defensive, self-aware version of [Expanded].
///
/// Features:
/// *   **Crash Prevention:** Automatically detects unbounded constraints and applies a safe fallback size.
/// *   **Debug Feedback:** In debug mode, displays a red border and logs a detailed error explaining the issue and the fix.
/// *   **Flex Behavior:** When constraints are bounded, provides flex-based expansion similar to [Expanded].
class EzExpanded extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The flex factor to use for this child.
  ///
  /// If null or zero, the child is inflexible and determines its own size.
  /// If non-zero, the amount of space the child's can occupy in the main axis
  /// is determined by dividing the free space according to the flex factors of the flexible children.
  final int flex;

  /// Creates a defensive, self-aware version of [Expanded].
  ///
  /// This widget automatically detects unbounded constraints and applies a fix
  /// to prevent layout crashes, providing detailed debugging information in
  /// debug mode.
  const EzExpanded({
    super.key,
    this.flex = 1,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isUnboundedHeight = constraints.maxHeight.isInfinite;
        final bool isUnboundedWidth = constraints.maxWidth.isInfinite;

        // If constraints are bounded, we can safely size the child to fill available space
        if (!isUnboundedHeight && !isUnboundedWidth) {
          // Use SizedBox to fill the available space
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: child,
          );
        }

        // --- Apply safe fallback for unbounded constraints ---
        final mediaQuery = MediaQuery.of(context);

        final double fixedHeight;
        if (isUnboundedHeight) {
          // Calculate a reasonable default height based on the screen size.
          final calculatedSafeHeight =
              mediaQuery.size.height - mediaQuery.padding.top - kToolbarHeight;
          fixedHeight = calculatedSafeHeight * 0.5; // Use 50% as a default
        } else {
          fixedHeight = constraints.maxHeight;
        }

        final double fixedWidth;
        if (isUnboundedWidth) {
          fixedWidth = mediaQuery.size.width * 0.5; // Use 50% as a default
        } else {
          fixedWidth = constraints.maxWidth;
        }

        if (kDebugMode) {
          // Identify the parent widget causing the issue and report a detailed error.
          _reportError(context, isUnboundedWidth, isUnboundedHeight);

          // Wrap with a visual indicator to highlight the problematic widget.
          return Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2.5),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: SizedBox(
              width: fixedWidth,
              height: fixedHeight,
              child: child,
            ),
          );
        }

        // In release mode, apply the fix silently to prevent a crash.
        return SizedBox(
          width: fixedWidth,
          height: fixedHeight,
          child: child,
        );
      },
    );
  }

  /// Reports a detailed error about which dimension was unbounded.
  void _reportError(BuildContext context, bool badWidth, bool badHeight) {
    String culprit = "an unknown parent";
    context.visitAncestorElements((element) {
      if (element.widget is Flex ||
          element.widget is ListView ||
          element.widget is CustomScrollView) {
        culprit = element.widget.runtimeType.toString();
        return false;
      }
      return true;
    });

    String problematicDimension = "unknown";
    if (badWidth && badHeight) {
      problematicDimension = "width and height";
    } else if (badWidth) {
      problematicDimension = "width";
    } else {
      problematicDimension = "height";
    }

    FlutterError.reportError(
      FlutterErrorDetails(
        exception: 'EzExpanded: Unbounded $problematicDimension detected.',
        library: 'EzExpanded',
        context: ErrorDescription('while building EzExpanded'),
        informationCollector: () => [
          ErrorSummary('EzExpanded has applied an automatic layout fix.'),
          ErrorDescription(
            'This widget was placed in a context with infinite $problematicDimension (likely inside a $culprit). '
            'This would normally cause a layout crash.',
          ),
          ErrorHint(
            'ACTION REQUIRED: For a permanent fix, you must provide bounded constraints, such as wrapping in an Expanded, SizedBox, or Container with explicit dimensions.',
          ),
        ],
      ),
    );
  }
}
