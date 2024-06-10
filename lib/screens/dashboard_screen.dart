import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/interaction.dart';
import '../models/category.dart';
import '../widgets/interaction_card.dart';
import 'calendar_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late SharedPreferences _prefs;

  final List<Interaction> _interactions = [];
  final List<Category> _categories = [];

  DateTime _currentDate = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _prefs = await SharedPreferences.getInstance();

    setState(() {
      _loadInteractions();
      _loadCategories();
    });
  }

  void _loadInteractions() {
    final List<String>? interactionStrings = _prefs.getStringList('interactions');
    if (interactionStrings != null) {
      _interactions.clear();
      _interactions.addAll(interactionStrings.map((string) => Interaction.fromString(string)));
    }
  }

  void _loadCategories() {
    final List<String>? categoryStrings = _prefs.getStringList('categories');
    if (categoryStrings != null) {
      _categories.clear();
      _categories.addAll(categoryStrings.map((string) => Category.fromString(string)));
    } else {
      _categories.addAll([
        Category(id: '1', name: 'Trabajo'),
        Category(id: '2', name: 'Social'),
        Category(id: '3', name: 'Ejercicio'),
      ]);
    }
  }

  Future<void> _saveInteractions() async {
    final List<String> interactionStrings = _interactions.map((interaction) => interaction.toString()).toList();
    await _prefs.setStringList('interactions', interactionStrings);
  }

  Future<void> _saveCategories() async {
    final List<String> categoryStrings = _categories.map((category) => category.toString()).toList();
    await _prefs.setStringList('categories', categoryStrings);
  }

  void _addInteraction(String description, String category) {
    final newInteraction = Interaction(
      id: DateTime.now().toString(),
      description: description,
      category: category,
      date: DateTime.now(),
    );

    setState(() {
      _interactions.add(newInteraction);
      _saveInteractions();
    });
  }

  void _removeInteraction(String id) {
    setState(() {
      _interactions.removeWhere((interaction) => interaction.id == id);
      _saveInteractions();
    });
  }

  void _addCategory(String name) {
    final newCategory = Category(
      id: DateTime.now().toString(),
      name: name,
    );

    setState(() {
      _categories.add(newCategory);
      _saveCategories();
    });
  }

  void _removeCategory(Category category) {
    setState(() {
      _categories.remove(category);
      _saveCategories();
    });
  }

  int _countMonthlyInteractions(DateTime date) {
    return _interactions
        .where((interaction) =>
            interaction.date.year == date.year && interaction.date.month == date.month)
        .length;
  }

  int _daysLeftInMonth(DateTime date) {
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    final lastDayOfMonth = nextMonth.subtract(Duration(days: 1));
    final today = DateTime.now();
    if (date.year == today.year && date.month == today.month) {
      return lastDayOfMonth.day - today.day;
    } else {
      return lastDayOfMonth.day;
    }
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int interactionCount = _countMonthlyInteractions(_currentDate);
    final double progress = (interactionCount / 100).clamp(0.0, 1.0);
    final int daysLeft = _daysLeftInMonth(_currentDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddInteractionDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CalendarScreen(interactions: _interactions),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_left),
                      onPressed: _previousMonth,
                    ),
                    Text(
                      '${_currentDate.year}-${_currentDate.month}',
                      style: TextStyle(fontSize: 20),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_right),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
                Text(
                  'Interacciones este mes: $interactionCount/100',
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  'Días restantes: $daysLeft',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _interactions.length,
              itemBuilder: (ctx, index) {
                return InteractionCard(
                  interaction: _interactions[index],
                  onDelete: () => _removeInteraction(_interactions[index].id),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.category),
        onPressed: () {
          _showManageCategoriesDialog(context);
        },
      ),
    );
  }

  void _showAddInteractionDialog(BuildContext context) {
    final _descriptionController = TextEditingController();
    String? _selectedCategory = _categories.isNotEmpty ? _categories[0].name : null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Añadir Interacción'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.name,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: InputDecoration(labelText: 'Categoría'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Añadir'),
            onPressed: () {
              if (_descriptionController.text.isNotEmpty && _selectedCategory != null) {
                _addInteraction(_descriptionController.text, _selectedCategory!);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final _nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Añadir Categoría'),
        content: TextField(
          controller: _nameController,
          decoration: InputDecoration(labelText: 'Nombre de la Categoría'),
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text('Añadir'),
            onPressed: () {
              if (_nameController.text.isNotEmpty) {
                _addCategory(_nameController.text);
                Navigator.of(ctx).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _showManageCategoriesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Gestionar Categorías'),
        content: Container(
          width: double.minPositive,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _categories.length,
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      title: Text(_categories[index].name),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removeCategory(_categories[index]);
                          Navigator.of(ctx).pop();
                          _showManageCategoriesDialog(context); // Volver a abrir el diálogo para reflejar los cambios
                        },
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showAddCategoryDialog(context);
                },
                child: Text('Añadir Categoría'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cerrar'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}
