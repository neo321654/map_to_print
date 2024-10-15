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
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  List<Widget> _tempList = [];
  late List<T> _tempItems;
  Size _sizeSizedBox = const Size(0, 0);

  @override
  void initState() {
    super.initState();
    _tempItems = _items;
  }

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
        children: buildList(context),
      ),
    );
  }

  List<Widget> buildList(BuildContext context) {
    // var _tempList = _items.map(widget.builder).toList();

    // var _tempList  = [];

    _tempList;

    print('before $_tempList');

    _tempList = _tempItems.map((e) {
      Widget wid = widget.builder(e);

      return Draggable<T>(
        onDragUpdate: (details) {},
        dragAnchorStrategy: (Draggable<Object> draggable, BuildContext context,
            Offset position) {
          final RenderBox renderObject =
              context.findRenderObject()! as RenderBox;
          _sizeSizedBox = renderObject.size;

          return renderObject.globalToLocal(position);
        },

        onDragEnd: (DraggableDetails details) {},
        onDragStarted: () {
          print('onDragStarted');
        },
        // feedbackOffset: Offset(22, 33),
        key: ValueKey(e),
        // childWhenDragging:widget.builder(e) ,
        childWhenDragging:
            // SizedBox(width: _sizeSizedBox.width, height: _sizeSizedBox.height,),
            Visibility(
          child: wid,
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
        ),
        data: e,
        feedback: wid,
        child: DragTarget<T>(
          builder: (BuildContext context, candidateData, rejectedData) {
            candidateData;

            if (candidateData.isNotEmpty) {
              return Center(
                child: Align(child: wid, alignment: Alignment.topRight),
              );
            }

            return wid;
          },
          onAcceptWithDetails: (data) {
            //   var d = data;

            setState(() {
              int oldIndex = _tempItems.indexOf(e);
              // Меняем местами иконки
              var curIndex = _tempItems.indexOf(data.data);

              // _tempItems.shuffle();

              var temp = _tempItems[oldIndex];

              _tempItems[oldIndex] = _tempItems[curIndex];
              _tempItems[curIndex] = temp;

              // _tempList=_tempList..shuffle();
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
