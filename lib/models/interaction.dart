class Interaction {
  String id;
  String description;
  String category;
  DateTime date;

  Interaction({
    required this.id,
    required this.description,
    required this.category,
    required this.date,
  });

  // Método para crear una interacción desde una cadena
  factory Interaction.fromString(String interactionString) {
    List<String> parts = interactionString.split(',');
    return Interaction(
      id: parts[0],
      description: parts[1],
      category: parts[2],
      date: DateTime.parse(parts[3]),
    );
  }

  // Método para convertir la interacción a una cadena
  String toString() {
    return '$id,$description,$category,${date.toIso8601String()}';
  }
}
