import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ideas_provider.dart';
import '../widgets/idea_item.dart';
import 'add_idea_screen.dart';

class IdeasScreen extends StatefulWidget {
  const IdeasScreen({super.key});

  @override
  State<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends State<IdeasScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) {
        return;
      }
      context.read<IdeasProvider>().initializeIdeas();
    });
  }

  Future<void> _refreshIdeas() async {
    try {
      await context.read<IdeasProvider>().fetchIdeas();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to refresh ideas.')));
    }
  }

  Future<void> _deleteIdea(String ideaId) async {
    try {
      await context.read<IdeasProvider>().deleteIdea(ideaId);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete the idea.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final IdeasProvider ideasProvider = context.watch<IdeasProvider>();

    Widget body;

    if (ideasProvider.isLoading && ideasProvider.ideas.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (ideasProvider.ideas.isEmpty) {
      body = RefreshIndicator(
        onRefresh: _refreshIdeas,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            const Center(
              child: Text(
                'No ideas found.\nTap + to add a new idea.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _refreshIdeas,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: ideasProvider.ideas.length,
          itemBuilder: (context, index) {
            final idea = ideasProvider.ideas[index];
            return IdeaItem(
              idea: idea,
              onDelete: () => _deleteIdea(idea.id),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideas App'),
        bottom: ideasProvider.isFetching && ideasProvider.ideas.isNotEmpty
            ? const PreferredSize(
                preferredSize: Size.fromHeight(3),
                child: LinearProgressIndicator(minHeight: 3),
              )
            : null,
      ),
      body: Column(
        children: [
          if (ideasProvider.errorMessage != null)
            Container(
              width: double.infinity,
              color: Colors.orange.shade100,
              padding: const EdgeInsets.all(12),
              child: Text(
                ideasProvider.errorMessage!,
                style: const TextStyle(color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddIdeaScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
