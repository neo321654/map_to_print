import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Positioned Transition Demo',
      home: const PositionedTransitionWidget(),
    );
  }
}

class PositionedTransitionWidget extends StatefulWidget {
  const PositionedTransitionWidget({super.key});

  @override
  _PositionedTransitionWidgetState createState() => _PositionedTransitionWidgetState();
}

class _PositionedTransitionWidgetState extends State<PositionedTransitionWidget> {
  bool _isMoved = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Positioned Transition Sample')),
      body: Center(
        child: Stack(
          children: [
            TweenAnimationBuilder<Offset>(
              tween: Tween<Offset>(
                begin: Offset(0.0, 0.0), // Начальная позиция
                end: _isMoved ? Offset(1.0, 1.0) : Offset(0.0, 0.0), // Конечная позиция
              ),
              duration: const Duration(seconds: 1),
              builder: (context, offset, child) {
                return Transform.translate(
                  offset: Offset(offset.dx * 200, offset.dy * 200), // Умножаем на 200 для перемещения
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.blue,
                    alignment: Alignment.center,
                    child: const Text('Slide Me', style: TextStyle(color: Colors.white)),
                  ),
                );
              },
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isMoved = !_isMoved; // Переключаем состояние перемещения
                    });
                  },
                  child: const Text('Toggle Position'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}