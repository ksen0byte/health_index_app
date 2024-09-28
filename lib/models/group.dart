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
}
