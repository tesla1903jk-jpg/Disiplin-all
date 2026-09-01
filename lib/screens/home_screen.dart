import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/database_helper.dart';
import 'journal_screen.dart';
import 'meditation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _goalController = TextEditingController();
  final String _today = DateTime.now().toIso8601String().split('T')[0];
  List<Goal> _goals = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => _loadGoals());
    _loadGoals();
  }

  GoalType get _currentType {
    switch (_tabController.index) {
      case 0: return GoalType.daily;
      case 1: return GoalType.weekly;
      case 2: return GoalType.monthly;
      default: return GoalType.daily;
    }
  }

  Future<void> _loadGoals() async {
    final goals = await DatabaseHelper.instance.getGoalsByDateAndType(_today, _currentType);
    setState(() => _goals = goals);
  }

  Future<void> _addGoal() async {
    if (_goalController.text.trim().isEmpty) return;
    final newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _goalController.text.trim(),
      type: _currentType,
      date: _today,
    );
    await DatabaseHelper.instance.insertGoal(newGoal);
    _goalController.clear();
    _loadGoals();
  }

  Future<void> _toggleGoal(Goal goal) async {
    await DatabaseHelper.instance.updateGoalStatus(goal.id, !goal.isCompleted);
    _loadGoals();
  }

  Future<void> _deleteGoal(String id) async {
    await DatabaseHelper.instance.deleteGoal(id);
    _loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disiplin & Odak'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.self_improvement, color: Colors.deepOrangeAccent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MeditationScreen()),
              );
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.deepOrangeAccent,
          tabs: const [
            Tab(text: 'Günlük'),
            Tab(text: 'Haftalık'),
            Tab(text: 'Aylık'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1F1F),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.format_quote, color: Colors.deepOrangeAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"Disiplin, hedefler ile başarı arasındaki köprüdür."',
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goalController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Yeni hedef ekle...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 40, color: Colors.deepOrangeAccent),
                  onPressed: _addGoal,
                ),
              ],
            ),
          ),
          Expanded(
            child: _goals.isEmpty
                ? const Center(child: Text('Henüz eklenmiş bir hedef yok.'))
                : ListView.builder(
                    itemCount: _goals.length,
                    itemBuilder: (context, index) {
                      final goal = _goals[index];
                      return ListTile(
                        leading: Checkbox(
                          activeColor: Colors.deepOrangeAccent,
                          value: goal.isCompleted,
                          onChanged: (_) => _toggleGoal(goal),
                        ),
                        title: Text(
                          goal.title,
                          style: TextStyle(
                            decoration: goal.isCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteGoal(goal.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepOrangeAccent,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JournalScreen()),
          );
        },
        icon: const Icon(Icons.book, color: Colors.white),
        label: const Text('Sorgulama & Günlük', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
