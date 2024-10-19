import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

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
  Offset globalOffset = Offset.infinite;

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
            globalDeltaOffset: globalDeltaOffset,
            globalOffset: globalOffset,
            setGlobalOffset: setGlobalOffset,
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
      globalDeltaOffset = offset;
    });
  }

  void setGlobalOffset(Offset offset) {
    setState(() {
      globalOffset = offset;
    });
  }
}

class DockItem<T extends Object> extends StatefulWidget {
  const DockItem(
      {required this.item,
      required this.builder,
      required this.onDrop,
      required this.setGlobalDeltaOffset,
      required this.setGlobalOffset,
      required this.globalDeltaOffset,
      required this.globalOffset,
      super.key});

  final T item;
  final Widget Function(T) builder;
  final Function(T itemToRemove, T item) onDrop;
  final Function(Offset offset) setGlobalDeltaOffset;
  final Function(Offset offset) setGlobalOffset;
  final Offset globalDeltaOffset;
  final Offset globalOffset;

  @override
  State<DockItem<T>> createState() => _DockItemState<T>();
}

class _DockItemState<T extends Object> extends State<DockItem<T>> {
  bool isDragging = false;
  bool isVisible = true;
  late Widget widgetFromBuilder;
  Offset offsetToDelta = Offset.zero;
  Offset offsetToLeave = Offset.zero;
  OverlayEntry? overlayEntry;

  @override
  void initState() {
    super.initState();
    widgetFromBuilder = widget.builder(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    // print(context);
    return Visibility(
      visible: isVisible,
      maintainSize: true,
      maintainAnimation: true,
      maintainState: true,
      child: Draggable<T>(
        data: widget.item,
        onDragStarted: () {
          isDragging = true;
          isVisible = false;
        },
        onDragEnd: (details) {
          isDragging = false;
          isVisible = true;
          resetGlobalDelta();
          showOverlayAnimation(details.offset, context);
        },
        onDragCompleted: () {
          isDragging = false;
          isVisible = true;
          resetGlobalDelta();
        },
        onDraggableCanceled: (vel, offset) {
          isDragging = false;
          isVisible = true;
          resetGlobalDelta();
        },
        dragAnchorStrategy: (Draggable<Object> draggable, BuildContext context,
            Offset position) {
          /// не может быть null , из-за  Draggable ->Listener extends SingleChildRenderObjectWidget
          RenderBox renderObject = getRenderBoxObject(context)!;

          /// офсет для
          Offset? offSet = getParentOffset(renderObject);

          if (offSet != null) {
            Offset ofToGlobal = renderObject.localToGlobal(offSet) - offSet;
            widget.setGlobalDeltaOffset(offSet);
            widget.setGlobalOffset(ofToGlobal);
          }

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
          onMove: (details) {
            // print(details.offset);
          },
          builder: (BuildContext context, candidateData, rejectedData) {
            if (candidateData.isNotEmpty) {
              ///не может быть null , из-за  DragTarget ->MetaData extends SingleChildRenderObjectWidget
              RenderBox renderBox = context.findRenderObject() as RenderBox;

              Offset offsetBias = getParentOffset(renderBox) ?? Offset.zero;

              offsetToLeave = offsetBias;

              offsetToDelta = widget.globalDeltaOffset - offsetBias;

              /// Смещение влево или вправо
              offsetToDelta = Offset(
                renderBox.size.width * offsetToDelta.dx.sign,
                offsetToDelta.dy,
              );

              return AnimatedOffsetWidget(
                begin: Offset.zero,
                end: candidateData.isNotEmpty ? offsetToDelta : Offset.zero,
                duration: const Duration(milliseconds: 600),
                child: widgetFromBuilder,
                builder: (context, offset, child) {
                  return Transform.translate(
                    offset: offset,
                    child: widgetFromBuilder,
                  );
                },
              );

              // return TweenAnimationBuilder<Offset>(
              //     curve: Curves.easeInOutExpo,
              //     tween: Tween<Offset>(
              //       begin: Offset.zero,
              //       end: candidateData.isNotEmpty ? offsetToDelta : Offset.zero,
              //     ),
              //     duration: const Duration(milliseconds: 600),
              //     builder: (context, offset, child) {
              //       return Transform.translate(
              //         offset: offset,
              //         child: widgetFromBuilder,
              //       );
              //     });
            }

            return widgetFromBuilder;
          },
          onAcceptWithDetails: (data) {
            widget.onDrop(data.data, widget.item);
          },
          onLeave: (data) {
            widget.setGlobalDeltaOffset(offsetToLeave);
            // widget.setGlobalOffset(offset);
            widget.onDrop(data!, widget.item);
          },
        ),
      ),
    );
  }

  Offset? getParentOffset(RenderBox? renderObject) {
    if (renderObject == null) return null;

    BoxParentData? pData = findBoxParentData(renderObject);

    if (pData != null) return pData.offset;

    return null;
  }

  BoxParentData? findBoxParentData(RenderBox? renderBox) {
    if (renderBox == null) return null;

    RenderObject? parent = renderBox.parent;

    if (parent == null) return null;

    while (parent != null) {
      var parentData = parent.parentData;
      if (parentData is BoxParentData) {
        return parentData;
      }
      parent = parent.parent;
    }
    return null;
  }

  RenderBox? getRenderBoxObject(BuildContext context) {
    RenderObject? renderObject = context.findRenderObject();
    if (renderObject != null && renderObject is RenderBox) {
      return renderObject;
    }
    return null;
  }

  void resetGlobalDelta() {
    offsetToDelta = Offset.zero;
    widget.setGlobalDeltaOffset(Offset.infinite);
  }

  void showOverlayAnimation(Offset offset, BuildContext context) {
    // print(widget.globalOffset);
    overlayEntry = OverlayEntry(
      // Create a new OverlayEntry.
      builder: (BuildContext context) {
        // print('!!!!!!     $offset');
        // context.size;
        // Align is used to position the highlight overlay
        // relative to the NavigationBar destination.
        return Container(
          color: Colors.red.withOpacity(0.3),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AnimatedOffsetWidget(
                begin: offset,
                end: widget.globalOffset,
                duration: const Duration(milliseconds: 1000),
                onEnd: removeOverlayEntry,
                child: widgetFromBuilder,
                builder: (context, offset, child) {
                  return Positioned(
                    top: offset.dy,
                    left: offset.dx,
                    child: widgetFromBuilder,
                  );
                },
              ),

              // TweenAnimationBuilder<Offset>(
              //     curve: Curves.easeInOutExpo,
              //     tween: Tween<Offset>(
              //       begin: offset,
              //       end: widget.globalOffset,
              //     ),
              //     onEnd: () {
              //       removeOverlayEntry();
              //     },
              //     duration: const Duration(milliseconds: 1000),
              //     builder: (context, offset, child) {
              //       return Positioned(
              //         top: offset.dy,
              //         left: offset.dx,
              //         child: widgetFromBuilder,
              //       );
              //     }),
            ],
          ),
        );
      },
    );

    // isVisible = false;

    Overlay.of(context, debugRequiredFor: widget).insert(overlayEntry!);
  }

  void removeOverlayEntry() {
    overlayEntry?.remove();
    overlayEntry?.dispose();
    overlayEntry = null;
  }
}

class AnimatedOffsetWidget extends StatelessWidget {
  final Offset begin;
  final Offset end;
  final Duration duration;
  final Widget child;
  final Curve curve;
  final ValueWidgetBuilder<Offset> builder;
  final void Function()? onEnd;

  const AnimatedOffsetWidget({
    Key? key,
    required this.begin,
    required this.end,
    required this.duration,
    required this.child,
    required this.builder,
    this.curve = Curves.easeInOutExpo,
    this.onEnd,
  }) : super(key: key);

  // ValueWidgetBuilder<Offset>

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Offset>(
      curve: curve,
      tween: Tween<Offset>(
        begin: begin,
        end: end,
      ),
      duration: duration,
      onEnd: onEnd,
      builder: builder,
      child: child,
    );
  }
}
