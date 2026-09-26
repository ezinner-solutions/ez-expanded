import 'package:ez_expanded/ez_expanded.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EzExpanded', () {
    testWidgets('expands naturally inside bounded Column', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              width: 200,
              child: Column(
                children: [
                  SizedBox(height: 100),
                  EzExpanded(
                    child: KeyedSubtree(
                      key: Key('expanded_child'),
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);

      final size = tester.getSize(find.byKey(const Key('expanded_child')));
      expect(size.height, 200.0);
      expect(size.width, 200.0);
    });

    testWidgets('respects flex factor inside bounded Row', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              width: 300,
              child: Row(
                children: [
                  EzExpanded(
                    flex: 2,
                    child: KeyedSubtree(
                      key: Key('first_child'),
                      child: SizedBox.expand(),
                    ),
                  ),
                  EzExpanded(
                    flex: 1,
                    child: KeyedSubtree(
                      key: Key('second_child'),
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);

      final firstSize = tester.getSize(find.byKey(const Key('first_child')));
      final secondSize = tester.getSize(find.byKey(const Key('second_child')));

      expect(firstSize.width, 200.0);
      expect(secondSize.width, 100.0);
    });

    testWidgets(
        'prevents crash inside SingleChildScrollView -> Column (Unbounded)',
        (tester) async {
      bool detectedUnbounded = false;
      String? detectedCulprit;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const Text('Header'),
                  EzExpanded(
                    onUnboundedDetected: ({
                      required bool isInvalidParent,
                      required bool isUnbounded,
                      required String? culprit,
                    }) {
                      detectedUnbounded = isUnbounded;
                      detectedCulprit = culprit;
                    },
                    child: const Text('Child in unbounded column'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // In Flutter, normal Expanded crashes with fatal layout exception here.
      // EzExpanded reports structured diagnostic error and renders fallback.
      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
      expect(detectedUnbounded, isTrue);
      expect(detectedCulprit, 'SingleChildScrollView');
      expect(find.text('Child in unbounded column'), findsOneWidget);
    });

    testWidgets('prevents crash when placed outside Flex (Invalid Parent)',
        (tester) async {
      bool detectedInvalidParent = false;
      String? detectedCulprit;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                EzExpanded(
                  onUnboundedDetected: ({
                    required bool isInvalidParent,
                    required bool isUnbounded,
                    required String? culprit,
                  }) {
                    detectedInvalidParent = isInvalidParent;
                    detectedCulprit = culprit;
                  },
                  child: const Text('Child in Stack'),
                ),
              ],
            ),
          ),
        ),
      );

      // In Flutter, normal Expanded throws ParentDataWidget assertion error here.
      // EzExpanded catches it and safely renders the child.
      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isTrue);
      expect(detectedInvalidParent, isTrue);
      expect(detectedCulprit, 'RenderStack');
      expect(find.text('Child in Stack'), findsOneWidget);
    });

    testWidgets('respects showDebugIndicator: false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  EzExpanded(
                    showDebugIndicator: false,
                    child: Text('No border'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      expect(_hasRedBorder(tester), isFalse);
    });

    testWidgets('respects custom fallbackHeight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  EzExpanded(
                    fallbackHeight: 185.0,
                    child: KeyedSubtree(
                      key: Key('custom_height_child'),
                      child: SizedBox.expand(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
      final size = tester.getSize(find.byKey(const Key('custom_height_child')));
      expect(size.height, 185.0);
    });

    testWidgets(
        'renders normally inside SizedBox bounded child of SingleChildScrollView',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: 400,
                width: 300,
                child: Column(
                  children: [
                    SizedBox(height: 150),
                    EzExpanded(
                      child: KeyedSubtree(
                        key: Key('nested_bounded_child'),
                        child: SizedBox.expand(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(_hasRedBorder(tester), isFalse);

      final size =
          tester.getSize(find.byKey(const Key('nested_bounded_child')));
      expect(size.height, 250.0);
    });
  });
}

bool _hasRedBorder(WidgetTester tester) {
  final containers = tester.widgetList<Container>(find.byType(Container));
  for (final c in containers) {
    if (c.decoration is BoxDecoration) {
      final box = c.decoration as BoxDecoration;
      if (box.border is Border) {
        final b = box.border as Border;
        if (b.top.color == Colors.red) return true;
      }
    }
  }
  return false;
}
