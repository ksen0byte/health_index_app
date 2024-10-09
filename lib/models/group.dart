class Group {
  int? id;
  final String name;

  Group({this.id, required this.name});

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() {
    return 'Group{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Group &&
        other.id == id && // Compare by `id` or any other unique identifier
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
