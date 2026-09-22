import 'package:flutter/material.dart';

/// Activity 1 — Container screen with a TabBar
/// holding the Counter and the Color Picker.
class ActivityOneScreen extends StatelessWidget {
  const ActivityOneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity 1 — Counter & Color Picker'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.exposure_plus_1), text: 'Counter'),
              Tab(icon: Icon(Icons.palette_outlined), text: 'Color Picker'),
            ],
          ),
        ),
        body: const TabBarView(children: [_CounterTab(), _ColorPickerTab()]),
      ),
    );
  }
}

// ============================================================
// Tab 1: Counter (moved from the old ActivityOneScreen)
// ============================================================
class _CounterTab extends StatefulWidget {
  const _CounterTab();

  @override
  State<_CounterTab> createState() => _CounterTabState();
}

class _CounterTabState extends State<_CounterTab>
    with AutomaticKeepAliveClientMixin {
  int _count = 0;

  @override
  bool get wantKeepAlive => true; // keeps state when switching tabs

  void _increment() => setState(() => _count++);
  void _decrement() => setState(() => _count--);
  void _reset() => setState(() => _count = 0);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have tapped:'),
              const SizedBox(height: 12),
              Text(
                '$_count',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _decrement,
                      icon: const Icon(Icons.remove),
                      label: const Text('Minus'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _increment,
                      icon: const Icon(Icons.add),
                      label: const Text('Plus'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Reset'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Tab 2: Color Picker (moved from the old ActivityTwoScreen)
// ============================================================
class _ColorPickerTab extends StatefulWidget {
  const _ColorPickerTab();

  @override
  State<_ColorPickerTab> createState() => _ColorPickerTabState();
}

class _ColorPickerTabState extends State<_ColorPickerTab>
    with AutomaticKeepAliveClientMixin {
  Color _selected = Colors.deepOrange;
  final List<Color> _palette = const [
    Colors.deepOrange,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.amber,
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          final preview = AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: isWide ? 260 : 180,
            decoration: BoxDecoration(
              color: _selected,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Center(
              child: Text(
                'Preview',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          );

          final grid = Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _palette.map((c) {
              final selected = c == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = c),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.black87, width: 3)
                        : null,
                  ),
                ),
              );
            }).toList(),
          );

          return Padding(
            padding: const EdgeInsets.all(20),
            child: isWide
                ? Row(
                    children: [
                      Expanded(child: preview),
                      const SizedBox(width: 20),
                      Expanded(child: SingleChildScrollView(child: grid)),
                    ],
                  )
                : Column(children: [preview, const SizedBox(height: 24), grid]),
          );
        },
      ),
    );
  }
}
