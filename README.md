# EzExpanded

A defensive, crash-safe drop-in replacement for Flutter's `Expanded` that provides true flex-based expansion inside bounded `Row`, `Column`, and `Flex` widgets, while preventing layout crashes from unbounded constraints or invalid parent widget hierarchy.

[![pub package](https://img.shields.io/pub/v/ez_expanded.svg)](https://pub.dev/packages/ez_expanded)
[![likes](https://img.shields.io/pub/likes/ez_expanded.svg)](https://pub.dev/packages/ez_expanded)
[![pub points](https://img.shields.io/pub/points/ez_expanded.svg)](https://pub.dev/packages/ez_expanded)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Problem Statement

In Flutter, standard `Expanded` and `Flexible` widgets must be direct children of a `Flex` (`Row`, `Column`, or `Flex`). Using them incorrectly triggers fatal runtime assertions that crash the application with a red error screen:

1. **Invalid Parent Hierarchy:** Using `Expanded` outside a `Flex` container (for example, inside a `Stack`, `Container`, or directly in a `Scaffold` body) crashes immediately.
2. **Unbounded Flex Container:** Using `Expanded` inside a `Column` or `Row` placed inside an unconstrained scroll view (`SingleChildScrollView`, `ListView`) gives the flex container infinite space, violating Flutter's flex layout algorithm.

### Targeted Error Signatures
`EzExpanded` catches and prevents the following Flutter layout runtime exceptions:
* `"Incorrect use of ParentDataWidget"`
* `"Expanded widgets must be placed inside Flex widgets"`
* `"RenderFlex children have non-zero flex but incoming height constraints are unbounded"`
* `"RenderFlex children have non-zero flex but incoming width constraints are unbounded"`
* `"A RenderFlex overflowed by ... pixels"`

## Technical Solution

`EzExpanded` inspects incoming constraints and ancestor hierarchy defensively:

1. **True Flex Expansion:** Inside a valid, bounded `Row`, `Column`, or `Flex`, `EzExpanded` operates as a native `Expanded` (or `Flexible`), dividing remaining space proportionally according to `flex` factors.
2. **Invalid Parent Protection:** When used outside of a `Flex` widget, it safely renders the child without throwing `ParentDataWidget` assertion errors.
3. **Unbounded Scroll Protection:** When placed inside an unconstrained scrollable (such as `SingleChildScrollView`), it calculates a responsive fallback size (50% of screen height/width via `MediaQuery`/`View`) so the child remains visible.
4. **Debug Diagnostics:** In debug mode, highlights layout issues with a visible red outline border and logs an actionable `FlutterError` identifying the parent culprit (e.g. `SingleChildScrollView`, `RenderStack`).
5. **Silent Release Protection:** In release mode, silently applies the fallback layout so end users never experience a crash or red screen.

## Installation

```shell
flutter pub add ez_expanded
```

## Quick Migration

Replace standard `Expanded` with `EzExpanded`:

```diff
- Expanded(
+ EzExpanded(
    child: MyContentWidget(),
  )
```

## Usage Examples

### 1. Safe Inside SingleChildScrollView (Crash Prevention)

In standard Flutter, placing `Expanded` inside a `SingleChildScrollView` throws `"RenderFlex children have non-zero flex but incoming height constraints are unbounded"`. `EzExpanded` prevents the crash:

```dart
SingleChildScrollView(
  child: Column(
    children: [
      const Text('Header'),
      // Does not crash. Renders safely with a red diagnostic outline in debug mode:
      EzExpanded(
        child: Container(
          color: Colors.blue,
          child: const Center(child: Text('Content')),
        ),
      ),
    ],
  ),
)
```

### 2. Normal Bounded Usage (True Flex Expansion)

Inside a bounded `Column` or `Row`, `EzExpanded` provides genuine flex expansion:

```dart
SizedBox(
  height: 300,
  child: Column(
    children: [
      const Text('Fixed Header (50px)'),
      // Expands to fill the remaining 250px
      EzExpanded(
        child: Container(color: Colors.green),
      ),
    ],
  ),
)
```

### 3. Multiple Flex Factors

```dart
Row(
  children: [
    EzExpanded(
      flex: 2,
      child: Container(color: Colors.red),
    ),
    EzExpanded(
      flex: 1,
      child: Container(color: Colors.blue),
    ),
  ],
)
```

### 4. Custom Fallback Dimensions & Telemetry Callback

```dart
EzExpanded(
  fallbackHeight: 250,
  showDebugIndicator: false, // Disables red border in debug mode
  onUnboundedDetected: ({
    required bool isInvalidParent,
    required bool isUnbounded,
    required String? culprit,
  }) {
    // Send diagnostics to your logging or telemetry service
    debugPrint('Layout issue in $culprit: invalidParent=$isInvalidParent, unbounded=$isUnbounded');
  },
  child: Container(color: Colors.teal),
)
```

## Permanent Architectural Resolution

While `EzExpanded` safely handles invalid configurations, recommended structural patterns in Flutter include:

```dart
// Option A: If inside a scroll view, use explicit sizing instead of Expanded
SingleChildScrollView(
  child: Column(
    children: [
      const Text('Header'),
      SizedBox(
        height: 300,
        child: MyContentWidget(),
      ),
    ],
  ),
)

// Option B: If placed outside Flex, wrap in a Column or Row
Column(
  children: [
    EzExpanded(child: MyContentWidget()),
  ],
)
```

## API Reference

| Property | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `child` | `Widget` | *Required* | The widget below this widget in the tree. |
| `flex` | `int` | `1` | The flex factor to use for determining child extent. |
| `fit` | `FlexFit` | `FlexFit.tight` | How the child is inscribed into the available space. |
| `showDebugIndicator` | `bool` | `true` | Shows a red outline border in debug mode when invalid or unbounded. |
| `fallbackWidth` | `double?` | `null` | Explicit fallback width when horizontal dimension is unbounded. |
| `fallbackHeight` | `double?` | `null` | Explicit fallback height when vertical dimension is unbounded. |
| `onUnboundedDetected` | `Function?` | `null` | Diagnostic callback invoked when invalid parent or unbounded constraint is caught. |

## Sponsoring & Support

If this package saved you debugging time, consider supporting ongoing maintenance:
* [GitHub Sponsors](https://github.com/sponsors/Evgenii-Zinner/)
* [Thanks.dev](https://thanks.dev/u/gh/evgenii-zinner)
* [Buy Me a Coffee](https://buymeacoffee.com/evgeniizinner)

## License

MIT License. See [LICENSE](LICENSE) for details.
