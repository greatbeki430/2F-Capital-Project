class Todo {
  String id;
  String title;
  String color;
  bool isPinned;
  DateTime? dueDate;
  DateTime? reminder;
  String? voiceInput;

  Todo({
    required this.id,
    required this.title,
    this.color = 'white',
    this.isPinned = false,
    this.dueDate,
    this.reminder,
    this.voiceInput,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'color': color,
      'isPinned': isPinned,
      'dueDate': dueDate?.toIso8601String(),
      'reminder': reminder?.toIso8601String(),
      'voiceInput': voiceInput,
    };
  }

  static Todo fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      color: json['color'],
      isPinned: json['isPinned'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      reminder:
          json['reminder'] != null ? DateTime.parse(json['reminder']) : null,
      voiceInput: json['voiceInput'],
    );
  }
}
