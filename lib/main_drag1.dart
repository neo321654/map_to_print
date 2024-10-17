import 'package:flutter/material.dart';

class TransitionExample extends StatefulWidget {
  @override
  _TransitionExampleState createState() => _TransitionExampleState();
}

class _TransitionExampleState extends State<TransitionExample> with SingleTickerProviderStateMixin {
  List<String> _items = ["Item 1", "Item 2", "Item 3"];
  late AnimationController _controller;
  String? _currentItem;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  void onDrop(String itemToReplace, String newItem) {
    setState(() {
      int index = _items.indexOf(itemToReplace);
      if (index != -1) {
        _currentItem = itemToReplace; // Сохраняем текущий элемент для анимации
        Future.delayed(Duration(milliseconds: 300), () {
          setState(() {
            _items[index] = newItem; // Заменяем элемент
            _currentItem = null; // Сбрасываем текущий элемент
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Не забывайте освобождать ресурсы
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transition Example")),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, 1.0), // Начальная позиция (снизу)
                end: Offset.zero, // Конечная позиция (по центру)
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Curves.easeInOut,
              )),
              child: ListTile(
                key: ValueKey<String>(_items[index]), // Уникальный ключ для анимации
                title: Text(_items[index]),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Пример замены элемента
          onDrop("Item 2", "New Item");
        },
        child: Icon(Icons.swap_horiz),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: TransitionExample()));