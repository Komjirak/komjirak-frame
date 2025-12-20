import 'package:flutter/foundation.dart';
import '../models/project_model.dart';

class ProjectProvider with ChangeNotifier {
  final List<Project> _projects = [];

  List<Project> get projects => List.unmodifiable(_projects);

  void addProject(Project project) {
    _projects.insert(0, project);
    notifyListeners();
  }

  void updateProject(Project project) {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  void deleteProject(String projectId) {
    _projects.removeWhere((p) => p.id == projectId);
    notifyListeners();
  }

  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
