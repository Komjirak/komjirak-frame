import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../services/storage_service.dart';

class ProjectProvider with ChangeNotifier {
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  List<Project> get projects => List.unmodifiable(_projects);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProjects => _projects.isNotEmpty;

  // Load all projects from storage
  Future<void> loadProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await StorageService.getAllProjects();
      _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      _error = 'Failed to load projects: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new project
  Future<bool> addProject(Project project) async {
    try {
      final success = await StorageService.saveProject(project);
      if (success) {
        _projects.insert(0, project);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to add project: $e';
      debugPrint(_error);
      return false;
    }
  }

  // Update existing project
  Future<bool> updateProject(Project project) async {
    try {
      final success = await StorageService.saveProject(project);
      if (success) {
        final index = _projects.indexWhere((p) => p.id == project.id);
        if (index != -1) {
          _projects[index] = project;
          _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to update project: $e';
      debugPrint(_error);
      return false;
    }
  }

  // Delete a project
  Future<bool> deleteProject(String projectId) async {
    try {
      final success = await StorageService.deleteProject(projectId);
      if (success) {
        _projects.removeWhere((p) => p.id == projectId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'Failed to delete project: $e';
      debugPrint(_error);
      return false;
    }
  }

  // Get project by ID
  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
