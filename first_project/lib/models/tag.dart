class Tag {
  final int id;
  final String name;

  Tag.Tag({
    required this.id,
    required this.name,
  });

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag.Tag(
      id: map['id'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}