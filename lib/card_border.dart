import 'package:flutter/material.dart';

/// The edge of the card along which [CardBorder] draws its accent stripe.
enum CardBorderSide { top, right, bottom, left }

/// Draws a solid color stripe along one edge of [child].
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
    this.color = Colors.green,
    this.thickness = 6,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  final Widget child;
  final CardBorderSide side;
  final Color color;
  final double thickness;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: CustomPaint(
        foregroundPainter: EdgeBorderPainter(
          side: side,
          color: color,
          thickness: thickness,
          borderRadius: borderRadius,
        ),
        child: child,
      ),
    );
  }
}

/// Paints a solid color stripe along one [side], with rounded outer corners
/// (following [borderRadius]) and a straight inner edge. Shared by
/// [CardBorder] and `ContainerBorder`.
class EdgeBorderPainter extends CustomPainter {
  EdgeBorderPainter({
    required this.side,
    required this.color,
    required this.thickness,
    required this.borderRadius,
  });

  final CardBorderSide side;
  final Color color;
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
    final bandPath = Path()..addRect(band);

    // Intersection = rounded outer corners + straight inner edge.
    final stripe = Path.combine(PathOperation.intersect, rrectPath, bandPath);

    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    canvas.drawPath(stripe, paint);
  }

  @override
  bool shouldRepaint(EdgeBorderPainter old) =>
      side != old.side ||
      color != old.color ||
      thickness != old.thickness ||
      borderRadius != old.borderRadius;
}
