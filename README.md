# EZ Expanded

A **defensive, self-aware** widget that provides flex-based expansion behavior while safely handling unbounded constraints.

## 🛑 The Problem

Developers often want widgets to "fill available space" in layouts. Flutter's `Expanded` widget provides this for `Row` and `Column`, but it has strict requirements:
*   **Must be inside Flex:** Using `Expanded` outside of `Row`, `Column`, or `Flex` causes a crash:
    > "Incorrect use of ParentDataWidget. Expanded widgets must be placed inside Flex widgets."
*   **Unbounded Constraints:** Even when used correctly inside Flex, if the Flex itself has unbounded constraints, the layout can still break.

## ✅ The EZ Solution

`EzExpanded` follows the same defensive pattern as `EzListView`, `EzGridView`, and `EzCustomScrollView`:

*   **Auto-Detection:** Uses `LayoutBuilder` to detect unbounded constraints (infinite width/height).
*   **Crash Prevention:** Automatically applies a safe, bounded size (50% of screen) to ensure the widget renders instead of breaking.
*   **Developer Feedback:**
    *   **Debug Mode:** Displays a **red border** and logs a clear warning identifying the exact parent causing the issue.
    *   **Release Mode:** Silently fixes the layout so your users never see a broken screen.
*   **Flex Behavior:** When constraints are bounded, uses `Flexible` with `FlexFit.tight` to provide the same expansion behavior as `Expanded`.

## ✨ Features

*   **Drop-in Replacement:** Provides flex-based expansion when possible.
*   **Omni-Directional Safety:** Handles both unbounded height and width.
*   **Works Anywhere:** Compatible with any widget context, not just Flex widgets.
*   **Zero Dependencies:** Lightweight and pure Flutter.

## 📦 Installation

```shell
flutter pub add ez_expanded
```

## 🚀 Usage

### Basic (Safe with Unbounded Constraints)
This would normally crash or cause layout errors, but EzExpanded handles it safely:
```dart
Column(
  children: [
    Text('Header'),
    EzExpanded(
      child: Container(
        color: Colors.blue,
        child: Center(child: Text('Fills Space')),
      ),
    ),
  ],
)
```

### Correct Usage (With Bounded Constraints)
When used in a properly constrained context, it behaves like `Expanded`:
```dart
SizedBox(
  height: 400,
  child: Column(
    children: [
      Text('Header'),
      EzExpanded(
        child: Container(
          color: Colors.green,
          child: Center(child: Text('Expands to Fill')),
        ),
      ),
    ],
  ),
)
```

### With Flex Factor
Control the expansion ratio just like `Expanded`:
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

## 🤝 Contributing

Contributions are welcome! Please feel free to open an issue or submit a pull request on [GitHub](https://github.com/Evgenii-Zinner/ez-expanded).

## 📜 License

MIT License - see the [LICENSE](LICENSE) file for details.
