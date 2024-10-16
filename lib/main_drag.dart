import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
    Offset globalDragPositions = Offset.infinite;
    final List<Widget> tempListWidgets = [];
    bool isDragging = false;
    Offset posTarget = Offset.zero;


    for (int i = 0; i < _items.length; i++) {
      final Widget widgetFromBuilder = widget.builder(_items[i]);

      Draggable finalWidget = Draggable(
        onDragStarted: (){
          isDragging = true;
        },
        onDragEnd: (_){
          isDragging = false;
          globalDragPositions = Offset.infinite;
        },

        onDragCompleted: () {
          isDragging = false;
          globalDragPositions = Offset.infinite;
        },
        onDraggableCanceled: (_, __) {
          isDragging = false;
          globalDragPositions = Offset.infinite;
        },
        dragAnchorStrategy: (Draggable<Object> draggable, BuildContext context,
            Offset position) {
          final RenderBox renderObject =
              context.findRenderObject()! as RenderBox;

          if (renderObject.parentData is BoxParentData &&
              globalDragPositions == Offset.infinite) {
            BoxParentData parentData =
                renderObject.parentData! as BoxParentData;
            Offset offSet = parentData.offset;

            print('_offSet!!!! === $offSet');
            globalDragPositions = offSet;
            print('_globalDragPositions === $globalDragPositions');
          }
          return renderObject.globalToLocal(position);
        },
        childWhenDragging: Visibility(
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: widgetFromBuilder,
        ),
        data: _items[i],
        feedback: widgetFromBuilder,
        child: DragTarget<T>(
          builder: (BuildContext context, candidateData, rejectedData) {
            if (candidateData.isNotEmpty) {

              if(isDragging){
                RenderBox renderBox = context.findRenderObject() as RenderBox;

                BoxParentData vvv = renderBox.parent?.parentData as BoxParentData;
                posTarget = globalDragPositions - vvv.offset;

              }







              // Offset localPosition =
              //     renderBox.globalToLocal(_globalDragPositions);
              // print('localPosition == $localPosition');
              // renderBox.localToGlobal(renderBox.)
              // renderBox.
              // return  TweenAnimationBuilder<Offset>(
              //   curve: Curves.fastLinearToSlowEaseIn ,
              //     tween: Tween<Offset>(
              //       begin: Offset.zero,
              //       end: candidateData.isNotEmpty ? _globalDragPositions : Offset.zero, // Изменяем смещение
              //     ),
              //     duration: const Duration(milliseconds: 1300),
              //     builder: (context, offset, child) {

              // setState(
              //       () {
                  int curIndex = _items.indexOf(candidateData.first!);
                  _items[curIndex] = _items[i];
                  _items[i] = candidateData.first!;
              //   },
              // );

              return Transform.translate(
                offset: Offset(posTarget.dx, 0),
                child: widgetFromBuilder,
              );
            }

            return widgetFromBuilder;
          },
          onAcceptWithDetails: (data) {
            setState(
              () {
                int oldIndex = i;
                int curIndex = _items.indexOf(data.data);
                T temp = _items[oldIndex];
                _items[oldIndex] = _items[curIndex];
                _items[curIndex] = temp;
              },
            );
          },
          onLeave: (data){

            // setState(
            //
            //       () {
            //         // _items[i-1] = data!;
            //     // int oldIndex = i;
            //     // int curIndex = _items.indexOf(data!);
            //     // T temp = _items[oldIndex];
            //     // _items[oldIndex] = _items[curIndex];
            //     // _items[curIndex] = temp;
            //     // int oldIndex = i;
            //     // int curIndex = _items.indexOf(data!);
            //     // T temp = _items[oldIndex];
            //     // _items[oldIndex] = _items[curIndex];
            //     // _items[curIndex] = temp;
            //   },
            // );

            // posTarget = Offset.zero;
            // setState(() {
            //
            // });

            //todo need check
            if(!isDragging){

              globalDragPositions = Offset.infinite;

            }

          },

        ),
      );

      tempListWidgets.add(finalWidget);
    }

    return tempListWidgets;
  }
}

class DockListWidgets extends StatelessWidget {
  const DockListWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
