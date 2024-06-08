class Category {
  String id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  // Método para crear una categoría desde una cadena
  factory Category.fromString(String categoryString) {
    List<String> parts = categoryString.split(',');
    return Category(
      id: parts[0],
      name: parts[1],
    );
  }

  // Método para convertir la categoría a una cadena
  String toString() {
    return '$id,$name';
  }
}
