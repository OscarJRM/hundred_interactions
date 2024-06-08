import 'package:flutter/material.dart';
import '../models/interaction.dart';

class InteractionCard extends StatelessWidget {
  final Interaction interaction;
  final VoidCallback onDelete;

  InteractionCard({
    required this.interaction,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(interaction.description),
        subtitle: Text('${interaction.date.toIso8601String()} - ${interaction.category}'),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
