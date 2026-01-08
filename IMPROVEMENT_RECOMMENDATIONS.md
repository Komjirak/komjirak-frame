# 콜라주/매거진 서비스 개선 제안서

## 📋 개요
현재 코드베이스를 검토한 결과, 다음과 같은 개선점들을 발견했습니다. 우선순위별로 정리했습니다.

---

## 🔴 높은 우선순위 (즉시 개선 권장)

### 1. 에러 처리 및 예외 처리 개선

#### 문제점
- 일부 메서드에서 에러가 조용히 무시됨 (`debugPrint`만 사용)
- 사용자 친화적인 에러 메시지 부족
- 에러 복구 메커니즘 부재

#### 개선 방안
```dart
// 현재: storage_service.dart
static Future<bool> deleteProject(String projectId) async {
  try {
    // ... 코드 ...
    return true;
  } catch (e) {
    debugPrint('Error deleting project: $e');  // ❌ 조용히 실패
    return false;
  }
}

// 개선: 명확한 에러 타입과 사용자 메시지
enum StorageError {
  fileNotFound,
  permissionDenied,
  diskFull,
  unknown,
}

class StorageException implements Exception {
  final StorageError type;
  final String userMessage;
  final String? technicalDetails;
  
  StorageException(this.type, this.userMessage, [this.technicalDetails]);
}

static Future<Result<bool, StorageException>> deleteProject(String projectId) async {
  try {
    // ... 코드 ...
    return Result.success(true);
  } on FileSystemException catch (e) {
    return Result.failure(StorageException(
      StorageError.fileNotFound,
      '프로젝트 파일을 찾을 수 없습니다.',
      e.message,
    ));
  } catch (e) {
    return Result.failure(StorageException(
      StorageError.unknown,
      '프로젝트 삭제 중 오류가 발생했습니다.',
      e.toString(),
    ));
  }
}
```

**영향 파일:**
- `lib/services/storage_service.dart`
- `lib/services/image_service.dart`
- `lib/providers/project_provider.dart`
- `lib/providers/photo_provider.dart`

---

### 2. 메모리 관리 및 성능 최적화

#### 문제점
- 큰 이미지 처리 시 메모리 부족 가능성
- 이미지 캐싱 메커니즘 부재
- 위젯 리빌드 최적화 부족

#### 개선 방안

**2.1 이미지 캐싱 추가**
```dart
// lib/services/image_cache_service.dart (신규)
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheService {
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'komjirak_images',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 100,
    ),
  );
  
  static Future<File> getCachedImage(String url) async {
    return await _cacheManager.getSingleFile(url);
  }
  
  static Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }
}
```

**2.2 이미지 리사이징 최적화**
```dart
// lib/services/image_service.dart 개선
static Future<File?> resizeImage(
  File file, {
  required int width,
  required int height,
  int? maxMemoryMB = 50,  // 메모리 제한 추가
}) async {
  try {
    // 파일 크기 확인
    final fileSize = await file.length();
    if (fileSize > maxMemoryMB! * 1024 * 1024) {
      // 큰 파일은 스트리밍 방식으로 처리
      return await _resizeImageStreaming(file, width, height);
    }
    
    // 기존 방식
    final bytes = await file.readAsBytes();
    // ... 나머지 코드
  } catch (e) {
    // 에러 처리
  }
}
```

**2.3 위젯 리빌드 최적화**
```dart
// collage_canvas.dart 개선
class _CollageCanvasState extends State<CollageCanvas> {
  // const 생성자 사용 가능한 위젯은 const로
  // 불필요한 리빌드 방지
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(  // 이미 있음 - 좋음!
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // 이미지 셀들을 메모이제이션
              ..._buildCachedCells(constraints),
            ],
          );
        },
      ),
    );
  }
  
  List<Widget> _buildCachedCells(BoxConstraints constraints) {
    // 이미 빌드된 셀은 재사용
    return List.generate(
      widget.imagePaths.length.clamp(0, _editableCells.length),
      (index) => _buildCell(index, constraints),
    );
  }
}
```

**영향 파일:**
- `lib/services/image_service.dart`
- `lib/widgets/collage_canvas.dart`
- `lib/screens/collage_edit_screen.dart`

---

### 3. 데이터 일관성 및 무결성

#### 문제점
- 프로젝트 삭제 시 관련 이미지 파일 정리 불완전
- 썸네일 생성 실패 시 프로젝트 저장 실패 가능성
- JSON 저장 시 동시성 문제 가능성

#### 개선 방안

**3.1 트랜잭션 기반 저장**
```dart
// lib/services/storage_service.dart
static Future<bool> saveProject(Project project) async {
  try {
    // 1. 임시 파일에 먼저 저장
    final tempFile = File('${appDir.path}/$_projectsFileName.tmp');
    final projects = await getAllProjects();
    
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) {
      projects[index] = project;
    } else {
      projects.add(project);
    }
    
    final jsonList = projects.map((p) => p.toJson()).toList();
    await tempFile.writeAsString(json.encode(jsonList));
    
    // 2. 썸네일 생성 (비동기, 실패해도 계속 진행)
    if (project.thumbnailPath == null) {
      _generateThumbnailAsync(project);
    }
    
    // 3. 원자적 교체 (rename은 원자적 연산)
    final mainFile = File('${appDir.path}/$_projectsFileName');
    await tempFile.rename(mainFile.path);
    
    return true;
  } catch (e) {
    // 임시 파일 정리
    try {
      await tempFile.delete();
    } catch (_) {}
    rethrow;
  }
}

static Future<void> _generateThumbnailAsync(Project project) async {
  try {
    if (project.photoPaths.isNotEmpty) {
      final thumbnail = await ImageService.createThumbnail(
        File(project.photoPaths.first),
      );
      if (thumbnail != null) {
        final updatedProject = project.copyWith(
          thumbnailPath: thumbnail.path,
        );
        await saveProject(updatedProject);
      }
    }
  } catch (e) {
    debugPrint('Thumbnail generation failed: $e');
    // 실패해도 프로젝트는 저장됨
  }
}
```

**3.2 프로젝트 삭제 시 정리 개선**
```dart
static Future<bool> deleteProject(String projectId) async {
  try {
    final projects = await getAllProjects();
    final project = projects.firstWhere((p) => p.id == projectId);
    
    // 관련 파일 삭제 (병렬 처리)
    final deleteTasks = <Future>[];
    
    if (project.thumbnailPath != null) {
      deleteTasks.add(deleteImage(project.thumbnailPath!));
    }
    
    // 프로젝트 이미지 파일들도 삭제 (선택적)
    for (final photoPath in project.photoPaths) {
      // 임시 파일인 경우에만 삭제
      if (photoPath.contains('temp') || photoPath.contains('cache')) {
        deleteTasks.add(deleteImage(photoPath));
      }
    }
    
    await Future.wait(deleteTasks, eagerError: false);
    
    // 프로젝트 목록에서 제거
    projects.removeWhere((p) => p.id == projectId);
    
    // 저장
    final appDir = await getAppDirectory();
    final file = File('$appDir/$_projectsFileName');
    final jsonList = projects.map((p) => p.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
    
    return true;
  } catch (e) {
    debugPrint('Error deleting project: $e');
    return false;
  }
}
```

**영향 파일:**
- `lib/services/storage_service.dart`
- `lib/providers/project_provider.dart`

---

## 🟡 중간 우선순위 (단기 개선 권장)

### 4. 사용자 경험 개선

#### 4.1 로딩 상태 표시 개선
```dart
// 현재: 단순 CircularProgressIndicator
// 개선: 진행률 표시 + 취소 가능

class LoadingDialog extends StatelessWidget {
  final String message;
  final double? progress;
  final VoidCallback? onCancel;
  
  const LoadingDialog({
    required this.message,
    this.progress,
    this.onCancel,
  });
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (progress != null)
            LinearProgressIndicator(value: progress)
          else
            const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
          if (onCancel != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onCancel,
              child: const Text('취소'),
            ),
          ],
        ],
      ),
    );
  }
}
```

#### 4.2 오프라인 처리
```dart
// lib/services/connectivity_service.dart (신규)
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final Connectivity _connectivity = Connectivity();
  
  static Stream<bool> get isConnectedStream async* {
    await for (final result in _connectivity.onConnectivityChanged) {
      yield result != ConnectivityResult.none;
    }
  }
  
  static Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}

// 사용 예시
Future<void> saveProject(Project project) async {
  // 오프라인 상태 확인
  if (!await ConnectivityService.isConnected) {
    // 로컬 큐에 저장
    await _saveToOfflineQueue(project);
    throw OfflineException('오프라인 상태입니다. 연결 후 자동으로 저장됩니다.');
  }
  
  // 온라인 저장 로직
}
```

**영향 파일:**
- 모든 화면 파일들
- `lib/services/storage_service.dart`

---

### 5. 코드 구조 및 아키텍처 개선

#### 5.1 Repository 패턴 도입
```dart
// lib/repositories/project_repository.dart (신규)
abstract class ProjectRepository {
  Future<List<Project>> getAllProjects();
  Future<Project?> getProject(String id);
  Future<bool> saveProject(Project project);
  Future<bool> deleteProject(String id);
}

class LocalProjectRepository implements ProjectRepository {
  final StorageService _storage;
  
  LocalProjectRepository(this._storage);
  
  @override
  Future<List<Project>> getAllProjects() async {
    return await _storage.getAllProjects();
  }
  
  // ... 나머지 구현
}

// Provider에서 사용
class ProjectProvider with ChangeNotifier {
  final ProjectRepository _repository;
  
  ProjectProvider({ProjectRepository? repository})
      : _repository = repository ?? LocalProjectRepository(StorageService());
  
  Future<void> loadProjects() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _projects = await _repository.getAllProjects();
      _projects.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    } catch (e) {
      _error = 'Failed to load projects: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

#### 5.2 상수 중앙 관리
```dart
// lib/utils/constants.dart 개선
class AppConstants {
  // 이미지 관련
  static const int defaultImageQuality = 85;
  static const int highImageQuality = 95;
  static const int thumbnailSize = 200;
  static const int previewSize = 800;
  static const int exportSize = 2048;
  static const int maxImageSizeMB = 50;
  
  // 레이아웃 관련
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 20.0;
  static const double cardElevation = 2.0;
  
  // 애니메이션
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // 제한
  static const int maxPhotosPerCollage = 12;
  static const int minPhotosPerCollage = 1;
  
  // 파일 경로
  static const String projectsFileName = 'projects.json';
  static const String cacheDirectoryName = 'komjirak_cache';
  
  // 에러 메시지
  static const String errorImageLoad = '이미지를 불러올 수 없습니다';
  static const String errorSaveFailed = '저장에 실패했습니다';
  static const String errorPermissionDenied = '권한이 거부되었습니다';
}
```

**영향 파일:**
- 전체 코드베이스 리팩토링 필요

---

### 6. 테스트 코드 추가

#### 현재 상태
- `test/widget_test.dart`만 존재하고 실제 테스트 없음

#### 개선 방안
```dart
// test/services/storage_service_test.dart
void main() {
  group('StorageService', () {
    test('should save and load projects correctly', () async {
      final project = Project(
        name: 'Test Project',
        photoPaths: ['path1', 'path2'],
      );
      
      final saved = await StorageService.saveProject(project);
      expect(saved, isTrue);
      
      final loaded = await StorageService.getProject(project.id);
      expect(loaded, isNotNull);
      expect(loaded!.name, equals(project.name));
    });
    
    test('should handle file not found gracefully', () async {
      final project = await StorageService.getProject('non-existent-id');
      expect(project, isNull);
    });
  });
}

// test/providers/project_provider_test.dart
void main() {
  group('ProjectProvider', () {
    late ProjectProvider provider;
    
    setUp(() {
      provider = ProjectProvider();
    });
    
    test('should load projects on initialization', () async {
      await provider.loadProjects();
      expect(provider.isLoading, isFalse);
    });
    
    test('should add project correctly', () async {
      final project = Project(
        name: 'New Project',
        photoPaths: [],
      );
      
      final result = await provider.addProject(project);
      expect(result, isTrue);
      expect(provider.projects.length, greaterThan(0));
    });
  });
}
```

**추가 필요 패키지:**
```yaml
dev_dependencies:
  mockito: ^5.4.4
  build_runner: ^2.4.7
```

---

## 🟢 낮은 우선순위 (장기 개선 권장)

### 7. 기능 개선

#### 7.1 이미지 편집 기능 추가
- 밝기/대비 조정
- 필터 적용
- 크롭/회전

#### 7.2 프로젝트 백업/복원
- 클라우드 저장소 연동 (iCloud, Google Drive)
- 프로젝트 내보내기/가져오기

#### 7.3 사용자 설정
- 테마 변경 (다크/라이트)
- 기본 품질 설정
- 자동 저장 옵션

---

## 📊 우선순위별 작업 계획

### Phase 1 (1-2주)
1. ✅ 에러 처리 개선
2. ✅ 메모리 관리 최적화
3. ✅ 데이터 일관성 개선

### Phase 2 (2-3주)
4. ✅ 사용자 경험 개선
5. ✅ 코드 구조 개선
6. ✅ 기본 테스트 추가

### Phase 3 (장기)
7. ✅ 기능 확장
8. ✅ 성능 모니터링
9. ✅ 사용자 피드백 반영

---

## 🔧 기술 부채 정리

### 발견된 문제들
1. **하드코딩된 값들**
   - `collage_canvas.dart`의 `.clamp(3, 4)` 반복
   - 매직 넘버들 (픽셀 비율, 품질 값 등)

2. **중복 코드**
   - 이미지 로딩 로직이 여러 곳에 분산
   - 에러 처리 패턴이 일관되지 않음

3. **타입 안정성**
   - `Map<String, dynamic>` 남용
   - 옵셔널 체이닝 부족

4. **문서화 부족**
   - 주석이 거의 없음
   - API 문서 없음

---

## 📝 결론

현재 코드베이스는 기본적인 기능은 잘 구현되어 있으나, 프로덕션 환경에서의 안정성과 사용자 경험을 위해 위의 개선사항들을 단계적으로 적용하는 것을 권장합니다.

특히 **에러 처리**, **메모리 관리**, **데이터 일관성** 부분은 즉시 개선이 필요합니다.
