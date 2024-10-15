import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock<IconData>(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: buildList(),
      ),
    );
  }

  List<Widget> buildList() {
    var _tempList = _items.map(widget.builder).toList();


    _tempList = _tempList.map((e) {
      return Draggable<Widget>(
        data: e,

        feedback: e,
        child: DragTarget<Widget>(
            builder: (BuildContext context,candidateData,
              rejectedData) {
              return e;
            },
          onAcceptWithDetails: (data) {
            //   var d = data;

            setState(() {
              int oldIndex = _tempList.indexOf(data.data);
              // Меняем местами иконки
              var curIndex = _tempList.indexOf(e);
              var temp = _tempList[oldIndex];
              _tempList[oldIndex] = _tempList[curIndex];
              _tempList[curIndex] = temp;
            });
          },
        ),
      );
    }).toList();

    return _tempList;
  }
}