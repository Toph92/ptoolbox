import 'package:flutter/material.dart';
import 'package:toolbox/toolbox.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCalendar Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const CalendarDemoPage(),
    );
  }
}

// Modèle personnalisé pour les événements
class MyEvent {
  final DateTime date;
  final bool done;

  MyEvent({required this.date, required this.done});
}

class CalendarDemoPage extends StatefulWidget {
  const CalendarDemoPage({super.key});

  @override
  State<CalendarDemoPage> createState() => _CalendarDemoPageState();
}

class _CalendarDemoPageState extends State<CalendarDemoPage> {
  late PCalendarController _controller;
  DateTime _selectedDate = DateTime.now();

  // Liste d'événements avec différents états
  final List<MyEvent> _events = [
    MyEvent(date: DateTime.now().add(const Duration(days: 2)), done: true),
    MyEvent(date: DateTime.now().add(const Duration(days: 5)), done: false),
    MyEvent(date: DateTime.now().subtract(const Duration(days: 3)), done: true),
    MyEvent(date: DateTime.now().add(const Duration(days: 7)), done: false),
  ];

  @override
  void initState() {
    super.initState();
    _controller = PCalendarController(initialDate: _selectedDate);
    _controller.addListener(() {
      setState(() {
        _selectedDate = _controller.selectedDate ?? DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PCalendar Demo'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Style conditionnel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vert = Terminé (done: true)\nRouge = À faire (done: false)',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _controller.prevMonth(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Mois préc.'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _controller.nextMonth(),
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Mois suiv.'),
                        iconAlignment: IconAlignment.end,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Card(
                      elevation: 4,
                      shadowColor: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: PCalendar(
                        controller: _controller,
                        initialDate: _selectedDate,
                        compact: false,
                        // Utilisation du builder pour gérer les états
                        dayStyleBuilder: (date) {
                          // Rechercher si on a un événement pour ce jour
                          final event = _events
                              .where(
                                (e) =>
                                    e.date.year == date.year &&
                                    e.date.month == date.month &&
                                    e.date.day == date.day,
                              )
                              .firstOrNull;

                          if (event == null) return null;

                          // Retourner le style en fonction de l'état 'done'
                          return PCalendarDayStyle(
                            backgroundColor: event.done
                                ? Colors.grey.withValues(alpha: 0.2)
                                : Colors.blue.withValues(alpha: 0.2),
                            textStyle: TextStyle(
                              color: event.done ? Colors.grey : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                        onDateSelected: (date) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Sélection : ${date.day}/${date.month}/${date.year}',
                              ),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondaryContainer),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: colorScheme.secondary),
              const SizedBox(width: 12),
              Text(
                'Détails de la sélection',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Jour', _selectedDate.day.toString()),
          _buildInfoRow('Mois', _selectedDate.month.toString()),
          _buildInfoRow('Année', _selectedDate.year.toString()),
          _buildInfoRow(
            'Jour de la semaine',
            _getWeekdayName(_selectedDate.weekday),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    const days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    return days[weekday - 1];
  }
}
