# EzExpanded

A defensive, self-aware drop-in replacement for Flutter's `Expanded` that provides true flex-based expansion inside bounded `Row`, `Column`, and `Flex` widgets, while preventing layout crashes from unbounded constraints or invalid parent widget hierarchy.

## 🛑 The Problem

In Flutter, using `Expanded` can easily trigger fatal runtime exceptions:

1. **Invalid Parent Widget:** Using `Expanded` outside of a `Row`, `Column`, or `Flex` (e.g. inside `Stack`, `Container`, or directly in `Scaffold`) crashes immediately:
   > "Incorrect use of ParentDataWidget. Expanded widgets must be placed inside Flex widgets."
2. **Unbounded Flex Container:** Using `Expanded` inside a `Column` or `Row` nested within a scroll view (`SingleChildScrollView`, `ListView`, etc.) crashes with:
   > "RenderFlex children have non-zero flex but incoming height/width constraints are unbounded."

Instead of a graceful degradation or actionable guidance, the screen turns red and the build fails.

## ✅ The EzExpanded Solution

`EzExpanded` intercepts both error scenarios defensively:

* **True Flex Expansion:** When placed inside a valid, bounded `Row`, `Column`, or `Flex`, it behaves as a native `Expanded` (or `Flexible`), accurately dividing available space according to `flex` factors.
* **Invalid Parent Protection:** Detects if placed outside a `Flex` and safely renders the child without throwing `ParentDataWidget` errors.
* **Unbounded Scroll Protection:** Detects if the enclosing `Flex` is inside an unconstrained scrollable and applies a sensible, responsive fallback size (50% screen height/width or custom dimensions).
* **Developer Diagnostics (Debug Mode):** Highlights problematic usage with a red border and reports a detailed `FlutterError` diagnosing the exact parent culprit (e.g. `SingleChildScrollView`, `RenderStack`).
* **Silent Fix (Release Mode):** Automatically applies the fallback layout so your users never see a crash or red screen.

## 📦 Installation

```shell
flutter pub add ez_expanded
```

## 🚀 Usage

### 1. Safe Inside SingleChildScrollView (Crash Prevention)

Standard `Expanded` crashes here. `EzExpanded` safely renders a fallback and warns you in debug mode:

```dart
SingleChildScrollView(
  child: Column(
    children: [
      const Text('Header'),
      // Won't crash! Safely sized with a debug outline.
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
      const Text('Fixed Header'),
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

### 4. Custom Fallback & Telemetry

```dart
EzExpanded(
  fallbackHeight: 250,
  showDebugIndicator: false, // Disables red border in debug mode
  onUnboundedDetected: ({
    required bool isInvalidParent,
    required bool isUnbounded,
    required String? culprit,
  }) {
    print('Layout issue in $culprit: invalidParent=$isInvalidParent, unbounded=$isUnbounded');
  },
  child: Container(color: Colors.teal),
)
```

## 🤝 Contributing

Contributions, issues, and feature suggestions are always welcome! Check out the [GitHub repository](https://github.com/Evgenii-Zinner/ez-expanded).

## 📜 License

MIT License - see [LICENSE](LICENSE) for details.
