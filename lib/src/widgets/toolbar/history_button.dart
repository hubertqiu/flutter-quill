import 'package:flutter/cupertino.dart';

import '../../../flutter_quill.dart';
import 'quill_icon_button.dart';

class HistoryButton extends StatefulWidget {
  const HistoryButton({
    required this.icon,
    required this.controller,
    required this.undo,
    this.iconSize = kDefaultIconSize,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final bool undo;
  final QuillController controller;

  @override
  _HistoryButtonState createState() => _HistoryButtonState();
}

class _HistoryButtonState extends State<HistoryButton> {
  Color? _iconColor;
  late CupertinoThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = CupertinoTheme.of(context);
    _setIconColor();

    final fillColor = theme.scaffoldBackgroundColor;
    widget.controller.changes.listen((event) async {
      _setIconColor();
    });
    return QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * 1.77,
      icon: Icon(widget.icon, size: widget.iconSize, color: _iconColor),
      fillColor: fillColor,
      onPressed: _changeHistory,
    );
  }

  void _setIconColor() {
    if (!mounted) return;

    if (widget.undo) {
      setState(() {
        _iconColor = widget.controller.hasUndo ? theme.primaryColor : theme.primaryColor.withOpacity(0.3);
      });
    } else {
      setState(() {
        _iconColor = widget.controller.hasRedo ? theme.primaryColor : theme.primaryColor.withOpacity(0.3);
      });
    }
  }

  void _changeHistory() {
    if (widget.undo) {
      if (widget.controller.hasUndo) {
        widget.controller.undo();
      }
    } else {
      if (widget.controller.hasRedo) {
        widget.controller.redo();
      }
    }

    _setIconColor();
  }
}
