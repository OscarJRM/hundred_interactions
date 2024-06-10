import 'package:flutter/material.dart';
import '../models/interaction.dart';

class InteractionCard extends StatelessWidget {
  final Interaction interaction;
  final VoidCallback onDelete;
  final VoidCallback onEdit; // Nuevo parámetro para editar

  InteractionCard({
    required this.interaction,
    required this.onDelete,
    required this.onEdit, // Requerir el nuevo parámetro
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(interaction.description),
        subtitle: Text('${interaction.date.toIso8601String()} - ${interaction.category}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit, // Llamar a onEdit cuando se presiona el botón de edición
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
