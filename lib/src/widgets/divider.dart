// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

/// A thin vertical line, with padding on either side.
///
/// In the material design language, this represents a divider. Vertical
/// dividers can be used in horizontally scrolling lists, such as a
/// [ListView] with [ListView.scrollDirection] set to [Axis.horizontal].
///
/// The box's total width is controlled by [width]. The appropriate
/// padding is automatically computed from the width.
///
/// {@tool dartpad --template=stateless_widget_scaffold}
///
/// This sample shows how to display a [VerticalDivider] between an purple and orange box
/// inside a [Row]. The [VerticalDivider] is 20 logical pixels in width and contains a
/// horizontally centered black line that is 1 logical pixels thick. The grey
/// line is indented by 20 logical pixels.
///
/// ```dart
/// Widget build(BuildContext context) {
///   return Container(
///     padding: const EdgeInsets.all(10),
///     child: Row(
///       children: <Widget>[
///         Expanded(
///           child: Container(
///             decoration: BoxDecoration(
///               borderRadius: BorderRadius.circular(10),
///               color: Colors.deepPurpleAccent,
///             ),
///           ),
///         ),
///         const VerticalDivider(
///           color: Colors.grey,
///           thickness: 1,
///           indent: 20,
///           endIndent: 0,
///           width: 20,
///         ),
///         Expanded(
///           child: Container(
///             decoration: BoxDecoration(
///               borderRadius: BorderRadius.circular(10),
///               color: Colors.deepOrangeAccent,
///             ),
///           ),
///         ),
///       ],
///     ),
///   );
/// }
/// ```
/// {@end-tool}
/// See also:
///
///  * [ListView.separated], which can be used to generate vertical dividers.
///  * <https://material.io/design/components/dividers.html>
class MagicVerticalDivider extends StatelessWidget {
  /// Creates a material design vertical divider.
  ///
  /// The [width], [thickness], [indent], and [endIndent] must be null or
  /// non-negative.
  const MagicVerticalDivider({
    Key? key,
    this.width,
    this.thickness,
    this.indent,
    this.endIndent,
    required this.color,
  })  : assert(width == null || width >= 0.0),
        assert(thickness == null || thickness >= 0.0),
        assert(indent == null || indent >= 0.0),
        assert(endIndent == null || endIndent >= 0.0),
        super(key: key);

  /// The divider's width.
  ///
  /// The divider itself is always drawn as a vertical line that is centered
  /// within the width specified by this value.
  ///
  /// If this is null, then the [DividerThemeData.space] is used. If that is
  /// also null, then this defaults to 16.0.
  final double? width;

  /// The thickness of the line drawn within the divider.
  ///
  /// A divider with a [thickness] of 0.0 is always drawn as a line with a
  /// width of exactly one device pixel.
  ///
  /// If this is null, then the [DividerThemeData.thickness] is used which
  /// defaults to 0.0.
  final double? thickness;

  /// The amount of empty space on top of the divider.
  ///
  /// If this is null, then the [DividerThemeData.indent] is used. If that is
  /// also null, then this defaults to 0.0.
  final double? indent;

  /// The amount of empty space under the divider.
  ///
  /// If this is null, then the [DividerThemeData.endIndent] is used. If that is
  /// also null, then this defaults to 0.0.
  final double? endIndent;

  /// The color to use when painting the line.
  ///
  /// If this is null, then the [DividerThemeData.color] is used. If that is
  /// also null, then [ThemeData.dividerColor] is used.
  ///
  /// {@tool snippet}
  ///
  /// ```dart
  /// const Divider(
  ///   color: Colors.deepOrange,
  /// )
  /// ```
  /// {@end-tool}
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double width = this.width ?? 16.0;
    final double thickness = this.thickness ?? 0.0;
    final double indent = this.indent ?? 0.0;
    final double endIndent = this.endIndent ?? 0.0;

    return SizedBox(
      width: width,
      child: Center(
        child: Container(
          width: thickness,
          margin: EdgeInsetsDirectional.only(top: indent, bottom: endIndent),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
    );
  }
}
