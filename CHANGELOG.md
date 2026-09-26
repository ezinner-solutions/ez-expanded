## 0.0.2

* **Feat:** Native `Flexible` / `Expanded` support when placed inside a valid, bounded `Row`, `Column`, or `Flex`.
* **Feat:** Defensive invalid parent detection preventing `"Incorrect use of ParentDataWidget"` crashes when used outside `Flex`.
* **Feat:** Defensive unbounded scroll view detection preventing `"RenderFlex children have non-zero flex but incoming constraints are unbounded"` crashes.
* **Feat:** Added `showDebugIndicator` toggle, `fallbackHeight`, and `fallbackWidth` overrides.
* **Feat:** Added `onUnboundedDetected` diagnostic callback.
* **Tests:** Added comprehensive test suite with 7 passing tests covering bounded flex ratios, scroll fallbacks, and invalid parents.

## 0.0.1

* Initial release
* Defensive wrapper providing flex-based expansion behavior
* Auto-detects unbounded constraints
* Debug mode visual feedback with red border
* Release mode silent fix
* Omni-directional safety (handles both width and height)
