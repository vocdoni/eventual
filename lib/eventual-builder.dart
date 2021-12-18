import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:eventual/eventual-notifier.dart';

/// EventualBuilder provides a builder that rebuilds every time that any of `notifier` or
/// `notifiers` is updated. Either of them must be provided. 
class EventualBuilder extends StatefulWidget {
  final List<EventualNotifier?> notifiers = [];
  final Widget Function(BuildContext, List<EventualNotifier?>, Widget?) builder;
  final Widget? child;

  EventualBuilder(
      {EventualNotifier? notifier,
      List<EventualNotifier>? notifiers,
      required this.builder,
      this.child,
      Key? key})
      : assert(notifiers is List || notifier is EventualNotifier),
        super(key: key) {
    if (notifiers is List)
      this.notifiers.addAll(notifiers!);
    else
      this.notifiers.add(notifier);
  }

  @override
  _EventualSingleBuildertate createState() => _EventualSingleBuildertate();
}

class _EventualSingleBuildertate extends State<EventualBuilder> {
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
    assert(widget.notifiers is List, "notifiers must be set");

    for (final item in widget.notifiers) {
      item!.addListener(_changeHandler);
    }
  }

  void removeListeners() {
    assert(widget.notifiers is List);

    for (final item in widget.notifiers) {
      item!.removeListener(_changeHandler);
    }
  }

  @override
  void didUpdateWidget(EventualBuilder oldWidget) {
    if (!listEquals(oldWidget.notifiers, widget.notifiers)) {
      assert(widget.notifiers is List);

      for (final item in oldWidget.notifiers) {
        item!.removeListener(_changeHandler);
      }

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
    return widget.builder(context, widget.notifiers, widget.child);
  }
}
