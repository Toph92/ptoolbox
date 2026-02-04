import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolbox/toolbox.dart';

CustomPaint _findCustomPaintOfTitleBorderBox() {
  final customPaintFinder = find.byType(CustomPaint).evaluate().where((e) {
    final widget = e.widget as CustomPaint;
    return widget.painter is TitledBorderPainter;
  });
  expect(
    customPaintFinder.length,
    1,
    reason: 'Il devrait y avoir un CustomPaint avec TitledBorderPainter',
  );
  return customPaintFinder.first.widget as CustomPaint;
}

void main() {
  group('TitleBorderBox', () {
    testWidgets('renders child content et painter avec titre', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TitleBorderBox(title: 'Titre', child: Text('Contenu')),
        ),
      );
      expect(find.text('Contenu'), findsOneWidget);
      final paintWidget = _findCustomPaintOfTitleBorderBox();
      final painter = paintWidget.painter as TitledBorderPainter;
      expect(painter.title, 'Titre');
    });

    testWidgets('factory none produit un painter sans titre', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TitleBorderBox.none()));
      // Vérifie la présence du CustomPaint seulement (sous-classe interne)
      final paintWidget = _findCustomPaintOfTitleBorderBox();
      final painter = paintWidget.painter as TitledBorderPainter;
      expect(painter.title, isNull);
    });

    testWidgets('icon et spacing propagés au painter', (tester) async {
      const icon = Icon(Icons.star, size: 24, color: Colors.amber);
      await tester.pumpWidget(
        const MaterialApp(
          home: TitleBorderBox(
            title: 'Avec icône',
            icon: icon,
            iconSpacing: 8,
            child: SizedBox(),
          ),
        ),
      );
      final painter =
          _findCustomPaintOfTitleBorderBox().painter as TitledBorderPainter;
      expect(painter.icon, isNotNull);
      expect(painter.icon!.icon, icon.icon);
      expect(painter.iconSpacing, 8);
      expect(painter.title, 'Avec icône');
    });

    testWidgets('paramètres de style appliqués', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TitleBorderBox(
            title: 'Stylé',
            borderColor: Colors.red,
            backgroundColor: Colors.yellow,
            borderRadius: 16,
            borderWidth: 3,
            child: SizedBox(width: 50, height: 20),
          ),
        ),
      );
      final painter =
          _findCustomPaintOfTitleBorderBox().painter as TitledBorderPainter;
      expect(painter.borderColor, Colors.red);
      expect(painter.backgroundColor, Colors.yellow);
      expect(painter.borderRadius, 16);
      expect(painter.borderWidth, 3);
      expect(painter.title, 'Stylé');
    });

    testWidgets('borderWidth=0 ne dessine pas de bordure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TitleBorderBox(
            title: 'Sans bordure',
            borderWidth: 0,
            child: SizedBox(width: 20, height: 10),
          ),
        ),
      );
      final painter =
          _findCustomPaintOfTitleBorderBox().painter as TitledBorderPainter;
      expect(painter.borderWidth, 0);
    });

    testWidgets('long titre tronqué avec ellipsis', (tester) async {
      const longTitle =
          'Ceci est un titre extrêmement long qui doit être tronqué proprement sans retour à la ligne';
      await tester.pumpWidget(
        const MaterialApp(
          home: SizedBox(
            width: 220,
            child: TitleBorderBox(title: longTitle, child: SizedBox()),
          ),
        ),
      );
      final painter =
          _findCustomPaintOfTitleBorderBox().painter as TitledBorderPainter;
      expect(painter.title, isNot(equals(longTitle)));
      expect(painter.title, endsWith('…'));
    });
  });
}
