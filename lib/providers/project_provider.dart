import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../repositories/project_repository.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectRepository _repository;
  
  List<Project> _projects = [];
  bool _isLoading = false;
  String? _error;

  ProjectProvider({ProjectRepository? repository})
      : _repository = repository ?? LocalProjectRepository();

  List<Project> get projects => List.unmodifiable(_projects);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProjects => _projects.isNotEmpty;

  /// 프로젝트 목록 로드
  Future<void> loadProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.getAllProjects();
      
      result.fold(
        (error) {
          _error = error.displayMessage;
          debugPrint('[ProjectProvider] Error loading projects: ${error.technicalDetails}');
        },
        (projects) {
          _projects = projects;
          _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          _error = null;
        },
      );
    } catch (e) {
      _error = '프로젝트를 불러오는 중 예상치 못한 오류가 발생했습니다.';
      debugPrint('[ProjectProvider] Unexpected error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 새 프로젝트 추가
  Future<bool> addProject(Project project) async {
    try {
      final result = await _repository.saveProject(project);
      
      return result.fold(
        (error) {
          _error = error.displayMessage;
          debugPrint('[ProjectProvider] Error adding project: ${error.technicalDetails}');
          notifyListeners();
          return false;
        },
        (success) {
          if (success) {
            _projects.insert(0, project);
            _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
            _error = null;
            notifyListeners();
            return true;
          }
          return false;
        },
      );
    } catch (e) {
      _error = '프로젝트 추가 중 예상치 못한 오류가 발생했습니다.';
      debugPrint('[ProjectProvider] Unexpected error: $e');
      notifyListeners();
      return false;
    }
  }

  /// 프로젝트 업데이트
  Future<bool> updateProject(Project project) async {
    try {
      final result = await _repository.saveProject(project);
      
      return result.fold(
        (error) {
          _error = error.displayMessage;
          debugPrint('[ProjectProvider] Error updating project: ${error.technicalDetails}');
          notifyListeners();
          return false;
        },
        (success) {
          if (success) {
            final index = _projects.indexWhere((p) => p.id == project.id);
            if (index != -1) {
              _projects[index] = project;
              _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
              _error = null;
              notifyListeners();
              return true;
            }
            return false;
          }
          return false;
        },
      );
    } catch (e) {
      _error = '프로젝트 업데이트 중 예상치 못한 오류가 발생했습니다.';
      debugPrint('[ProjectProvider] Unexpected error: $e');
      notifyListeners();
      return false;
    }
  }

  /// 프로젝트 삭제
  Future<bool> deleteProject(String projectId) async {
    try {
      final result = await _repository.deleteProject(projectId);
      
      return result.fold(
        (error) {
          _error = error.displayMessage;
          debugPrint('[ProjectProvider] Error deleting project: ${error.technicalDetails}');
          notifyListeners();
          return false;
        },
        (success) {
          if (success) {
            _projects.removeWhere((p) => p.id == projectId);
            _error = null;
            notifyListeners();
            return true;
          }
          return false;
        },
      );
    } catch (e) {
      _error = '프로젝트 삭제 중 예상치 못한 오류가 발생했습니다.';
      debugPrint('[ProjectProvider] Unexpected error: $e');
      notifyListeners();
      return false;
    }
  }

  /// ID로 프로젝트 가져오기
  Project? getProjectById(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
