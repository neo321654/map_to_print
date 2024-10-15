import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Move Widget Demo',
      home: const MoveWidgetExample(),
    );
  }
}

class MoveWidgetExample extends StatefulWidget {
  const MoveWidgetExample({super.key});

  @override
  _MoveWidgetExampleState createState() => _MoveWidgetExampleState();
}

class _MoveWidgetExampleState extends State<MoveWidgetExample> {
  bool _isMoved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Move Widget Example')),
      body: Center(
        child: Row(
          children: [
            Container(width: 50, height: 50, color: Colors.red),
            Container(width: 50, height: 50, color: Colors.green),
            TweenAnimationBuilder<Offset>(
              tween: Tween<Offset>(
                begin: Offset.zero,
                end: _isMoved ? Offset(0.1, 0.4) : Offset.zero, // Изменяем смещение
              ),
              duration: const Duration(milliseconds: 300),
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: Offset(offset.dx * 300, 0), // Умножаем на 300 для перемещения
                  child: Container(
                    width: 50,
                    height: 50,
                    color: Colors.blue,
                  ),
                );
              },
            ),
            Container(width: 50, height: 50, color: Colors.yellow),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isMoved = !_isMoved; // Переключаем состояние перемещения
          });
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}