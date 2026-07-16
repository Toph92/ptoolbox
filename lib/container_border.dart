import 'package:flutter/material.dart';
import 'package:toolbox/card_border.dart';

/// A self-contained [Container] with rounded corners and a solid color accent
/// stripe along one [side].
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
    this.color = Colors.green,
    this.thickness = 6,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.backgroundColor,
    this.border,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final CardBorderSide side;
  final Color color;
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
          color: color,
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
