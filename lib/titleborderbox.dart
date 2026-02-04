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
    this.borderWidth = 1.5,
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
    const double titleVerticalPosition = 0;

    // Dessiner le fond
    final RRect backgroundRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(backgroundRRect, bgPaint);

    // Dessiner la bordure avec un espace pour le texte
    final Path borderPath = Path()
      // Commencer depuis le coin supérieur gauche
      ..moveTo(borderRadius, titleVerticalPosition)
      // Ligne jusqu'au début de l'espace pour le texte
      ..lineTo(textLeftPosition - textPadding, titleVerticalPosition);

    if (title != null && title!.isNotEmpty) {
      // Sauter l'espace du texte
      borderPath.moveTo(
        textLeftPosition + textWidth + textPadding,
        titleVerticalPosition,
      );
    }

    // Ligne jusqu'au coin supérieur droit
    borderPath
      ..lineTo(size.width - borderRadius, titleVerticalPosition)
      // Arc pour le coin supérieur droit
      ..arcToPoint(
        Offset(size.width, borderRadius),
        radius: Radius.circular(borderRadius),
      )
      // Ligne droite descendante côté droit
      ..lineTo(size.width, size.height - borderRadius)
      // Arc pour le coin inférieur droit
      ..arcToPoint(
        Offset(size.width - borderRadius, size.height),
        radius: Radius.circular(borderRadius),
      )
      // Ligne du bas
      ..lineTo(borderRadius, size.height)
      // Arc pour le coin inférieur gauche
      ..arcToPoint(
        Offset(0, size.height - borderRadius),
        radius: Radius.circular(borderRadius),
      )
      // Ligne gauche ascendante
      ..lineTo(0, borderRadius)
      // Arc pour le coin supérieur gauche
      ..arcToPoint(
        Offset(borderRadius, titleVerticalPosition),
        radius: Radius.circular(borderRadius),
      );

    if (borderPaint != null) {
      canvas.drawPath(borderPath, borderPaint);
    }

    // Dessiner le texte du titre
    if (title == null || title!.isEmpty) return;

    double currentX = textLeftPosition;

    // Dessiner l'icône si elle existe
    if (icon != null) {
      // Obtenir les informations de l'icône
      final IconData iconData = icon!.icon!;
      final Color iconColor = icon!.color ?? titleStyle.color!;
      final double iconSize = icon!.size ?? 20.0;

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
        ..paint(
          canvas,
          Offset(currentX, -textHeight / 2 + (textHeight - iconSize) / 2),
        );

      // Mettre à jour la position X pour le texte
      currentX += iconSize + iconSpacing;
    }

    // Dessiner le texte
    final TextSpan textSpan = TextSpan(text: title, style: titleStyle);

    TextPainter(text: textSpan, textDirection: TextDirection.ltr)
      ..layout()
      ..paint(canvas, Offset(currentX, -textHeight / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
