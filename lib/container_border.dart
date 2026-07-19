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
    this.overlapBorder = false,
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

  /// Optional full outline border, drawn in addition to the accent stripe.
  /// Note that combining a border with [borderRadius] requires a uniform
  /// border (e.g. [Border.all]).
  ///
  /// By default (see [overlapBorder]) the accent stripe is confined inside
  /// this border and never covers it.
  final BoxBorder? border;

  /// Whether the accent stripe should be painted over [border] instead of
  /// being confined inside it.
  ///
  /// When `false` (the default), [ContainerBorder] is built on a plain
  /// [Container], which — like any widget using [BoxDecoration.border] —
  /// automatically reserves [border]'s width as padding for its child. Since
  /// the accent stripe is painted as part of that child, it ends up inset by
  /// that same amount and never reaches [border]: the outline stays fully
  /// visible all around, unbroken by the stripe.
  ///
  /// When `true`, the stripe is painted in the same layer as the fill and
  /// [border], on top of both, so it visually overlaps/covers [border] on
  /// its [side] — e.g. for a full outline that gets "interrupted" by a
  /// colored accent on one edge. Has no effect if [border] is null.
  final bool overlapBorder;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final effectiveColors = colors ?? <Color>[color ?? Colors.green];
    final effectiveBackground = backgroundColor ?? Theme.of(context).cardColor;

    if (!overlapBorder) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: effectiveBackground,
          borderRadius: borderRadius,
          border: border,
        ),
        child: CustomPaint(
          foregroundPainter: EdgeBorderPainter(
            side: side,
            colors: effectiveColors,
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

    // overlapBorder: paint fill + border + stripe in the same CustomPaint,
    // in that order, so the stripe (foregroundPainter, painted last) covers
    // border on its side — instead of relying on Container, which would
    // otherwise reserve border's width as padding around the stripe too.
    return ClipRRect(
      borderRadius: borderRadius,
      child: CustomPaint(
        painter: _FillAndBorderPainter(
          color: effectiveBackground,
          border: border,
          borderRadius: borderRadius,
        ),
        foregroundPainter: EdgeBorderPainter(
          side: side,
          colors: effectiveColors,
          thickness: thickness,
          borderRadius: borderRadius,
        ),
        child: Padding(
          padding: (border?.dimensions ?? EdgeInsets.zero).add(padding),
          child: child,
        ),
      ),
    );
  }
}

/// Paints the background fill and, if set, [border] — used by
/// [ContainerBorder] instead of [BoxDecoration] when [ContainerBorder.overlapBorder]
/// is `true`, so [border] is drawn on the same [CustomPaint] as the accent
/// stripe (painted afterwards, on top) rather than by a separate
/// [Container] decoration that would reserve its own padding.
class _FillAndBorderPainter extends CustomPainter {
  _FillAndBorderPainter({
    required this.color,
    required this.border,
    required this.borderRadius,
  });

  final Color color;
  final BoxBorder? border;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRRect(borderRadius.toRRect(rect), Paint()..color = color);
    border?.paint(canvas, rect, borderRadius: borderRadius);
  }

  @override
  bool shouldRepaint(_FillAndBorderPainter old) =>
      color != old.color ||
      border != old.border ||
      borderRadius != old.borderRadius;
}
