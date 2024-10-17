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
  Offset globalDeltaOffset = Offset.infinite;

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
        children: _items.map((e) {
          return DockItem<T>(
            globalDeltaOffset:globalDeltaOffset,
            item: e,
            builder: widget.builder,
            onDrop: onDrop,
            setGlobalDeltaOffset: setGlobalDeltaOffset,
            key: ValueKey(e),
          );
        }).toList(),
      ),
    );
  }

  void onDrop(T itemToReplace, T item) {
    setState(() {
      int index = _items.indexOf(item);
      _items.remove(itemToReplace);
      _items.insert(index, itemToReplace);
    });
  }

  void setGlobalDeltaOffset(Offset offset) {
    setState(() {
      print('_offSet!!!! === $offset');
      globalDeltaOffset = offset;
    });
  }
}

//   List<Widget> buildList() {
//     Offset globalDragPositions = Offset.infinite;
//     final List<Widget> tempListWidgets = [];
//     bool isDragging = false;
//     Offset posTarget = Offset.zero;
//
//
//     for (int i = 0; i < _items.length; i++) {
//       final Widget widgetFromBuilder = widget.builder(_items[i]);
//
//       Draggable finalWidget = Draggable(
//         onDragStarted: (){
//           isDragging = true;
//         },
//         onDragEnd: (_){
//           isDragging = false;
//           globalDragPositions = Offset.infinite;
//         },
//
//         onDragCompleted: () {
//           isDragging = false;
//           globalDragPositions = Offset.infinite;
//         },
//         onDraggableCanceled: (_, __) {
//           isDragging = false;
//           globalDragPositions = Offset.infinite;
//         },
//         dragAnchorStrategy: (Draggable<Object> draggable, BuildContext context,
//             Offset position) {
//           final RenderBox renderObject =
//               context.findRenderObject()! as RenderBox;
//
//           if (renderObject.parentData is BoxParentData &&
//               globalDragPositions == Offset.infinite) {
//             BoxParentData parentData =
//                 renderObject.parentData! as BoxParentData;
//             Offset offSet = parentData.offset;
//
//             print('_offSet!!!! === $offSet');
//             globalDragPositions = offSet;
//             print('_globalDragPositions === $globalDragPositions');
//           }
//           return renderObject.globalToLocal(position);
//         },
//         childWhenDragging: Visibility(
//           visible: false,
//           maintainSize: true,
//           maintainAnimation: true,
//           maintainState: true,
//           child: widgetFromBuilder,
//         ),
//         data: _items[i],
//         feedback: widgetFromBuilder,
//         child: DragTarget<T>(
//           builder: (BuildContext context,  candidateData, rejectedData) {
//             print('injjjjjjj');
//
//             if (candidateData.isNotEmpty) {
//
//
//
// /////sxsxdd
//               if(isDragging){
//                 RenderBox renderBox = context.findRenderObject() as RenderBox;
//
//                 BoxParentData vvv = renderBox.parent?.parentData as BoxParentData;
//                 posTarget = globalDragPositions - vvv.offset;
//
//               }
//
//
//
//
//
//
//
//               // Offset localPosition =
//               //     renderBox.globalToLocal(_globalDragPositions);
//               // print('localPosition == $localPosition');
//               // renderBox.localToGlobal(renderBox.)
//               // renderBox.
//               // return  TweenAnimationBuilder<Offset>(
//               //   curve: Curves.fastLinearToSlowEaseIn ,
//               //     tween: Tween<Offset>(
//               //       begin: Offset.zero,
//               //       end: candidateData.isNotEmpty ? _globalDragPositions : Offset.zero, // Изменяем смещение
//               //     ),
//               //     duration: const Duration(milliseconds: 1300),
//               //     builder: (context, offset, child) {
//
//               // setState(
//               //       () {
//                   int curIndex = _items.indexOf(candidateData.first!);
//                   _items[curIndex] = _items[i];
//                   _items[i] = candidateData.first!;
//               //   },
//               // );
//
//               return Transform.translate(
//                 offset: Offset(posTarget.dx, 0),
//                 child: widgetFromBuilder,
//               );
//             }
//
//             return widgetFromBuilder;
//           },
//           onAcceptWithDetails: (data) {
//             setState(
//               () {
//                 int oldIndex = i;
//                 int curIndex = _items.indexOf(data.data);
//                 T temp = _items[oldIndex];
//                 _items[oldIndex] = _items[curIndex];
//                 _items[curIndex] = temp;
//               },
//             );
//           },
//           onLeave: (data){
//
//             // setState(
//             //
//             //       () {
//             //         // _items[i-1] = data!;
//             //     // int oldIndex = i;
//             //     // int curIndex = _items.indexOf(data!);
//             //     // T temp = _items[oldIndex];
//             //     // _items[oldIndex] = _items[curIndex];
//             //     // _items[curIndex] = temp;
//             //     // int oldIndex = i;
//             //     // int curIndex = _items.indexOf(data!);
//             //     // T temp = _items[oldIndex];
//             //     // _items[oldIndex] = _items[curIndex];
//             //     // _items[curIndex] = temp;
//             //   },
//             // );
//
//             // posTarget = Offset.zero;
//             // setState(() {
//             //
//             // });
//
//             //todo need check
//             if(!isDragging){
//
//               globalDragPositions = Offset.infinite;
//
//             }
//
//           },
//
//         ),
//       );
//
//       tempListWidgets.add(finalWidget);
//     }
//
//     return tempListWidgets;
//   }

class DockItem<T extends Object> extends StatefulWidget {
  const DockItem(
      {required this.item,
      required this.builder,
      required this.onDrop,
      required this.setGlobalDeltaOffset,
      required this.globalDeltaOffset,
      super.key});

  final T item;
  final Widget Function(T) builder;
  final Function(T itemToRemove, T item) onDrop;
  final Function(Offset offset) setGlobalDeltaOffset;
  final Offset globalDeltaOffset;

  @override
  State<DockItem<T>> createState() => _DockItemState<T>();
}

class _DockItemState<T extends Object> extends State<DockItem<T>> {
  bool isDragging = false;
  bool isVisible = true;
  late Widget widgetFromBuilder;
  Offset offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    widgetFromBuilder = widget.builder(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<T>(
      data: widget.item,
      onDragStarted: () {
        isDragging = true;
        isVisible = false;
        setState(() {});
      },
      onDragEnd: (_) {
        isDragging = false;
        isVisible = true;
        // offset = Offset.zero;
        widget.setGlobalDeltaOffset(Offset.infinite);
        // setState(() {
        //
        // });

        // globalDragPositions = Offset.infinite;
      },
      onDragCompleted: () {
        isDragging = false;
        isVisible = true;
        // globalDragPositions = Offset.infinite;
      },
      onDraggableCanceled: (_, __) {
        isDragging = false;
        isVisible = true;
      },
      dragAnchorStrategy:
          (Draggable<Object> draggable, BuildContext context, Offset position) {
        final RenderBox renderObject = context.findRenderObject()! as RenderBox;


          BoxParentData parentData = renderObject.parentData! as BoxParentData;
          Offset offSet = parentData.offset;

          widget.setGlobalDeltaOffset(offSet);

        return renderObject.globalToLocal(position);
      },
      childWhenDragging: Visibility(
        visible: isVisible,
        maintainSize: true,
        maintainAnimation: true,
        maintainState: true,
        child: widgetFromBuilder,
      ),
      feedback: widgetFromBuilder,
      child: DragTarget<T>(
        builder: (BuildContext context, candidateData, rejectedData) {


          if (candidateData.isNotEmpty) {
            var renderBox = context.findRenderObject();
           if (renderBox is RenderBox){
             RenderBox renderBox = context.findRenderObject() as RenderBox;

             BoxParentData vvv = renderBox.parent?.parentData as BoxParentData;


             offset = widget.globalDeltaOffset - vvv.offset;
             if(offset.dx>=0){
               offset = Offset(renderBox.size.width, 0);
             }else{
               offset = Offset(-renderBox.size.width, 0);
             }
             return Transform.translate(
               offset: offset,
               child: widgetFromBuilder,
             );
          }


          }

          if(widget.globalDeltaOffset!=Offset.infinite){
            var  offset1;
            var renderBox = context.findRenderObject();
            if (renderBox is RenderBox){
            RenderBox renderBox = context.findRenderObject() as RenderBox;

            BoxParentData vvv = renderBox.parent?.parentData as BoxParentData;
            offset1 = widget.globalDeltaOffset - vvv.offset;

            if(offset1.dx>=0&&offset1.dx<70){
              offset1 = Offset(-renderBox.size.width, 0);
            }else if(offset1.dx<0 && offset1.dx>-70){
              offset1 = Offset(renderBox.size.width, 0);
            }else{
              offset1 = offset;
            }

            return Transform.translate(
              offset: offset1,
              child: widgetFromBuilder,
            );}
          }


          return widgetFromBuilder;
        },
        onAcceptWithDetails: (data) {
          widget.onDrop(data.data, widget.item);
        },
        onLeave: (data) {
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
          RenderBox renderBox = context.findRenderObject() as RenderBox;

          BoxParentData vvv = renderBox.parent?.parentData as BoxParentData;
          offset = widget.globalDeltaOffset;
          // if(offset.dx>=0){
          //   offset = Offset(renderBox.size.width, 0);
          // }else{
          //   offset = Offset(-renderBox.size.width, 0);
          // }
          // setState(() {
          //
          // });

          //todo need check
        },
      ),
    );
  }
}
