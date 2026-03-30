class Task {
  final int id;
  final int listId;
  final String name;
  final bool isFinished;
  final String? imagePath;
  final int position;

  Task({
    required this.id,
    required this.listId,
    required this.name,
    required this.isFinished,
    this.imagePath,
    required this.position,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      listId: map['list_id'],
      name: map['name'],
      isFinished: map['is_finished'] == 1,
      imagePath: map['image_path'],
      position: map['position'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'list_id': listId,
      'name': name,
      'is_finished': isFinished ? 1 : 0,
      'image_path': imagePath,
      'position': position,
    };
  }
}
