import 'dart:math';
import 'package:flutter/material.dart';
import 'package:roulette/roulette.dart';
import 'arrow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roulette',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class MyRoulette extends StatelessWidget {
  const MyRoulette({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final RouletteController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Roulette(
              controller: controller,
              style: const RouletteStyle(
                dividerThickness: 0.0,
                dividerColor: Colors.black,
                centerStickSizePercent: 0.05,
                centerStickerColor: Colors.black,
              ),
            ),
          ),
        ),
        const Arrow(),
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  static final _random = Random();

  late RouletteController _controller;
  final ValueNotifier<String> _resultNotifier = ValueNotifier<String>('');
  bool _clockwise = true;

  final colors = <Color>[
    Colors.red.withAlpha(50),
    Colors.green.withAlpha(30),
    Colors.blue.withAlpha(70),
    Colors.yellow.withAlpha(90),
    Colors.amber.withAlpha(50),
    Colors.indigo.withAlpha(70),
  ];

  final texts = <String>[
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4',
    'Option 5',
    'Option 6',
  ];

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    assert(colors.length == texts.length);

    _controller = RouletteController(
      vsync: this,
      group: RouletteGroup.uniform(
        colors.length,
        colorBuilder: (index) => colors[index],
        textBuilder: (index) => texts[index],
        textStyleBuilder: (index) {
          return const TextStyle(color: Colors.black);
        },
      ),
    );
  }

  void _addText(String text) {
    setState(() {
      texts.add(text);
      colors.add(_generateRandomColor());
      _controller = RouletteController(
        vsync: this,
        group: RouletteGroup.uniform(
          texts.length,
          colorBuilder: (index) => colors[index],
          textBuilder: (index) => texts[index],
          textStyleBuilder: (index) {
            return const TextStyle(color: Colors.black);
          },
        ),
      );
    });
  }

  Color _generateRandomColor() {
    return Color.fromARGB(
      50 + _random.nextInt(206),
      _random.nextInt(256),
      _random.nextInt(256),
      _random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roulette'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "방향 바꾸기",
                    style: TextStyle(fontSize: 18),
                  ),
                  Switch(
                    value: _clockwise,
                    onChanged: (onChanged) {
                      setState(() {
                        _controller.resetAnimation();
                        _clockwise = !_clockwise;
                      });
                    },
                  ),
                ],
              ),
              MyRoulette(controller: _controller),
              const SizedBox(height: 20),
              ValueListenableBuilder<String>(
                valueListenable: _resultNotifier,
                builder: (context, value, child) {
                  return Text(
                    value.isEmpty ? '~룰렛돌리기~' : 'Result: $value',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  );
                },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Add Text',
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_textController.text.isNotEmpty) {
                    _addText(_textController.text);
                    _textController.clear();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.pink.withOpacity(0.1),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Use the controller to run the animation with rollTo method
        onPressed: () => _controller.rollTo(
          _random.nextInt(texts.length),
          clockwise: _clockwise,
          offset: _random.nextDouble(),
        ),
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }
}
