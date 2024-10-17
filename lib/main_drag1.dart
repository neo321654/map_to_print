import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


typedef _OnDragEnd = void Function(Velocity velocity, Offset offset, bool wasAccepted);
typedef DragAnchorStrategy = Offset Function(MyDraggable<Object> draggable, BuildContext context, Offset position);

Offset childDragAnchorStrategy(MyDraggable<Object> draggable, BuildContext context, Offset position) {
  final RenderBox renderObject = context.findRenderObject()! as RenderBox;
  return renderObject.globalToLocal(position);
}

class MyDraggable<T extends Object> extends StatefulWidget {
  const MyDraggable({
    super.key,
    required this.child,
    required this.feedback,
    this.data,
    this.axis,
    this.childWhenDragging,
    this.feedbackOffset = Offset.zero,
    this.dragAnchorStrategy = childDragAnchorStrategy,
    this.affinity,
    this.maxSimultaneousDrags,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDraggableCanceled,
    this.onDragEnd,
    this.onDragCompleted,
    this.ignoringFeedbackSemantics = true,
    this.ignoringFeedbackPointer = true,
    this.rootOverlay = false,
    this.hitTestBehavior = HitTestBehavior.deferToChild,
    this.allowedButtonsFilter,
  }) : assert(maxSimultaneousDrags == null || maxSimultaneousDrags >= 0);

  final T? data;

  final Axis? axis;

  final Widget child;

  final Widget? childWhenDragging;

  final Widget feedback;

  final Offset feedbackOffset;

  final DragAnchorStrategy dragAnchorStrategy;

  final bool ignoringFeedbackSemantics;

  final bool ignoringFeedbackPointer;

  final Axis? affinity;

  final int? maxSimultaneousDrags;

  final VoidCallback? onDragStarted;

  final DragUpdateCallback? onDragUpdate;

  final DraggableCanceledCallback? onDraggableCanceled;

  final VoidCallback? onDragCompleted;

  final DragEndCallback? onDragEnd;

  final bool rootOverlay;

  final HitTestBehavior hitTestBehavior;

  final AllowedButtonsFilter? allowedButtonsFilter;

  MultiDragGestureRecognizer createRecognizer(
      GestureMultiDragStartCallback onStart) {
    return switch (affinity) {
      Axis.horizontal => HorizontalMultiDragGestureRecognizer(
          allowedButtonsFilter: allowedButtonsFilter),
      Axis.vertical => VerticalMultiDragGestureRecognizer(
          allowedButtonsFilter: allowedButtonsFilter),
      null => ImmediateMultiDragGestureRecognizer(
          allowedButtonsFilter: allowedButtonsFilter),
    }
      ..onStart = onStart;
  }

  @override
  State<MyDraggable<T>> createState() => _MyDraggableState<T>();
}

class _MyDraggableState<T extends Object> extends State<MyDraggable<T>> {
  @override
  void initState() {
    super.initState();
    _recognizer = widget.createRecognizer(_startDrag);
  }

  @override
  void dispose() {
    _disposeRecognizerIfInactive();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _recognizer!.gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
    super.didChangeDependencies();
  }

  GestureRecognizer? _recognizer;
  int _activeCount = 0;

  void _disposeRecognizerIfInactive() {
    if (_activeCount > 0) {
      return;
    }
    _recognizer!.dispose();
    _recognizer = null;
  }

  void _routePointer(PointerDownEvent event) {
    if (widget.maxSimultaneousDrags != null && _activeCount >= widget.maxSimultaneousDrags!) {
      return;
    }
    _recognizer!.addPointer(event);
  }

  _DragAvatar<T>? _startDrag(Offset position) {
    if (widget.maxSimultaneousDrags != null && _activeCount >= widget.maxSimultaneousDrags!) {
      return null;
    }
    final Offset dragStartPoint;
    dragStartPoint = widget.dragAnchorStrategy(widget, context, position);
    setState(() {
      _activeCount += 1;
    });
    final _DragAvatar<T> avatar = _DragAvatar<T>(
      overlayState: Overlay.of(context, debugRequiredFor: widget, rootOverlay: widget.rootOverlay),
      data: widget.data,
      axis: widget.axis,
      initialPosition: position,
      dragStartPoint: dragStartPoint,
      feedback: widget.feedback,
      feedbackOffset: widget.feedbackOffset,
      ignoringFeedbackSemantics: widget.ignoringFeedbackSemantics,
      ignoringFeedbackPointer: widget.ignoringFeedbackPointer,
      viewId: View.of(context).viewId,
      onDragUpdate: (DragUpdateDetails details) {
        if (mounted && widget.onDragUpdate != null) {
          widget.onDragUpdate!(details);
        }
      },
      onDragEnd: (Velocity velocity, Offset offset, bool wasAccepted) {
        if (mounted) {
          setState(() {
            _activeCount -= 1;
          });
        } else {
          _activeCount -= 1;
          _disposeRecognizerIfInactive();
        }
        if (mounted && widget.onDragEnd != null) {
          widget.onDragEnd!(DraggableDetails(
            wasAccepted: wasAccepted,
            velocity: velocity,
            offset: offset,
          ));
        }
        if (wasAccepted && widget.onDragCompleted != null) {
          widget.onDragCompleted!();
        }
        if (!wasAccepted && widget.onDraggableCanceled != null) {
          widget.onDraggableCanceled!(velocity, offset);
        }
      },
    );
    widget.onDragStarted?.call();
    return avatar;
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasOverlay(context));
    final bool canDrag = widget.maxSimultaneousDrags == null ||
        _activeCount < widget.maxSimultaneousDrags!;
    final bool showChild = _activeCount == 0 || widget.childWhenDragging == null;
    return Listener(
      behavior: widget.hitTestBehavior,
      onPointerDown: canDrag ? _routePointer : null,
      child: showChild ? widget.child : widget.childWhenDragging,
    );
  }
}

class _DragAvatar<T extends Object> extends Drag {
  _DragAvatar({
    required this.overlayState,
    this.data,
    this.axis,
    required Offset initialPosition,
    this.dragStartPoint = Offset.zero,
    this.feedback,
    this.feedbackOffset = Offset.zero,
    this.onDragUpdate,
    this.onDragEnd,
    required this.ignoringFeedbackSemantics,
    required this.ignoringFeedbackPointer,
    required this.viewId,
  }) : _position = initialPosition {
    _entry = OverlayEntry(builder: _build);
    overlayState.insert(_entry!);
    updateDrag(initialPosition);
  }

  final T? data;
  final Axis? axis;
  final Offset dragStartPoint;
  final Widget? feedback;
  final Offset feedbackOffset;
  final DragUpdateCallback? onDragUpdate;
  final _OnDragEnd? onDragEnd;
  final OverlayState overlayState;
  final bool ignoringFeedbackSemantics;
  final bool ignoringFeedbackPointer;
  final int viewId;

  _MyDragTargetState<Object>? _activeTarget;
  final List<_MyDragTargetState<Object>> _enteredTargets = <_MyDragTargetState<Object>>[];
  Offset _position;
  Offset? _lastOffset;
  late Offset _overlayOffset;
  OverlayEntry? _entry;

  @override
  void update(DragUpdateDetails details) {
    final Offset oldPosition = _position;
    _position += _restrictAxis(details.delta);
    updateDrag(_position);
    if (onDragUpdate != null && _position != oldPosition) {
      onDragUpdate!(details);
    }
  }

  @override
  void end(DragEndDetails details) {
    finishDrag(_DragEndKind.dropped, _restrictVelocityAxis(details.velocity));
  }


  @override
  void cancel() {
    finishDrag(_DragEndKind.canceled);
  }

  void updateDrag(Offset globalPosition) {
    _lastOffset = globalPosition - dragStartPoint;
    if (overlayState.mounted) {
      final RenderBox box = overlayState.context.findRenderObject()! as RenderBox;
      final Offset overlaySpaceOffset = box.globalToLocal(globalPosition);
      _overlayOffset = overlaySpaceOffset - dragStartPoint;

      _entry!.markNeedsBuild();
    }

    final HitTestResult result = HitTestResult();
    WidgetsBinding.instance.hitTestInView(result, globalPosition + feedbackOffset, viewId);

    final List<_MyDragTargetState<Object>> targets = _getDragTargets(result.path).toList();

    bool listsMatch = false;
    if (targets.length >= _enteredTargets.length && _enteredTargets.isNotEmpty) {
      listsMatch = true;
      final Iterator<_MyDragTargetState<Object>> iterator = targets.iterator;
      for (int i = 0; i < _enteredTargets.length; i += 1) {
        iterator.moveNext();
        if (iterator.current != _enteredTargets[i]) {
          listsMatch = false;
          break;
        }
      }
    }

    // If everything's the same, report moves, and bail early.
    if (listsMatch) {
      for (final _MyDragTargetState<Object> target in _enteredTargets) {
        target.didMove(this);
      }
      return;
    }

    // Leave old targets.
    _leaveAllEntered();

    // Enter new targets.
    final _MyDragTargetState<Object>? newTarget = targets.cast<_MyDragTargetState<Object>?>().firstWhere(
          (_MyDragTargetState<Object>? target) {
        if (target == null) {
          return false;
        }
        _enteredTargets.add(target);
        return target.didEnter(this);
      },
      orElse: () => null,
    );

    // Report moves to the targets.
    for (final _MyDragTargetState<Object> target in _enteredTargets) {
      target.didMove(this);
    }

    _activeTarget = newTarget;
  }

  Iterable<_MyDragTargetState<Object>> _getDragTargets(Iterable<HitTestEntry> path) {
    // Look for the RenderBoxes that corresponds to the hit target (the hit target
    // widgets build RenderMetaData boxes for us for this purpose).
    return <_MyDragTargetState<Object>>[
      for (final HitTestEntry entry in path)
        if (entry.target case final RenderMetaData target)
          if (target.metaData case final _MyDragTargetState<Object> metaData)
            if (metaData.isExpectedDataType(data, T)) metaData,
    ];
  }

  void _leaveAllEntered() {
    for (int i = 0; i < _enteredTargets.length; i += 1) {
      _enteredTargets[i].didLeave(this);
    }
    _enteredTargets.clear();
  }

  void finishDrag(_DragEndKind endKind, [ Velocity? velocity ]) {
    bool wasAccepted = false;
    if (endKind == _DragEndKind.dropped && _activeTarget != null) {
      _activeTarget!.didDrop(this);
      wasAccepted = true;
      _enteredTargets.remove(_activeTarget);
    }
    _leaveAllEntered();
    _activeTarget = null;
    _entry!.remove();
    _entry!.dispose();
    _entry = null;
    // TODO(ianh): consider passing _entry as well so the client can perform an animation.
    onDragEnd?.call(velocity ?? Velocity.zero, _lastOffset!, wasAccepted);
  }

  Widget _build(BuildContext context) {
    return Positioned(
      left: _overlayOffset.dx,
      top: _overlayOffset.dy,
      child: ExcludeSemantics(
        excluding: ignoringFeedbackSemantics,
        child: IgnorePointer(
          ignoring: ignoringFeedbackPointer,
          child: feedback,
        ),
      ),
    );
  }

  Velocity _restrictVelocityAxis(Velocity velocity) {
    if (axis == null) {
      return velocity;
    }
    return Velocity(
      pixelsPerSecond: _restrictAxis(velocity.pixelsPerSecond),
    );
  }

  Offset _restrictAxis(Offset offset) {
    return switch (axis) {
      Axis.horizontal => Offset(offset.dx, 0.0),
      Axis.vertical   => Offset(0.0, offset.dy),
      null => offset,
    };
  }
}

enum _DragEndKind { dropped, canceled }

class _MyDragTargetState<T extends Object> extends State<MyDragTarget<T>> {
  final List<_DragAvatar<Object>> _candidateAvatars = <_DragAvatar<Object>>[];
  final List<_DragAvatar<Object>> _rejectedAvatars = <_DragAvatar<Object>>[];

  // On non-web platforms, checks if data Object is equal to type[T] or subtype of [T].
  // On web, it does the same, but requires a check for ints and doubles
  // because dart doubles and ints are backed by the same kind of object on web.
  // JavaScript does not support integers.
  bool isExpectedDataType(Object? data, Type type) {
    if (kIsWeb && ((type == int && T == double) || (type == double && T == int))) {
      return false;
    }
    return data is T?;
  }

  bool didEnter(_DragAvatar<Object> avatar) {
    assert(!_candidateAvatars.contains(avatar));
    assert(!_rejectedAvatars.contains(avatar));
    final bool resolvedWillAccept = (widget.onWillAccept == null &&
        widget.onWillAcceptWithDetails == null) ||
        (widget.onWillAccept != null &&
            widget.onWillAccept!(avatar.data as T?)) ||
        (widget.onWillAcceptWithDetails != null &&
            avatar.data != null &&
            widget.onWillAcceptWithDetails!(DragTargetDetails<T>(data: avatar.data! as T, offset: avatar._lastOffset!)));
    if (resolvedWillAccept) {
      setState(() {
        _candidateAvatars.add(avatar);
      });
      return true;
    } else {
      setState(() {
        _rejectedAvatars.add(avatar);
      });
      return false;
    }
  }

  void didLeave(_DragAvatar<Object> avatar) {
    assert(_candidateAvatars.contains(avatar) || _rejectedAvatars.contains(avatar));
    if (!mounted) {
      return;
    }
    setState(() {
      _candidateAvatars.remove(avatar);
      _rejectedAvatars.remove(avatar);
    });
    widget.onLeave?.call(avatar.data as T?);
  }

  void didDrop(_DragAvatar<Object> avatar) {
    assert(_candidateAvatars.contains(avatar));
    if (!mounted) {
      return;
    }
    setState(() {
      _candidateAvatars.remove(avatar);
    });
    if (avatar.data != null)  {
      widget.onAccept?.call(avatar.data! as T);
      widget.onAcceptWithDetails?.call(DragTargetDetails<T>(data: avatar.data! as T, offset: avatar._lastOffset!));
    }
  }

  void didMove(_DragAvatar<Object> avatar) {
    if (!mounted || avatar.data == null) {
      return;
    }
    widget.onMove?.call(DragTargetDetails<T>(data: avatar.data! as T, offset: avatar._lastOffset!));
  }

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: this,
      behavior: widget.hitTestBehavior,
      child: widget.builder(context, _mapAvatarsToData<T>(_candidateAvatars), _mapAvatarsToData<Object>(_rejectedAvatars)),
    );
  }
}


List<T?> _mapAvatarsToData<T extends Object>(List<_DragAvatar<Object>> avatars) {
  return avatars.map<T?>((_DragAvatar<Object> avatar) => avatar.data as T?).toList();
}

class MyDragTarget<T extends Object> extends StatefulWidget {
  /// Creates a widget that receives drags.
  const MyDragTarget({
    super.key,
    required this.builder,
    @Deprecated(
        'Use onWillAcceptWithDetails instead. '
            'This callback is similar to onWillAcceptWithDetails but does not provide drag details. '
            'This feature was deprecated after v3.14.0-0.2.pre.'
    )
    this.onWillAccept,
    this.onWillAcceptWithDetails,
    @Deprecated(
        'Use onAcceptWithDetails instead. '
            'This callback is similar to onAcceptWithDetails but does not provide drag details. '
            'This feature was deprecated after v3.14.0-0.2.pre.'
    )
    this.onAccept,
    this.onAcceptWithDetails,
    this.onLeave,
    this.onMove,
    this.hitTestBehavior = HitTestBehavior.translucent,
  }) : assert(onWillAccept == null || onWillAcceptWithDetails == null, "Don't pass both onWillAccept and onWillAcceptWithDetails.");

  /// Called to build the contents of this widget.
  ///
  /// The builder can build different widgets depending on what is being dragged
  /// into this drag target.
  final DragTargetBuilder<T> builder;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  ///
  /// Equivalent to [onWillAcceptWithDetails], but only includes the data.
  ///
  /// Must not be provided if [onWillAcceptWithDetails] is provided.
  @Deprecated(
      'Use onWillAcceptWithDetails instead. '
          'This callback is similar to onWillAcceptWithDetails but does not provide drag details. '
          'This feature was deprecated after v3.14.0-0.2.pre.'
  )
  final DragTargetWillAccept<T>? onWillAccept;

  /// Called to determine whether this widget is interested in receiving a given
  /// piece of data being dragged over this drag target.
  ///
  /// Called when a piece of data enters the target. This will be followed by
  /// either [onAccept] and [onAcceptWithDetails], if the data is dropped, or
  /// [onLeave], if the drag leaves the target.
  ///
  /// Equivalent to [onWillAccept], but with information, including the data,
  /// in a [DragTargetDetails].
  ///
  /// Must not be provided if [onWillAccept] is provided.
  final DragTargetWillAcceptWithDetails<T>? onWillAcceptWithDetails;

  /// Called when an acceptable piece of data was dropped over this drag target.
  /// It will not be called if `data` is `null`.
  ///
  /// Equivalent to [onAcceptWithDetails], but only includes the data.
  @Deprecated(
      'Use onAcceptWithDetails instead. '
          'This callback is similar to onAcceptWithDetails but does not provide drag details. '
          'This feature was deprecated after v3.14.0-0.2.pre.'
  )
  final DragTargetAccept<T>? onAccept;

  /// Called when an acceptable piece of data was dropped over this drag target.
  /// It will not be called if `data` is `null`.
  ///
  /// Equivalent to [onAccept], but with information, including the data, in a
  /// [DragTargetDetails].
  final DragTargetAcceptWithDetails<T>? onAcceptWithDetails;

  /// Called when a given piece of data being dragged over this target leaves
  /// the target.
  final DragTargetLeave<T>? onLeave;

  /// Called when a [Draggable] moves within this [MyDragTarget]. It will not be
  /// called if `data` is `null`.
  ///
  /// This includes entering and leaving the target.
  final DragTargetMove<T>? onMove;

  /// How to behave during hit testing.
  ///
  /// Defaults to [HitTestBehavior.translucent].
  final HitTestBehavior hitTestBehavior;

  @override
  State<MyDragTarget<T>> createState() => _MyDragTargetState<T>();
}

