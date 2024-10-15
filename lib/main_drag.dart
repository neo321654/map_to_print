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
            key: UniqueKey(),

            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {

              return Container(
                key: UniqueKey(),


                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(                key: UniqueKey(),
                    child: Icon(                key: UniqueKey(),
                        e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
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
  State<Dock<T >> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  List<Widget> _tempList = [];
  late List<T> _tempItems;

  @override
  void initState() {
    super.initState();
    _tempItems =_items;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      key: UniqueKey(),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        key: UniqueKey(),

        mainAxisSize: MainAxisSize.min,
        children: buildList(),
      ),
    );
  }

  List<Widget> buildList() {
    // var _tempList = _items.map(widget.builder).toList();

    // var _tempList  = [];

    _tempList;

    print('before $_tempList');

    _tempList = _tempItems.map((e) {
      return Draggable<T>(
        key: UniqueKey(),

        data: e,

        feedback: widget.builder(e),
        child: DragTarget<T>(
          key: UniqueKey(),

          builder: (BuildContext context,candidateData,
              rejectedData) {
              return widget.builder(e);
            },
          onAcceptWithDetails: (data) {
            //   var d = data;

            setState(() {
              int oldIndex = _tempItems.indexOf(e);
              // Меняем местами иконки
              var curIndex = _tempItems.indexOf(data.data);

              _tempItems.shuffle();

              var temp = _tempList[oldIndex];

              _tempList[oldIndex] = _tempList[curIndex];
              _tempList[curIndex] = temp;
              _tempList=_tempList..shuffle();


            });
          },
        ),
      );
    }).toList();

    _tempList;
    print('after $_tempList');

    return _tempList;
  }
}
