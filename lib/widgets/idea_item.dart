import 'package:flutter/material.dart';

import '../models/idea.dart';

class IdeaItem extends StatelessWidget {
  const IdeaItem({
    super.key,
    required this.idea,
    required this.onDelete,
  });

  final Idea idea;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(
          idea.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(idea.description),
        ),
        trailing: IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ),
    );
  }
}
