import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';

///Widget that draw a beautiful checkbox rounded. Provided with animation if wanted
class RoundCheckBox extends StatefulWidget {
  const RoundCheckBox({
    Key? key,
    this.isChecked,
    this.checkedWidget,
    this.uncheckedWidget,
    this.checkedColor,
    this.uncheckedColor,
    this.borderColor,
    this.size,
    this.animationDuration,
    required this.onTap,
  }) : super(key: key);

  ///Define wether the checkbox is marked or not
  final bool? isChecked;

  ///Define the widget that is shown when Widgets is checked
  final Widget? checkedWidget;

  ///Define the widget that is shown when Widgets is unchecked
  final Widget? uncheckedWidget;

  ///Define the color that is shown when Widgets is checked
  final Color? checkedColor;

  ///Define the color that is shown when Widgets is unchecked
  final Color? uncheckedColor;

  ///Define the border of the widget
  final Color? borderColor;

  ///Define the size of the checkbox
  final double? size;

  ///Define Function that os executed when user tap on checkbox
  final Function(bool?) onTap;

  ///Define the duration of the animation. If any
  final Duration? animationDuration;

  @override
  _RoundCheckBoxState createState() => _RoundCheckBoxState();
}

class _RoundCheckBoxState extends State<RoundCheckBox> {
  bool? isChecked;
  double? size;
  Color? checkedColor;
  Color? uncheckedColor;
  late Color borderColor;

  @override
  void initState() {
    isChecked = widget.isChecked ?? false;
    size = widget.size ?? 40.0;
    checkedColor = widget.checkedColor ?? CupertinoColors.activeGreen;
    uncheckedColor = widget.checkedColor ?? CupertinoColors.white;
    borderColor = widget.borderColor ?? CupertinoColors.separator.withOpacity(0.5);
    super.initState();
  }

  @override
  void didUpdateWidget(RoundCheckBox oldWidget) {
    final themeData = CupertinoTheme.of(context);
    uncheckedColor = widget.uncheckedColor ?? themeData.scaffoldBackgroundColor;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var checkedWidget = isChecked!
        ? Icon(
            CupertinoIcons.checkmark_alt,
            color: CupertinoColors.white,
            size: 16,
          )
        : Container(
            decoration: BoxDecoration(
              color: uncheckedColor,
              borderRadius: BorderRadius.circular(size! / 2),
            ),
          );
    return GestureDetector(
      onTap: () {
        setState(() => isChecked = !isChecked!);
        widget.onTap(isChecked);
      },
      child: Container(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size! / 2),
          child: Container(
            height: size!,
            width: size!,
            decoration: BoxDecoration(
              color: isChecked! ? checkedColor : uncheckedColor,
              border: Border.all(
                color: borderColor,
              ),
              borderRadius: BorderRadius.circular(size! / 2),
            ),
            child: Center(child: checkedWidget),
          ),
        ),
      ),
    );
  }
}
