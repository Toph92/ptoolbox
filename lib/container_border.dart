import 'package:flutter/material.dart';
import 'package:toolbox/card_border.dart';

/// A self-contained [Container] with rounded corners and a solid color
/// accent stripe — or, when [colors] is set, a sequence of equal-width
/// color segments — along one [side].
///
/// Unlike [CardBorder] (which needs a parent that provides the background and
/// clipping, e.g. a [Card]), [ContainerBorder] draws its own [backgroundColor]
/// and clips itself, so it can be dropped in anywhere.
///
/// The stripe follows [borderRadius] on the outside (rounded corners) while its
/// inner edge stays straight — same rendering as [CardBorder].
class ContainerBorder extends StatelessWidget {
  const ContainerBorder({
    required this.child,
    super.key,
    this.side = CardBorderSide.left,
    this.color,
    this.colors,
    this.thickness = 6,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.backgroundColor,
    this.border,
    this.padding = EdgeInsets.zero,
  }) : assert(
         color == null || colors == null,
         'Provide either color or colors, not both.',
       );

  final Widget child;
  final CardBorderSide side;

  /// The stripe's solid color. Ignored when [colors] is provided.
  ///
  /// Defaults to [Colors.green] when neither [color] nor [colors] is set.
  /// Mutually exclusive with [colors]: providing both is a contract
  /// violation, asserted in debug mode (in release builds [colors] simply
  /// takes priority).
  final Color? color;

  /// Splits the accent stripe into `colors.length` equal-width segments,
  /// each painted with its own color, instead of a single solid [color].
  ///
  /// * A single-entry list behaves exactly like [color] with that value.
  /// * Segments are ordered top-to-bottom for [CardBorderSide.left] and
  ///   [CardBorderSide.right], and left-to-right for [CardBorderSide.top]
  ///   and [CardBorderSide.bottom].
  /// * Only the segment(s) touching a rounded outer corner of
  ///   [borderRadius] show that curve; interior segments are straight-edged.
  /// * Must not be empty. Mutually exclusive with [color]: providing both is
  ///   a contract violation, asserted in debug mode.
  final List<Color>? colors;

  final double thickness;
  final BorderRadius borderRadius;

  /// Fill behind the child. Defaults to the theme's [ThemeData.cardColor].
  final Color? backgroundColor;

  /// Optional full outline border, passed straight to the [BoxDecoration] just
  /// like `Container(decoration: BoxDecoration(border: ...))`. This draws in
  /// addition to the accent stripe. Note that combining a border with
  /// [borderRadius] requires a uniform border (e.g. [Border.all]).
  final BoxBorder? border;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: borderRadius,
        border: border,
      ),
      child: CustomPaint(
        foregroundPainter: EdgeBorderPainter(
          side: side,
          colors: colors ?? <Color>[color ?? Colors.green],
          thickness: thickness,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
