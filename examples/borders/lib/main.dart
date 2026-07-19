import 'package:flutter/material.dart';
import 'package:toolbox/toolbox.dart';

void main() => runApp(const ToolboxExampleApp());

class ToolboxExampleApp extends StatelessWidget {
  const ToolboxExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CardBorder & ContainerBorder Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const ExamplesPage(),
    );
  }
}

class ExamplesPage extends StatelessWidget {
  const ExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CardBorder & ContainerBorder Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SectionTitle('CardBorder — dans une Card'),
            const SizedBox(height: 8),
            const Text(
              'CardBorder ne dessine pas de fond : il doit être placé dans '
              'un widget qui fournit déjà le fond et le clip, comme Card.',
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const CardBorder(
                side: CardBorderSide.left,
                color: Colors.green,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Carte avec liseré vert à gauche'),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const _SectionTitle('CardBorder — les 4 côtés'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _CardBorderDemo(
                    side: CardBorderSide.top,
                    color: Colors.red,
                    label: 'top',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CardBorder(
                      side: CardBorderSide.right,
                      color: Colors.orange,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade50, Colors.orange.shade200],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('right\navec dégradé'),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _CardBorderDemo(
                    side: CardBorderSide.bottom,
                    color: Colors.purple,
                    label: 'bottom',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CardBorderDemo(
                    side: CardBorderSide.left,
                    color: Colors.teal,
                    label: 'left',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _SectionTitle('ContainerBorder — autonome'),
            const SizedBox(height: 8),
            const Text(
              'ContainerBorder dessine son propre fond et se clippe '
              "lui-même : il peut être posé n'importe où, sans parent Card.",
            ),
            const SizedBox(height: 8),
            const ContainerBorder(
              side: CardBorderSide.left,
              color: Colors.indigo,
              backgroundColor: Color(0xFFEDEBFB),
              padding: EdgeInsets.all(16),
              child: Text('Bloc autonome avec fond et liseré indigo'),
            ),
            const SizedBox(height: 24),

            const _SectionTitle('ContainerBorder — épaisseur et rayon'),
            const SizedBox(height: 8),
            ContainerBorder(
              side: CardBorderSide.left,
              color: Colors.pink,
              thickness: 14,
              borderRadius: BorderRadius.circular(24),
              backgroundColor: Colors.pink.shade50,
              padding: const EdgeInsets.all(16),
              child: const Text('Liseré épais (14) et coins très arrondis'),
            ),
            const SizedBox(height: 24),

            const _SectionTitle('ContainerBorder — avec bordure complète'),
            const SizedBox(height: 8),
            ContainerBorder(
              side: CardBorderSide.top,
              color: Colors.amber.shade800,
              backgroundColor: Colors.amber.shade50,
              border: Border.all(color: Colors.amber.shade200),
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Combine le liseré coloré avec un contour complet',
              ),
            ),
            const SizedBox(height: 24),

            const _SectionTitle('3 colonnes de ContainerBorder'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ContainerBorder(
                    side: CardBorderSide.left,
                    color: Colors.green,
                    backgroundColor: Colors.green.shade50,
                    padding: const EdgeInsets.all(12),
                    child: const Text('Colonne 1'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ContainerBorder(
                    side: CardBorderSide.left,
                    color: Colors.orange,
                    backgroundColor: Colors.orange.shade50,
                    padding: const EdgeInsets.all(12),
                    child: const Text('Colonne 2'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ContainerBorder(
                    side: CardBorderSide.left,
                    color: Colors.purple,
                    backgroundColor: Colors.purple.shade50,
                    padding: const EdgeInsets.all(12),
                    child: const Text('Colonne 3'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _SectionTitle('CardBorder — colors (dégradé multi-couleurs)'),
            const SizedBox(height: 8),
            const Text(
              'Avec colors, le liseré est divisé en segments égaux : '
              'haut→bas pour left/right, gauche→droite pour top/bottom.',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const CardBorder(
                      side: CardBorderSide.left,
                      colors: [Colors.red, Colors.amber, Colors.green],
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('left — 3 couleurs'),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const CardBorder(
                      side: CardBorderSide.top,
                      colors: [Colors.blue, Colors.pink],
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('top — 2 couleurs'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const _SectionTitle(
              'ContainerBorder — colors (dégradé multi-couleurs)',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ContainerBorder(
                    side: CardBorderSide.left,
                    colors: const [Colors.red, Colors.amber, Colors.green],
                    backgroundColor: const Color(0xFFF3F3F3),
                    padding: const EdgeInsets.all(16),
                    child: const Text('left — 3 couleurs'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ContainerBorder(
                    side: CardBorderSide.bottom,
                    colors: const [Colors.blue, Colors.pink],
                    backgroundColor: const Color(0xFFF3F3F3),
                    padding: const EdgeInsets.all(16),
                    child: const Text('bottom — 2 couleurs'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

/// Wraps [CardBorder] in a [Card] since [CardBorder] relies on its parent
/// for background and clipping.
class _CardBorderDemo extends StatelessWidget {
  const _CardBorderDemo({
    required this.side,
    required this.color,
    required this.label,
  });

  final CardBorderSide side;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: CardBorder(
        side: side,
        color: color,
        child: Padding(padding: const EdgeInsets.all(16), child: Text(label)),
      ),
    );
  }
}
