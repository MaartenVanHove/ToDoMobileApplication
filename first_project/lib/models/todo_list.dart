class TodoList {
  final int id;
  final int collectionId;
  final String name;
  final String? imagePath;

  TodoList({
    required this.id,
    required this.collectionId,
    required this.name,
    required this.imagePath,
  });

  factory TodoList.fromMap(Map<String, dynamic> map) {
    return TodoList(
      id: map['id'],
      collectionId: map['collection_id'],
      name: map['name'],
      imagePath: map['image_path']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collection_id': collectionId,
      'name': name,
      'image_path': imagePath
    };
  }
}