import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// The edge of the card along which [CardBorder] draws its accent stripe.
enum CardBorderSide { top, right, bottom, left }

/// Draws a solid color stripe — or, when [colors] is set, a sequence of
/// equal-width color segments — along one edge of [child].
///
/// The stripe follows the card's [borderRadius] on the outside (rounded
/// corners) while its inner edge stays perfectly straight, matching a card
/// accent bar. The child is clipped to the same [borderRadius] so both
/// share the exact same rounded corners with no visible overlap.
class CardBorder extends StatelessWidget {
  const CardBorder({
    required this.child,
    super.key,
    this.side = CardBorderSide.left,
    this.color,
    this.colors,
    this.thickness = 6,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
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

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CustomPaint(
        foregroundPainter: EdgeBorderPainter(
          side: side,
          colors: colors ?? <Color>[color ?? Colors.green],
          thickness: thickness,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

/// Paints a solid color stripe — or, when [colors] has more than one entry,
/// a sequence of equal-width color segments — along one [side], with
/// rounded outer corners (following [borderRadius]) and a straight inner
/// edge. Shared by [CardBorder] and `ContainerBorder`.
///
/// Adjacent segments are drawn as separate anti-aliased paths, so a faint
/// ~1px color blend can appear at segment boundaries; this is a minor
/// cosmetic tradeoff, not a rendering bug.
class EdgeBorderPainter extends CustomPainter {
  EdgeBorderPainter({
    required this.side,
    required this.colors,
    required this.thickness,
    required this.borderRadius,
  }) : assert(colors.isNotEmpty, 'colors must not be empty.');

  final CardBorderSide side;

  /// Resolved, non-empty stripe colors. See [CardBorder.colors] /
  /// `ContainerBorder.colors` for the segment-splitting behavior.
  final List<Color> colors;
  final double thickness;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Full rounded-rect outline: provides the rounded OUTER corners.
    final rrectPath = Path()..addRRect(borderRadius.toRRect(rect));

    // Straight band along the requested edge: provides the straight INNER edge.
    final Rect band = switch (side) {
      CardBorderSide.top => Rect.fromLTWH(0, 0, size.width, thickness),
      CardBorderSide.bottom =>
        Rect.fromLTWH(0, size.height - thickness, size.width, thickness),
      CardBorderSide.left => Rect.fromLTWH(0, 0, thickness, size.height),
      CardBorderSide.right =>
        Rect.fromLTWH(size.width - thickness, 0, thickness, size.height),
    };

    final vertical =
        side == CardBorderSide.left || side == CardBorderSide.right;
    final segmentCount = colors.length;

    // Boundary coordinates along the band's length axis, shared between
    // adjacent segments so there's never a rounding gap/overlap; the first
    // and last boundary are pinned exactly to the band's outer edges.
    final double bandStart = vertical ? band.top : band.left;
    final double bandEnd = vertical ? band.bottom : band.right;
    final boundaries = List<double>.generate(segmentCount + 1, (i) {
      if (i == 0) return bandStart;
      if (i == segmentCount) return bandEnd;
      return bandStart + (bandEnd - bandStart) * i / segmentCount;
    });

    final paint = Paint()..isAntiAlias = true;
    for (var i = 0; i < segmentCount; i++) {
      final subRect = vertical
          ? Rect.fromLTRB(
              band.left,
              boundaries[i],
              band.right,
              boundaries[i + 1],
            )
          : Rect.fromLTRB(
              boundaries[i],
              band.top,
              boundaries[i + 1],
              band.bottom,
            );

      final segment = Path.combine(
        PathOperation.intersect,
        rrectPath,
        Path()..addRect(subRect),
      );
      paint.color = colors[i];
      canvas.drawPath(segment, paint);
    }
  }

  @override
  bool shouldRepaint(EdgeBorderPainter old) =>
      side != old.side ||
      !listEquals(colors, old.colors) ||
      thickness != old.thickness ||
      borderRadius != old.borderRadius;
}
