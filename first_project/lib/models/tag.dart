class Tagg {
  final int id;
  final String name;

  Tagg({
    required this.id,
    required this.name,
  });

  factory Tagg.fromMap(Map<String, dynamic> map) {
    return Tagg(
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