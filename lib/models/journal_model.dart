class JournalEntry {
  final String date;
  final String wins;
  final String struggles;
  final int disciplineScore;

  JournalEntry({
    required this.date,
    required this.wins,
    required this.struggles,
    required this.disciplineScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'wins': wins,
      'struggles': struggles,
      'disciplineScore': disciplineScore,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      date: map['date'],
      wins: map['wins'],
      struggles: map['struggles'],
      disciplineScore: map['disciplineScore'],
    );
  }
}
