class Idea {
  final String id;
  final String title;
  final String description;

  const Idea({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  factory Idea.fromFirebase(String id, Map<String, dynamic> json) {
    return Idea(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }

  Map<String, dynamic> toFirebaseJson() {
    return {
      'title': title,
      'description': description,
    };
  }
}
