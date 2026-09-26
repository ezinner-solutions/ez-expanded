import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A defensive, self-aware drop-in replacement for [Expanded] that prevents
/// layout crashes from unbounded constraints or invalid parent widget hierarchy.
///
/// In standard Flutter, using [Expanded] can crash the application in two common scenarios:
///
/// 1. **Invalid Parent:** Using [Expanded] outside of a [Row], [Column], or [Flex]
///    throws a fatal [ParentDataWidget] assertion failure:
///    * `"Incorrect use of ParentDataWidget. Expanded widgets must be placed inside Flex widgets."`
/// 2. **Unbounded Flex Parent:** Using [Expanded] inside a [Row] or [Column] that is nested
///    inside an unbounded scroll view (such as [SingleChildScrollView] or [ListView]) throws:
///    * `"RenderFlex children have non-zero flex but incoming height/width constraints are unbounded."`
///
/// [EzExpanded] intercepts both error conditions defensively:
///
/// * **Crash Prevention:** Detects invalid parents or unbounded flex ancestors and
///   applies a safe, responsive fallback layout.
/// * **Developer Diagnostics:** In debug mode, highlights the widget with a red outline border
///   and logs an actionable [FlutterError] identifying the culprit parent widget.
/// * **Silent Protection:** In release mode, automatically resolves the layout so end users
///   never experience a crash or red screen.
/// * **Native Flex Behavior:** When placed inside a properly constrained [Flex] ([Row], [Column]),
///   it behaves as a native [Expanded] (or [Flexible]) with full support for [flex] factors.
///
/// ## Examples
///
/// ### Safe inside SingleChildScrollView (Crash Prevention)
///
/// In standard Flutter, placing `Expanded` here crashes with unbounded height:
///
/// ```dart
/// SingleChildScrollView(
///   child: Column(
///     children: [
///       const Text('Header'),
///       // Won't crash! EzExpanded falls back safely and reports a debug warning.
///       EzExpanded(
///         child: Container(color: Colors.blue),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ### Correct Usage inside a Constrained Column
///
/// ```dart
/// SizedBox(
///   height: 300,
///   child: Column(
///     children: [
///       const Text('Header'),
///       EzExpanded(
///         flex: 2,
///         child: Container(color: Colors.green),
///       ),
///       EzExpanded(
///         flex: 1,
///         child: Container(color: Colors.amber),
///       ),
///     ],
///   ),
/// )
/// ```
///
/// See also:
///
///  * [Expanded], the standard Flutter flex child widget.
///  * [Flexible], the parent data widget supporting custom [FlexFit].
class EzExpanded extends StatelessWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// The flex factor to use for this child when inside a bounded [Flex].
  ///
  /// Defaults to `1`.
  final int flex;

  /// How a flexible child is inscribed into the available space.
  ///
  /// Defaults to [FlexFit.tight] (matching standard [Expanded]).
  final FlexFit fit;

  /// Whether to display a red border indicator in debug mode when unbounded constraints
  /// or an invalid parent hierarchy is detected.
  ///
  /// Defaults to `true`. Has no effect in release mode.
  final bool showDebugIndicator;

  /// Optional custom fallback height to use when unbounded height or an invalid parent
  /// is detected.
  ///
  /// If `null`, defaults to 50% of available screen height.
  final double? fallbackHeight;

  /// Optional custom fallback width to use when unbounded width or an invalid parent
  /// is detected.
  ///
  /// If `null`, defaults to 50% of available screen width.
  final double? fallbackWidth;

  /// Optional callback invoked when unbounded constraints or an invalid parent is detected.
  ///
  /// Useful for automated telemetry, testing, or custom diagnostic logging.
  final void Function({
    required bool isInvalidParent,
    required bool isUnbounded,
    required String? culprit,
  })? onUnboundedDetected;

  /// Creates a defensive, self-aware version of [Expanded].
  const EzExpanded({
    super.key,
    this.flex = 1,
    this.fit = FlexFit.tight,
    this.showDebugIndicator = true,
    this.fallbackHeight,
    this.fallbackWidth,
    this.onUnboundedDetected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    RenderObjectElement? targetRenderElement;
    context.visitAncestorElements((element) {
      if (element is RenderObjectElement) {
        targetRenderElement = element;
        return false;
      }
      return true;
    });

    final parentRender = targetRenderElement?.renderObject;

    // 1. Check if the nearest render ancestor is a RenderFlex.
    if (parentRender is! RenderFlex) {
      final culprit =
          parentRender?.runtimeType.toString() ?? 'an unknown parent';
      return _handleProblematicLayout(
        context: context,
        isInvalidParent: true,
        isUnbounded: false,
        flexAxis: Axis.vertical,
        culprit: culprit,
        errorMessage:
            'EzExpanded was placed outside of a Row, Column, or Flex (nearest render ancestor is $culprit). '
            'In standard Flutter, this causes a fatal "Incorrect use of ParentDataWidget" exception.',
        actionHint:
            'ACTION REQUIRED: Move EzExpanded directly inside a Row, Column, or Flex, or replace it with a SizedBox/Container.',
      );
    }

    final Axis flexAxis = parentRender.direction;

    // 2. Check if the enclosing Flex is inside an unbounded scrollable in the main axis.
    bool isUnbounded = false;
    String? scrollCulprit;
    bool foundBoundedConstraint = false;

    targetRenderElement!.visitAncestorElements((element) {
      final widget = element.widget;

      // Intervening bounded constraint widgets
      if (widget is SizedBox) {
        final extent = flexAxis == Axis.vertical ? widget.height : widget.width;
        if (extent != null && !extent.isInfinite) {
          foundBoundedConstraint = true;
          return false;
        }
      } else if (widget is ConstrainedBox) {
        final maxExtent = flexAxis == Axis.vertical
            ? widget.constraints.maxHeight
            : widget.constraints.maxWidth;
        if (maxExtent.isFinite) {
          foundBoundedConstraint = true;
          return false;
        }
      } else if (widget is Container) {
        final constraints = widget.constraints;
        if (constraints != null) {
          final maxExtent = flexAxis == Axis.vertical
              ? constraints.maxHeight
              : constraints.maxWidth;
          if (maxExtent.isFinite) {
            foundBoundedConstraint = true;
            return false;
          }
        }
      }

      // If we encounter a scrollable before any bounded constraint:
      if (!foundBoundedConstraint) {
        if (widget is SingleChildScrollView ||
            widget is ListView ||
            widget is CustomScrollView ||
            widget is GridView ||
            widget is ScrollView) {
          isUnbounded = true;
          scrollCulprit = widget.runtimeType.toString();
          return false;
        }
      }

      return true;
    });

    if (isUnbounded) {
      final dimension = flexAxis == Axis.vertical ? 'height' : 'width';
      return _handleProblematicLayout(
        context: context,
        isInvalidParent: false,
        isUnbounded: true,
        flexAxis: flexAxis,
        culprit: scrollCulprit,
        errorMessage:
            'EzExpanded was placed inside a $scrollCulprit with unbounded $dimension. '
            'In standard Flutter, this causes a fatal "RenderFlex children have non-zero flex but incoming constraints are unbounded" exception.',
        actionHint:
            'ACTION REQUIRED: For a permanent fix, provide bounded constraints (e.g. wrap the Column in a SizedBox with explicit dimensions) or remove EzExpanded.',
      );
    }

    // 3. Valid, bounded Flex parent: return native Flexible / Expanded!
    return Flexible(
      flex: flex,
      fit: fit,
      child: child,
    );
  }

  Widget _handleProblematicLayout({
    required BuildContext context,
    required bool isInvalidParent,
    required bool isUnbounded,
    required Axis flexAxis,
    required String? culprit,
    required String errorMessage,
    required String actionHint,
  }) {
    if (kDebugMode) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: isInvalidParent
              ? 'EzExpanded: Invalid parent hierarchy detected.'
              : 'EzExpanded: Unbounded flex constraints detected.',
          library: 'EzExpanded',
          context: ErrorDescription('while building EzExpanded'),
          informationCollector: () => [
            ErrorSummary(
                'EzExpanded has applied an automatic layout fallback to prevent a crash.'),
            ErrorDescription(errorMessage),
            ErrorHint(actionHint),
          ],
        ),
      );

      onUnboundedDetected?.call(
        isInvalidParent: isInvalidParent,
        isUnbounded: isUnbounded,
        culprit: culprit,
      );
    }

    final mediaQuery = MediaQuery.maybeOf(context);
    final view = View.maybeOf(context);

    final Size screenSize;
    if (mediaQuery != null) {
      screenSize = mediaQuery.size;
    } else if (view != null && view.devicePixelRatio > 0) {
      screenSize = view.physicalSize / view.devicePixelRatio;
    } else {
      screenSize = const Size(360.0, 640.0);
    }

    final double availableHeight =
        (screenSize.height - (mediaQuery?.padding.top ?? 0) - kToolbarHeight)
            .clamp(100.0, double.infinity);

    final double fallbackH = fallbackHeight ?? (availableHeight * 0.5);
    final double fallbackW = fallbackWidth ?? (screenSize.width * 0.5);

    final double? width = flexAxis == Axis.horizontal ? fallbackW : null;
    final double? height = flexAxis == Axis.vertical ? fallbackH : null;

    Widget fallbackWidget = SizedBox(
      width: width,
      height: height,
      child: child,
    );

    if (kDebugMode && showDebugIndicator) {
      fallbackWidget = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2.5),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: fallbackWidget,
      );
    }

    return fallbackWidget;
  }
}
