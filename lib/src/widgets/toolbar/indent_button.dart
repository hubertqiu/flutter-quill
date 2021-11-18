import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/models/documents/style.dart';

import '../../../flutter_quill.dart';
import 'quill_icon_button.dart';

class IndentButton extends StatefulWidget {
  const IndentButton({
    required this.icon,
    required this.controller,
    required this.isIncrease,
    this.iconSize = kDefaultIconSize,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;
  final QuillController controller;
  final bool isIncrease;

  @override
  _IndentButtonState createState() => _IndentButtonState();
}

class _IndentButtonState extends State<IndentButton> {
  bool? _isToggled;

  Style get _selectionStyle => widget.controller.getSelectionStyle();

  @override
  void initState() {
    super.initState();
    _isToggled = _getIsToggled(_selectionStyle.attributes);
    widget.controller.addListener(_didChangeEditingValue);
  }

  bool _getIsToggled(Map<String, Attribute> attrs) {
    if (attrs[Attribute.list.key] == null) {
      return false;
    }
    Attribute attr = attrs[Attribute.list.key]!;
    return attr.value == 'bullet' || attr.value == 'ordered';
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _isToggled == true
        ? CupertinoTheme.of(context).primaryColor
        : CupertinoTheme.of(context).primaryColor.withOpacity(0.3);
    final fillColor = CupertinoTheme.of(context).scaffoldBackgroundColor;
    var onPressed = () {
      final indent = widget.controller.getSelectionStyle().attributes[Attribute.indent.key];
      if (indent == null) {
        if (widget.isIncrease) {
          widget.controller.formatSelection(Attribute.indentL1);
        }
        return;
      }
      if (indent.value == 1 && !widget.isIncrease) {
        widget.controller.formatSelection(Attribute.clone(Attribute.indentL1, null));
        return;
      }
      if (widget.isIncrease) {
        widget.controller.formatSelection(Attribute.getIndentLevel(indent.value + 1));
        return;
      }
      widget.controller.formatSelection(Attribute.getIndentLevel(indent.value - 1));
    };
    return QuillIconButton(
      highlightElevation: 0,
      hoverElevation: 0,
      size: widget.iconSize * 1.77,
      icon: Icon(widget.icon, size: widget.iconSize, color: iconColor),
      fillColor: fillColor,
      onPressed: _isToggled == true ? onPressed : null,
    );
  }

  @override
  void didUpdateWidget(covariant IndentButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_didChangeEditingValue);
      widget.controller.addListener(_didChangeEditingValue);
      _isToggled = _getIsToggled(_selectionStyle.attributes);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_didChangeEditingValue);
    super.dispose();
  }

  void _didChangeEditingValue() {
    setState(() => _isToggled = _getIsToggled(_selectionStyle.attributes));
  }
}
