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


  Offset _globalDragPositions = Offset.zero;


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

    final List<Widget> tempList = [];



    for (int i = 0; i < _items.length; i++) {
      Widget widgetFromBuilder = widget.builder(_items[i]);

      Draggable<T> finalWidget = Draggable(
        onDragCompleted: () {
          _globalDragPositions = Offset.zero;
        },
        onDraggableCanceled: (_,__){
          _globalDragPositions = Offset.zero;
        },
        dragAnchorStrategy: (Draggable<Object> draggable, BuildContext context,
            Offset position) {

          final RenderBox renderObject =
          context.findRenderObject()! as RenderBox;


          if (renderObject.parentData is BoxParentData && _globalDragPositions == Offset.zero)  {


              BoxParentData parentData = renderObject
                  .parentData! as BoxParentData;
              Offset offSet = parentData.offset;

              print('_offSet!!!! === $offSet');
              // _globalDragPositions = renderObject.localToGlobal(_offSet);
              _globalDragPositions = offSet;

              print('_globalDragPositions === $_globalDragPositions');

          }
          // print(runtimeType(  ));

          //print(renderObject.parentData) ;

          Offset xxx = renderObject.globalToLocal(position);

          return xxx;
        },

        onDragEnd: (DraggableDetails details) {},
        onDragStarted: () {
          RenderBox rb = context.findRenderObject() as RenderBox;

          // print('onDragStarted');
        },
        // feedbackOffset: Offset(22, 33),
        // childWhenDragging:widget.builder(e) ,
        childWhenDragging:
        // SizedBox(width: _sizeSizedBox.width, height: _sizeSizedBox.height,),
        Visibility(
          child: widgetFromBuilder,
          visible: false,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
        ),
        data: _items[i],
        feedback: widgetFromBuilder,
        child: DragTarget<T>(
          // onMove: (details){
          //   details;
          //
          // },
          builder: (BuildContext context, candidateData, rejectedData) {
            candidateData;

            // if (candidateData.isNotEmpty) {
            //   return Align(child: wid, alignment: Alignment.topRight);
            // }
            if (candidateData.isNotEmpty) {
              _globalDragPositions;

              RenderBox renderBox = context.findRenderObject() as RenderBox;

              BoxParentData vvv = renderBox.parent?.parentData as BoxParentData;
              _globalDragPositions = _globalDragPositions - vvv.offset;
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
              return Transform.translate(
                // transformHitTests: false,
                // offset: Offset(offset.dx, 0),
                offset: Offset(_globalDragPositions.dx, 0),
                child: widgetFromBuilder,
              );
              //   }
              // );
              // offset: Offset( 60, 0),child:wid,);
            }

            return widgetFromBuilder;
          },
          onAcceptWithDetails: (data) {
            //   var d = data;

            setState(() {
              int oldIndex = i;
              // Меняем местами иконки
              int curIndex = _items.indexOf(data.data);

               T temp = _items[oldIndex];

              _items[oldIndex] = _items[curIndex];
              _items[curIndex] = temp;

              // _tempList=_tempList..shuffle();
            });
          },
        ),
      );

      tempList.add(finalWidget);
    }


    // _tempList = _tempItems.map((e) {
    //
    // // _tempItems.forEach((element)async {
    // //   // Действия с элементом
    // // });
    //
    // Widget widgetFromBuilder = widget.builder(e);
    //
    // return Draggable<T>(
    //
    // onDragCompleted: () {
    // _globalDragPositions = Offset.zero;
    // //todo check need or not
    // // setState(() {
    // //
    // // });
    // },
    // onDragUpdate: (details) {},
    //
    // // dragAnchorStrategy:pointerDragAnchorStrategy,
    // //  dragAnchorStrategy: childDragAnchorStrategy,
    // //   final RenderBox renderObject = context.findRenderObject()! as RenderBox;
    // // return renderObject.globalToLocal(position);
    // dragAnchorStrategy: (Draggable<Object> draggable, BuildContext context,
    // Offset position) {
    //
    // final RenderBox renderObject =
    // context.findRenderObject()! as RenderBox;
    //
    // Offset _offSet = Offset(0, 0);
    //
    // if(renderObject.parentData is BoxParentData){
    // BoxParentData parentData = renderObject.parentData! as BoxParentData;
    // _offSet = parentData.offset;
    //
    // print('_offSet!!!! === $_offSet') ;
    //
    // if (_globalDragPositions == Offset.zero){
    // // _globalDragPositions = renderObject.localToGlobal(_offSet);
    // _globalDragPositions = _offSet;
    //
    // print('_globalDragPositions === $_globalDragPositions') ;
    // }
    //
    // }
    // // print(runtimeType(  ));
    //
    // //print(renderObject.parentData) ;
    //
    // Offset xxx =renderObject.globalToLocal(position);
    //
    // return xxx;
    //
    // },
    //
    // onDragEnd: (DraggableDetails details) {},
    // onDragStarted: () {
    // RenderBox rb = context.findRenderObject() as RenderBox;
    //
    // // print('onDragStarted');
    // },
    // // feedbackOffset: Offset(22, 33),
    // // childWhenDragging:widget.builder(e) ,
    // childWhenDragging:
    // // SizedBox(width: _sizeSizedBox.width, height: _sizeSizedBox.height,),
    // Visibility(
    // child: widgetFromBuilder,
    // visible: false,
    // maintainSize: true,
    // maintainAnimation: true,
    // maintainState: true,
    // ),
    // data: e,
    // feedback: widgetFromBuilder,
    // child: DragTarget<T>(
    // // onMove: (details){
    // //   details;
    // //
    // // },
    // builder: (BuildContext context, candidateData, rejectedData) {
    // candidateData;
    //
    // // if (candidateData.isNotEmpty) {
    // //   return Align(child: wid, alignment: Alignment.topRight);
    // // }
    // if (candidateData.isNotEmpty) {
    // _globalDragPositions;
    //
    // RenderBox renderBox = context.findRenderObject() as RenderBox;
    //
    // BoxParentData vvv = renderBox.parent?.parentData as BoxParentData;
    // _globalDragPositions = _globalDragPositions -vvv.offset;
    // // Offset localPosition =
    // //     renderBox.globalToLocal(_globalDragPositions);
    // // print('localPosition == $localPosition');
    // // renderBox.localToGlobal(renderBox.)
    // // renderBox.
    // // return  TweenAnimationBuilder<Offset>(
    // //   curve: Curves.fastLinearToSlowEaseIn ,
    // //     tween: Tween<Offset>(
    // //       begin: Offset.zero,
    // //       end: candidateData.isNotEmpty ? _globalDragPositions : Offset.zero, // Изменяем смещение
    // //     ),
    // //     duration: const Duration(milliseconds: 1300),
    // //     builder: (context, offset, child) {
    // return Transform.translate(
    // // transformHitTests: false,
    // // offset: Offset(offset.dx, 0),
    // offset: Offset(_globalDragPositions.dx, 0),
    // child: widgetFromBuilder,
    // );
    // //   }
    // // );
    // // offset: Offset( 60, 0),child:wid,);
    // }
    //
    // return widgetFromBuilder;
    // },
    // onAcceptWithDetails: (data) {
    // //   var d = data;
    //
    // setState(() {
    // int oldIndex = _tempItems.indexOf(e);
    // // Меняем местами иконки
    // var curIndex = _tempItems.indexOf(data.data);
    //
    // // _tempItems.shuffle();
    //
    // var temp = _tempItems[oldIndex];
    //
    // _tempItems[oldIndex] = _tempItems[curIndex];
    // _tempItems[curIndex] = temp;
    //
    // // _tempList=_tempList..shuffle();
    // });
    // },
    // ),
    // );
    // }).toList();
    //
    // _tempList;
    // print('after $_tempList');

    return tempList;
  }
}
