import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TitleBorderBox extends StatelessWidget {
  // Espacement entre l'icône et le texte

  const TitleBorderBox({
    required this.child,
    super.key,
    this.title,
    this.maxTitleWidth, // optionnel pour forcer une largeur max différente
    this.borderColor = Colors.blue,
    this.backgroundColor = Colors.white,
    this.borderRadius = 8.0,
    this.contentPadding = const EdgeInsets.all(16.0),
    this.borderWidth = 1.0,
    this.titleStyle = const TextStyle(
      color: Colors.black54,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    this.icon, // Icône optionnelle (maintenant de type Icon?)
    this.iconSpacing = 0.0, // Espacement par défaut entre l'icône et le texte
  }) : assert(
         borderWidth >= 0,
         'Border width must be greater than or equal to 0',
       ),
       assert(
         borderRadius >= 0,
         'Border radius must be greater than or equal to 0',
       );

  const factory TitleBorderBox.none() = _TitleBorderBoxNone;
  final dynamic title; // Accepte String ou Widget
  final Widget child;

  /// Permettre à l'utilisateur de fixer une largeur max du titre (sinon on infère via LayoutBuilder)
  final double? maxTitleWidth;
  final Color borderColor;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsets contentPadding;
  final double borderWidth;
  final TextStyle titleStyle;
  final Icon? icon; // Modifié de IconData? à Icon?
  final double iconSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        String? rawTitle;
        if (title is String) {
          rawTitle = title as String;
        } else if (title is Widget) {
          rawTitle = null; // pas géré dans painter
        }

        double iconWidth = 0;
        if (icon != null) {
          final double iconSize = icon!.size ?? 20.0;
          iconWidth = iconSize + iconSpacing;
        }

        // largeur max disponible (on laisse 20px de marge gauche et droite comme dans le painter)
        const double horizontalMargin = 20.0;
        final double available =
            (maxTitleWidth ?? constraints.maxWidth) -
            horizontalMargin * 2 -
            iconWidth;
        double effectiveAvailable = available.isFinite ? available : 300;
        if (effectiveAvailable < 40) effectiveAvailable = 40; // mini sécurité

        // Prépare un TextPainter pour mesurer et tronquer manuellement (ellipsis)
        String? truncated = rawTitle;
        if (rawTitle != null) {
          final basePainter = TextPainter(
            text: TextSpan(text: rawTitle, style: titleStyle),
            textDirection: TextDirection.ltr,
            maxLines: 1,
          )..layout(maxWidth: effectiveAvailable + 1000); // layout large

          if (basePainter.width > effectiveAvailable) {
            // Tronquer en binaire pour efficacité
            int min = 0;
            int max = rawTitle.length;
            int best = 0;
            while (min <= max) {
              final mid = (min + max) >> 1;
              final candidate = '${rawTitle.substring(0, mid)}…';
              final tp = TextPainter(
                text: TextSpan(text: candidate, style: titleStyle),
                textDirection: TextDirection.ltr,
                maxLines: 1,
              )..layout(maxWidth: effectiveAvailable);
              if (tp.didExceedMaxLines || tp.width > effectiveAvailable) {
                max = mid - 1;
              } else {
                best = mid;
                min = mid + 1;
              }
            }
            truncated = best == 0 ? '…' : '${rawTitle.substring(0, best)}…';
          }
        }

        // Mesurer le texte tronqué
        final textPainter = TextPainter(
          text: TextSpan(text: truncated, style: titleStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout(maxWidth: effectiveAvailable);

        final double textWidth = textPainter.width + iconWidth;
        final double textHeight = textPainter.height;

        return CustomPaint(
          painter: TitledBorderPainter(
            title: truncated,
            borderColor: borderColor,
            titleStyle: titleStyle,
            backgroundColor: backgroundColor,
            borderRadius: borderRadius,
            textWidth: textWidth,
            textHeight: textHeight,
            borderWidth: borderWidth,
            icon: icon,
            iconSpacing: iconSpacing,
          ),
          child: Padding(
            padding: contentPadding.copyWith(top: contentPadding.top),
            child: child,
          ),
        );
      },
    );
  }
}

class _TitleBorderBoxNone extends TitleBorderBox {
  const _TitleBorderBoxNone() : super(child: const SizedBox());
}

class TitledBorderPainter extends CustomPainter {
  TitledBorderPainter({
    required this.title,
    required this.borderColor,
    required this.titleStyle,
    required this.backgroundColor,
    required this.borderRadius,
    required this.textWidth,
    required this.textHeight,
    required this.borderWidth,
    this.icon,
    this.iconSpacing = 4.0,
  }) {
    if (title == null) {
      if (kDebugMode) {
        print(
          "if title is null or empty, may be a better idea to use Container() instead of TitleBorderBox()",
        );
      }
    }
  }
  final String? title;
  final Color borderColor;
  final TextStyle titleStyle;
  final Color backgroundColor;
  final double borderRadius;
  final double textWidth;
  final double textHeight;
  final double borderWidth;
  final Icon? icon;
  final double iconSpacing;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint? borderPaint = borderWidth > 0
        ? (Paint()
            ..color = borderColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderWidth)
        : null;

    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Position du texte (le titre)
    const double textLeftPosition = 20.0;
    const double textPadding = 4.0; // Espace autour du texte

    // Ajustement pour aligner le trait sur les pixels (évite l'effet de flou "épais" du lissage)
    // Cela simule un StrokeAlign.inside en décalant le tracé de la moitié de l'épaisseur vers l'intérieur
    final double halfStroke = borderWidth / 2.0;

    final double top = halfStroke;
    final double left = halfStroke;
    final double right = size.width - halfStroke;
    final double bottom = size.height - halfStroke;

    // Ajuster le rayon pour qu'il soit concentrique
    final double adjRadius = (borderRadius - halfStroke).clamp(
      0.0,
      borderRadius,
    );

    // Dessiner le fond (reste pleine taille)
    final RRect backgroundRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(backgroundRRect, bgPaint);

    // Dessiner la bordure avec un espace pour le texte
    final Path borderPath = Path()
      // Commencer après le coin supérieur gauche
      ..moveTo(left + adjRadius, top)
      // Ligne jusqu'au début de l'espace pour le texte
      ..lineTo(textLeftPosition - textPadding, top);

    if (title != null && title!.isNotEmpty) {
      // Sauter l'espace du texte
      borderPath.moveTo(textLeftPosition + textWidth + textPadding, top);
    }

    // Ligne jusqu'au coin supérieur droit
    borderPath
      ..lineTo(right - adjRadius, top)
      // Arc pour le coin supérieur droit
      ..arcToPoint(
        Offset(right, top + adjRadius),
        radius: Radius.circular(adjRadius),
      )
      // Ligne droite descendante côté droit
      ..lineTo(right, bottom - adjRadius)
      // Arc pour le coin inférieur droit
      ..arcToPoint(
        Offset(right - adjRadius, bottom),
        radius: Radius.circular(adjRadius),
      )
      // Ligne du bas
      ..lineTo(left + adjRadius, bottom)
      // Arc pour le coin inférieur gauche
      ..arcToPoint(
        Offset(left, bottom - adjRadius),
        radius: Radius.circular(adjRadius),
      )
      // Ligne gauche ascendante
      ..lineTo(left, top + adjRadius)
      // Arc pour le coin supérieur gauche
      ..arcToPoint(
        Offset(left + adjRadius, top),
        radius: Radius.circular(adjRadius),
      );

    if (borderPaint != null) {
      canvas.drawPath(borderPath, borderPaint);
    }

    // Dessiner le texte du titre
    if (title == null || title!.isEmpty) return;

    double currentX = textLeftPosition;

    // Le centre du texte s'aligne sur la ligne supérieure (top)
    final double textVerticalBaseline = top;

    // Dessiner l'icône si elle existe
    if (icon != null) {
      final IconData iconData = icon!.icon!;
      final Color iconColor = icon!.color ?? titleStyle.color!;
      final double iconSize = icon!.size ?? 20.0;

      // Centrer l'icône verticalement par rapport à la ligne
      final double iconTop = textVerticalBaseline - iconSize / 2.0;

      TextPainter(
          text: TextSpan(
            text: String.fromCharCode(iconData.codePoint),
            style: TextStyle(
              fontSize: iconSize,
              fontFamily: iconData.fontFamily,
              color: iconColor,
            ),
          ),
          textDirection: TextDirection.ltr,
        )
        ..layout()
        ..paint(canvas, Offset(currentX, iconTop));

      currentX += iconSize + iconSpacing;
    }

    // Dessiner le texte
    final TextSpan textSpan = TextSpan(text: title, style: titleStyle);

    // Centrer le texte verticalement par rapport à la ligne
    final double textTop = textVerticalBaseline - textHeight / 2.0;

    TextPainter(text: textSpan, textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(currentX, textTop));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
