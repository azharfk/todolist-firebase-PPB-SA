class Todo {
  final String title;
  final String description;
  final bool isComplete;
  final String uid;

  Todo({
    required this.title,
    required this.description,
    required this.isComplete,
    required this.uid,
  });

  factory Todo.fromMap(Map<String, dynamic> data) {
    return Todo(
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isComplete: data['isComplete'] ?? false,
      uid: data['uid'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isComplete': isComplete,
      'uid': uid,
    };
  }
}
