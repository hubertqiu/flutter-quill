import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;

class PreviewPage extends StatefulWidget {
  PreviewPage(this.markdown);
  String markdown;
  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Flutter Quill Preview',
          // style: Styles.navBarText,
        ),
        // backgroundColor: Styles.activeColor,
      ),
      child: SafeArea(child: _buildMarkDownWidget(context)),
    );
  }

  Widget _buildMarkDownWidget(BuildContext context) {
    Widget child;
    var textTheme = CupertinoTheme.of(context).textTheme.copyWith(
        textStyle: CupertinoTheme.of(context)
            .textTheme
            .textStyle
            .copyWith(fontSize: 16, height: 1.5, color: CupertinoColors.white));
    CupertinoThemeData themeData = CupertinoTheme.of(context).copyWith(textTheme: textTheme);
    var stylesheet = MarkdownStyleSheet.fromCupertinoTheme(themeData);
    child = Markdown(
      data: widget.markdown,
      styleSheet: stylesheet,
      styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
      selectable: true,
    );

    return Container(
      // height: height,
      child: child,
    );
  }
}
