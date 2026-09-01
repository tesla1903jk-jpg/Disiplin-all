enum GoalType { daily, weekly, monthly }

class Goal {
  final String id;
  final String title;
  final GoalType type;
  bool isCompleted;
  final String date;

  Goal({
    required this.id,
    required this.title,
    required this.type,
    this.isCompleted = false,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'isCompleted': isCompleted ? 1 : 0,
      'date': date,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      type: GoalType.values.byName(map['type']),
      isCompleted: map['isCompleted'] == 1,
      date: map['date'],
    );
  }
}
