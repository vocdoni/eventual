import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eventual/eventual-notifier.dart';

/// EventualSingleBuilder provides up to four different builders that are used according to the
/// current state of `notifier`.
/// - If `isLoading` evaluates to `true`, then `loadingBuilder` will be built (if present).
/// - If `hasError` evaluates to `true`, then `errorBuilder` will be built (if present).
/// - If `hasValue` evaluates to `false`, then `emptyBuilder` will be built (if present).
/// - In any other case, `builder` will be built.
class EventualSingleBuilder extends StatefulWidget {
  final EventualNotifier? notifier;
  final Widget Function(BuildContext, EventualNotifier?, Widget?)? loadingBuilder;
  final Widget Function(BuildContext, EventualNotifier?, Widget?)? errorBuilder;
  final Widget Function(BuildContext, EventualNotifier?, Widget?)? emptyBuilder;
  final Widget Function(BuildContext, EventualNotifier?, Widget?) builder;
  final Widget? child;

  EventualSingleBuilder(
      {required this.notifier,
      this.loadingBuilder,
      this.errorBuilder,
      this.emptyBuilder,
      required this.builder,
      this.child,
      Key? key})
      : super(key: key);

  @override
  _EventualSingleBuilderState createState() => _EventualSingleBuilderState();
}

class _EventualSingleBuilderState extends State<EventualSingleBuilder> {
  int _buildCount = 0;

  @override
  void initState() {
    super.initState();

    addListeners();
  }

  void _changeHandler() {
    // Trigger a rebuild
    setState(() => _buildCount++);
  }

  void addListeners() {
    widget.notifier!.addListener(_changeHandler);
  }

  void removeListeners() {
    widget.notifier!.removeListener(_changeHandler);
  }

  @override
  void didUpdateWidget(EventualSingleBuilder oldWidget) {
    if (oldWidget.notifier != widget.notifier) {
      oldWidget.notifier!.removeListener(_changeHandler);

      addListeners();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    removeListeners();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notifier!.isLoading && widget.loadingBuilder != null)
      return widget.loadingBuilder!(context, widget.notifier, widget.child);
    else if (widget.notifier!.hasError && widget.errorBuilder != null)
      return widget.errorBuilder!(context, widget.notifier, widget.child);
    else if (!widget.notifier!.hasValue && widget.emptyBuilder != null)
      return widget.emptyBuilder!(context, widget.notifier, widget.child);
    else
      return widget.builder(context, widget.notifier, widget.child);
  }
}
