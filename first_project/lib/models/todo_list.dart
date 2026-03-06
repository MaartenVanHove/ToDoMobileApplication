import 'package:first_project/models/tag.dart';

class TodoList {
  final int id;
  final int collectionId;
  final String name;
  final String? imagePath;
  final int colorId;

  final List<Tag> tags; // The list of tag objects

  TodoList({
    required this.id,
    required this.collectionId,
    required this.name,
    this.imagePath,
    required this.colorId,
    this.tags = const [], // Initialized as empty, never null
  });

  // Convert Database Map to Dart Object
  factory TodoList.fromMap(Map<String, dynamic> map, {List<Tag> tags = const []}) {
    return TodoList(
      id: map['id'],
      collectionId: map['collection_id'],
      name: map['name'],
      imagePath: map['image_path'],
      colorId: map['color_id'],
      tags: tags, // We pass the tags in here after fetching them
    );
  }

  // Convert Dart Object to Database Map (for Inserts/Updates)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collection_id': collectionId,
      'name': name,
      'image_path': imagePath,
      'color_id': colorId,
      // DO NOT put tags here because they live in a different table!
    };
  }
}