import 'package:flutter_test/flutter_test.dart';
import 'package:komjirak_frame/providers/project_provider.dart';
import 'package:komjirak_frame/models/project_model.dart';
import 'package:komjirak_frame/repositories/project_repository.dart';
import 'package:komjirak_frame/core/errors/storage_exception.dart';
import 'package:komjirak_frame/core/errors/result.dart';

/// Mock Repository for testing
class MockProjectRepository implements ProjectRepository {
  final List<Project> _projects = [];
  bool shouldFail = false;

  @override
  Future<Result<List<Project>, StorageException>> getAllProjects() async {
    if (shouldFail) {
      return Result.failure(StorageException(
        StorageError.unknown,
        'Test error',
      ));
    }
    return Result.success(List.from(_projects));
  }

  @override
  Future<Result<Project, StorageException>> getProject(String id) async {
    if (shouldFail) {
      return Result.failure(StorageException(
        StorageError.fileNotFound,
        'Project not found',
      ));
    }
    try {
      final project = _projects.firstWhere((p) => p.id == id);
      return Result.success(project);
    } catch (e) {
      return Result.failure(StorageException(
        StorageError.fileNotFound,
        'Project not found',
      ));
    }
  }

  @override
  Future<Result<bool, StorageException>> saveProject(Project project) async {
    if (shouldFail) {
      return Result.failure(StorageException(
        StorageError.unknown,
        'Save failed',
      ));
    }
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      _projects[index] = project;
    } else {
      _projects.add(project);
    }
    return Result.success(true);
  }

  @override
  Future<Result<bool, StorageException>> deleteProject(String id) async {
    if (shouldFail) {
      return Result.failure(StorageException(
        StorageError.unknown,
        'Delete failed',
      ));
    }
    _projects.removeWhere((p) => p.id == id);
    return Result.success(true);
  }
}

void main() {
  group('ProjectProvider', () {
    late ProjectProvider provider;
    late MockProjectRepository mockRepository;

    setUp(() {
      mockRepository = MockProjectRepository();
      provider = ProjectProvider(repository: mockRepository);
    });

    test('should initialize with empty projects', () {
      expect(provider.projects, isEmpty);
      expect(provider.isLoading, isFalse);
      expect(provider.hasProjects, isFalse);
    });

    test('should load projects successfully', () async {
      final project = Project(
        name: 'Test Project',
        photoPaths: ['path1'],
      );
      await mockRepository.saveProject(project);

      await provider.loadProjects();

      expect(provider.isLoading, isFalse);
      expect(provider.projects.length, equals(1));
      expect(provider.projects.first.name, equals('Test Project'));
      expect(provider.error, isNull);
    });

    test('should handle loading error', () async {
      mockRepository.shouldFail = true;

      await provider.loadProjects();

      expect(provider.isLoading, isFalse);
      expect(provider.error, isNotNull);
    });

    test('should add project successfully', () async {
      final project = Project(
        name: 'New Project',
        photoPaths: [],
      );

      final result = await provider.addProject(project);

      expect(result, isTrue);
      expect(provider.projects.length, equals(1));
      expect(provider.projects.first.name, equals('New Project'));
    });

    test('should handle add project error', () async {
      mockRepository.shouldFail = true;

      final project = Project(
        name: 'New Project',
        photoPaths: [],
      );

      final result = await provider.addProject(project);

      expect(result, isFalse);
      expect(provider.error, isNotNull);
    });

    test('should update project successfully', () async {
      final project = Project(
        name: 'Original',
        photoPaths: [],
      );
      await provider.addProject(project);

      final updated = project.copyWith(name: 'Updated');
      final result = await provider.updateProject(updated);

      expect(result, isTrue);
      expect(provider.projects.first.name, equals('Updated'));
    });

    test('should delete project successfully', () async {
      final project = Project(
        name: 'To Delete',
        photoPaths: [],
      );
      await provider.addProject(project);

      final result = await provider.deleteProject(project.id);

      expect(result, isTrue);
      expect(provider.projects, isEmpty);
    });

    test('should get project by id', () {
      final project = Project(
        name: 'Test',
        photoPaths: [],
      );
      provider.addProject(project);

      final found = provider.getProjectById(project.id);

      expect(found, isNotNull);
      expect(found!.name, equals('Test'));
    });

    test('should clear error', () {
      provider.clearError();
      expect(provider.error, isNull);
    });
  });
}
