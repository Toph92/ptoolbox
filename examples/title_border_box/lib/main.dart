import 'package:flutter/material.dart';
import 'package:toolbox/toolbox.dart'; // here is the barrel export

void main() => runApp(const ToolboxExampleApp());

class ToolboxExampleApp extends StatelessWidget {
  const ToolboxExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TitleBorderBox Examples',
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
      appBar: AppBar(title: const Text('TitleBorderBox Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Basique',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TitleBorderBox(
              title: 'Informations',
              child: Text('Contenu simple du bloc'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Avec icône',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TitleBorderBox(
              title: 'Statistiques',
              icon: Icon(
                Icons.stacked_line_chart_outlined,
                color: Colors.indigo,
                size: 30,
              ),
              iconSpacing: 2,
              child: Text('Quelques chiffres importants...'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Style personnalisé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TitleBorderBox(
              title: 'Alerte',
              borderColor: Colors.red,
              backgroundColor: Color(0xFFFFF2F2),
              borderRadius: 16,
              borderWidth: 2.5,
              titleStyle: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              child: Text('Un message important à lire attentivement.'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Sans titre (factory none)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const TitleBorderBox.none(), // je ne sais plus trop l'utilité de ce truc
            const SizedBox(height: 24),

            const SizedBox(height: 8),
            TitleBorderBox(
              title: 'Titre long sans bordure au cadre',
              backgroundColor: Colors.orange.shade100,
              borderWidth: 0,
              child: const Text('Gestion d\'un titre plus long.'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Contenu composé',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TitleBorderBox(
              title: 'Composition',
              icon: const Icon(Icons.layers, size: 18, color: Colors.teal),
              iconSpacing: 6,
              borderColor: Colors.teal,
              backgroundColor: Colors.teal.withValues(alpha: 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Plusieurs widgets:'),
                  const SizedBox(height: 8),
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: const Text('Zone colorée'),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.teal),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Texte plus long avec une explication détaillée démontrant la mise en page.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '3 colonnes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // add 3 TitleBorderBox in a row with expanded
                Expanded(
                  child: TitleBorderBox(
                    backgroundColor: Colors.green.shade100,
                    title: 'Colonne 1',
                    child: const Text('Green'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TitleBorderBox(
                    backgroundColor: Colors.orange.shade100,

                    child: const Text('Orange'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TitleBorderBox(
                    backgroundColor: Colors.purple.shade100,
                    title: 'Colonne 3',
                    child: const Text('Purple'),
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
