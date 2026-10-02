import 'package:flutter/widgets.dart';
import 'package:tideline/src/commands/command.dart';

/// Makes commands executable in a part of the widget tree.
///
/// Handlers of an inner [CommandHandlers] take precedence; commands it does
/// not handle fall through to outer ones. A command without any handler is
/// disabled, so its key passes through to other widgets.
class CommandHandlers extends StatelessWidget {
  /// Creates handlers for [child].
  const new({required this.handlers, required this.child, super.key});

  /// Callbacks by command id.
  final Map<String, VoidCallback> handlers;

  /// The subtree in which the commands work.
  final Widget child;

  /// Runs [commandId] from [context] if a handler exists. Returns whether
  /// it ran. Useful for buttons and menus.
  static bool invoke(BuildContext context, String commandId) {
    final handler = _HandlerScope.lookup(context, commandId);
    handler?.call();
    return handler != null;
  }

  @override
  Widget build(BuildContext context) {
    final parent = _HandlerScope.maybeOf(context);
    final merged = {...?parent?.handlers, ...handlers};
    return _HandlerScope(
      handlers: merged,
      child: Actions(
        actions: {CommandIntent: _CommandAction(merged)},
        child: child,
      ),
    );
  }
}

class _CommandAction extends Action<CommandIntent> {
  new(this._handlers);

  final Map<String, VoidCallback> _handlers;

  VoidCallback? _handlerFor(CommandIntent intent) {
    for (final id in intent.candidates) {
      final handler = _handlers[id];
      if (handler != null) return handler;
    }
    return null;
  }

  @override
  bool isEnabled(CommandIntent intent) => _handlerFor(intent) != null;

  @override
  void invoke(CommandIntent intent) => _handlerFor(intent)?.call();
}

class _HandlerScope extends InheritedWidget {
  const new({required this.handlers, required super.child});

  final Map<String, VoidCallback> handlers;

  static _HandlerScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_HandlerScope>();

  static VoidCallback? lookup(BuildContext context, String id) =>
      maybeOf(context)?.handlers[id];

  @override
  bool updateShouldNotify(_HandlerScope oldWidget) =>
      oldWidget.handlers != handlers;
}
