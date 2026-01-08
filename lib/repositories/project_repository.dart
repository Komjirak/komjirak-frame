import '../models/project_model.dart';
import '../core/errors/storage_exception.dart';
import '../core/errors/result.dart';
import '../services/storage_service.dart';

/// 프로젝트 저장소 인터페이스
abstract class ProjectRepository {
  Future<Result<List<Project>, StorageException>> getAllProjects();
  Future<Result<Project, StorageException>> getProject(String id);
  Future<Result<bool, StorageException>> saveProject(Project project);
  Future<Result<bool, StorageException>> deleteProject(String id);
}

/// 로컬 파일 시스템 기반 프로젝트 저장소
class LocalProjectRepository implements ProjectRepository {
  @override
  Future<Result<List<Project>, StorageException>> getAllProjects() async {
    try {
      final projects = await StorageService.getAllProjects();
      return Result.success(projects);
    } catch (e) {
      return Result.failure(StorageException(
        StorageError.unknown,
        '프로젝트 목록을 불러오는 중 오류가 발생했습니다.',
        e.toString(),
        e,
      ));
    }
  }

  @override
  Future<Result<Project, StorageException>> getProject(String id) async {
    return await StorageService.getProject(id);
  }

  @override
  Future<Result<bool, StorageException>> saveProject(Project project) async {
    return await StorageService.saveProject(project);
  }

  @override
  Future<Result<bool, StorageException>> deleteProject(String id) async {
    return await StorageService.deleteProject(id);
  }
}
