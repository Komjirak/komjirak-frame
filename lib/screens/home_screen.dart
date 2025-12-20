import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildHeroCard(context),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Jump Back In',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ProjectProvider>(
                builder: (context, provider, child) {
                  if (provider.projects.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  return _buildProjectList(context, provider.projects);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, User ✨',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  "Let's create something cool",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D5A4A), Color(0xFF8B6B47)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'NEW PROJECT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1F1A),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Remix Your World',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Start fresh with new Gen Z...',
                style: TextStyle(color: Colors.white70),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/photo-selection');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: const Color(0xFF0A1F1A),
                ),
                child: const Text('Create New'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList(BuildContext context, List<Project> projects) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 16),
          child: Card(
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/collage-edit',
                  arguments: {'project': project},
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 48),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Edited ${_formatDate(project.updatedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No projects yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first collage',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Works'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'today';
    if (difference.inDays == 1) return '1d ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
