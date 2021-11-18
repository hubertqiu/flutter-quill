import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../flutter_quill.dart';
import 'quill_icon_button.dart';

class ClearFormatButton extends StatefulWidget {
  const ClearFormatButton({
    required this.icon,
    required this.controller,
    this.iconSize = kDefaultIconSize,
    Key? key,
  }) : super(key: key);

  final IconData icon;
  final double iconSize;

  final QuillController controller;

  @override
  _ClearFormatButtonState createState() => _ClearFormatButtonState();
}

class _ClearFormatButtonState extends State<ClearFormatButton> {
  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final iconColor = theme.primaryColor;
    final fillColor = theme.barBackgroundColor;
    return QuillIconButton(
        highlightElevation: 0,
        hoverElevation: 0,
        size: widget.iconSize * kIconButtonFactor,
        icon: Icon(widget.icon, size: widget.iconSize, color: iconColor),
        fillColor: fillColor,
        onPressed: () {
<<<<<<< HEAD
          final attrs = <Attribute>{};
          for (final style in widget.controller.getAllSelectionStyles()) {
            for (final attr in style.attributes.values) {
              attrs.add(attr);
            }
          }
          for (final attr in attrs) {
            widget.controller.formatSelection(Attribute.clone(attr, null));
=======
          for (final k in widget.controller.getSelectionStyle().attributes.values) {
            widget.controller.formatSelection(Attribute.clone(k, null));
>>>>>>> litela_editor
          }
        });
  }
}
