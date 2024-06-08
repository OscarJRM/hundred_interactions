import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/interaction.dart';

class CalendarScreen extends StatefulWidget {
  final List<Interaction> interactions;

  CalendarScreen({required this.interactions});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late Map<DateTime, List<Interaction>> _interactionsByDay;

  @override
  void initState() {
    super.initState();
    _interactionsByDay = _groupInteractionsByDay(widget.interactions);
  }

  Map<DateTime, List<Interaction>> _groupInteractionsByDay(List<Interaction> interactions) {
    Map<DateTime, List<Interaction>> data = {};

    for (var interaction in interactions) {
      final date = DateTime(interaction.date.year, interaction.date.month, interaction.date.day);
      if (data[date] == null) {
        data[date] = [];
      }
      data[date]!.add(interaction);
    }

    return data;
  }

  List<Interaction> _getInteractionsForDay(DateTime day) {
    return _interactionsByDay[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario de Interacciones'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            eventLoader: _getInteractionsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: _buildEventsMarker(date, events.length),
                  );
                }
                return SizedBox();
              },
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                for (var date in _interactionsByDay.keys)
                  if (_interactionsByDay[date]!.isNotEmpty)
                    ListTile(
                      title: Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('${_interactionsByDay[date]!.length} interacciones'),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, int count) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '$count',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
