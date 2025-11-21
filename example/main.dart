import 'package:ez_expanded/ez_expanded.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EZ Expanded Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'EZ Expanded Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Safe with Unbounded Height',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'EzExpanded detects unbounded constraints and applies a safe fallback.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                const Text('Header'),
                EzExpanded(
                  child: Container(
                    color: Colors.blue.shade200,
                    child: const Center(
                      child: Text('Safe Expansion'),
                    ),
                  ),
                ),
                const Text('Footer'),
              ],
            ),
            const Divider(height: 32),
            const Text(
              '2. Correct Usage (Bounded Constraints)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'When constraints are bounded, it behaves like Expanded.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: Column(
                children: [
                  const Text('Header'),
                  EzExpanded(
                    child: Container(
                      color: Colors.green.shade200,
                      child: const Center(
                        child: Text('Proper Expansion'),
                      ),
                    ),
                  ),
                  const Text('Footer'),
                ],
              ),
            ),
            const Divider(height: 32),
            const Text(
              '3. With Flex Factor',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Control expansion ratio with flex parameter.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  EzExpanded(
                    flex: 2,
                    child: Container(
                      color: Colors.red.shade200,
                      child: const Center(child: Text('Flex: 2')),
                    ),
                  ),
                  EzExpanded(
                    flex: 1,
                    child: Container(
                      color: Colors.amber.shade200,
                      child: const Center(child: Text('Flex: 1')),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            const Text(
              '4. Horizontal Unbounded (Safe)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Also handles unbounded width constraints.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: Row(
                children: [
                  const Text('Label:'),
                  EzExpanded(
                    child: Container(
                      color: Colors.purple.shade200,
                      child: const Center(child: Text('Safe Width')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
