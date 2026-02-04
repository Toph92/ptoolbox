import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toolbox/dialogs.dart';
import 'package:toolbox/toolbox.dart';

void main() {
  group('DialogBuilder', () {
    setUp(() {
      // Réinitialise l'état global entre les tests
      checked.clear();
    });

    Future<BuildContext> pumpBase(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      return tester.element(find.byType(Scaffold));
    }

    testWidgets('ok() affiche message et retourne true sur OK', (tester) async {
      final ctx = await pumpBase(tester);
      final future = DialogBuilder<bool>(
        context: ctx,
        message: 'Message info',
      ).ok();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Message info'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      // Icône info (provient du type info)
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      final result = await future;
      expect(result, isTrue);
    });

    testWidgets('yesNo() retourne true ou false selon le bouton pressé', (
      tester,
    ) async {
      final ctx = await pumpBase(tester);
      final future = DialogBuilder<bool>(
        context: ctx,
        message: 'Continuer ?',
      ).yesNo();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Continuer ?'), findsOneWidget);
      expect(find.text('Oui'), findsOneWidget);
      expect(find.text('Non'), findsOneWidget);
      await tester.tap(find.text('Oui'));
      await tester.pumpAndSettle();
      expect(await future, isTrue);

      // On affiche à nouveau et on clique Non
      final future2 = DialogBuilder<bool>(
        context: ctx,
        message: 'Recommencer ?',
      ).yesNo();
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Non'));
      await tester.pumpAndSettle();
      expect(await future2, isFalse);
    });

    testWidgets(
      'custom() applique altMessage, icône et style par défaut sur bouton isDefault',
      (tester) async {
        final ctx = await pumpBase(tester);
        final future =
            DialogBuilder<int>(
              context: ctx,
              message: 'Température ?',
              altMessage: 'Très important.',
              icon: const Icon(Icons.ac_unit, color: Colors.blue, size: 40),
            ).custom(
              type: DialogType.question,
              dialogButtons: [
                DialogButton(label: 'Froid', value: 1),
                DialogButton(label: 'Parfait', value: 2, isDefault: true),
                DialogButton(label: 'Chaud', value: 3),
              ],
            );
        await tester.pump();
        await tester.pumpAndSettle();
        expect(find.text('Température ?'), findsOneWidget);
        expect(find.text('Très important.'), findsOneWidget);
        expect(find.byIcon(Icons.ac_unit), findsOneWidget);
        final parfaitText = tester.widget<Text>(find.text('Parfait'));
        expect(parfaitText.style?.fontWeight, FontWeight.bold);
        await tester.tap(find.text('Parfait'));
        await tester.pumpAndSettle();
        expect(await future, 2);
      },
    );

    testWidgets('tag + checkbox empêchent ré-affichage après sélection', (
      tester,
    ) async {
      final ctx = await pumpBase(tester);
      const tag = 'diag_tag_test';
      final future = DialogBuilder<bool>(
        context: ctx,
        message: 'Afficher encore ?',
        tag: tag,
      ).ok();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Afficher encore ?'), findsOneWidget);
      expect(find.text('Ne plus afficher'), findsOneWidget);
      expect(checked.containsKey(tag), isFalse);
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(checked[tag], isTrue);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await future, isTrue);

      // Deuxième appel : ne doit plus afficher de dialog
      final future2 = DialogBuilder<bool>(
        context: ctx,
        message: 'Afficher encore ?',
        tag: tag,
      ).ok();
      // Pas de nouvelle route -> pas d'AlertDialog supplémentaire
      await tester.pump();
      expect(await future2, isNull);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('tag sans cocher la case permet le ré-affichage', (
      tester,
    ) async {
      final ctx = await pumpBase(tester);
      const tag = 'diag_tag_test2';
      // première ouverture
      final future1 = DialogBuilder<bool>(
        context: ctx,
        message: 'Question ?',
        tag: tag,
      ).ok();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Question ?'), findsOneWidget);
      // on ne coche pas la case -> tag ne sera pas dans checked
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await future1, isTrue);
      expect(checked.containsKey(tag), isFalse);

      // deuxième ouverture doit toujours apparaître
      final future2 = DialogBuilder<bool>(
        context: ctx,
        message: 'Question ?',
        tag: tag,
      ).ok();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Question ?'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await future2, isTrue);
    });

    testWidgets('error() affiche icône erreur et retourne true', (
      tester,
    ) async {
      final ctx = await pumpBase(tester);
      final future = DialogBuilder<bool>(
        context: ctx,
        message: 'Une erreur est survenue.',
      ).error();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Une erreur est survenue.'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await future, isTrue);
    });

    testWidgets('warning() affiche icône warning et retourne true', (
      tester,
    ) async {
      final ctx = await pumpBase(tester);
      final future = DialogBuilder<bool>(
        context: ctx,
        message: 'Attention au niveau de batterie.',
      ).warning();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Attention au niveau de batterie.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await future, isTrue);
    });

    testWidgets('removeCancel() retourne false puis true selon le bouton', (
      tester,
    ) async {
      final ctx = await pumpBase(tester);
      final future1 = DialogBuilder<bool>(
        context: ctx,
        message: 'Supprimer cet élément ?',
      ).removeCancel();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Supprimer cet élément ?'), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Supprimer'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(await future1, isFalse);

      final future2 = DialogBuilder<bool>(
        context: ctx,
        message: 'Supprimer cet élément ?',
      ).removeCancel();
      await tester.pump();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Supprimer'));
      await tester.pumpAndSettle();
      expect(await future2, isTrue);
    });

    testWidgets('altMessage en tant que Widget est rendu', (tester) async {
      final ctx = await pumpBase(tester);
      final future = DialogBuilder<bool>(
        context: ctx,
        message: 'Info',
        altMessage: const Row(
          children: [
            Icon(Icons.info, size: 16),
            SizedBox(width: 4),
            Flexible(child: Text('Détail widgetisé')),
          ],
        ),
      ).ok();
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.text('Info'), findsOneWidget);
      expect(find.text('Détail widgetisé'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await future, isTrue);
    });
  });
}
