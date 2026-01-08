import 'package:flutter_test/flutter_test.dart';
import 'package:komjirak_frame/services/storage_service.dart';
import 'package:komjirak_frame/models/project_model.dart';
import 'package:komjirak_frame/core/errors/storage_exception.dart';

void main() {
  group('StorageService', () {
    test('should save and load projects correctly', () async {
      final project = Project(
        name: 'Test Project',
        photoPaths: ['path1', 'path2'],
      );
      
      final saveResult = await StorageService.saveProject(project);
      expect(saveResult.isSuccess, isTrue);
      
      final loadResult = await StorageService.getProject(project.id);
      expect(loadResult.isSuccess, isTrue);
      
      final loadedProject = loadResult.valueOrNull;
      expect(loadedProject, isNotNull);
      expect(loadedProject!.name, equals(project.name));
      expect(loadedProject.photoPaths.length, equals(2));
    });
    
    test('should handle file not found gracefully', () async {
      final result = await StorageService.getProject('non-existent-id');
      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<StorageException>());
      
      final error = result.errorOrNull as StorageException;
      expect(error.type, equals(StorageError.fileNotFound));
    });
    
    test('should update existing project', () async {
      final project = Project(
        name: 'Original Name',
        photoPaths: ['path1'],
      );
      
      await StorageService.saveProject(project);
      
      final updatedProject = project.copyWith(
        name: 'Updated Name',
      );
      
      final result = await StorageService.saveProject(updatedProject);
      expect(result.isSuccess, isTrue);
      
      final loadedResult = await StorageService.getProject(project.id);
      expect(loadedResult.isSuccess, isTrue);
      
      final loaded = loadedResult.valueOrNull;
      expect(loaded!.name, equals('Updated Name'));
    });
    
    test('should delete project correctly', () async {
      final project = Project(
        name: 'To Delete',
        photoPaths: ['path1'],
      );
      
      await StorageService.saveProject(project);
      
      final deleteResult = await StorageService.deleteProject(project.id);
      expect(deleteResult.isSuccess, isTrue);
      
      final loadResult = await StorageService.getProject(project.id);
      expect(loadResult.isFailure, isTrue);
    });
    
    test('should return failure when deleting non-existent project', () async {
      final result = await StorageService.deleteProject('non-existent-id');
      expect(result.isFailure, isTrue);
      
      final error = result.errorOrNull as StorageException;
      expect(error.type, equals(StorageError.fileNotFound));
    });
  });
}
