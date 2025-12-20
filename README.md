# Komjirak Frame

> ✨ **GenZ를 위한 감각적인 사진 콜라주 앱** - *by @Komjirak Studio*

인스타그램 스토리, 틱톡, 스냅챗에 올릴 멋진 콜라주를 1-10장의 사진으로 쉽고 빠르게 만들어보세요!

🌐 **[Live Demo](https://komjirak.github.io/komjirak-frame/)**

---

## ✨ 주요 기능

### 📸 완벽한 사진 콜라주 플로우
1. **메인 화면** - 저장된 콜라주 프로젝트 관리
2. **사진 선택** - 갤러리 또는 카메라에서 1-10장 선택
3. **프레임 & 폰트** - 6가지 레이아웃 + 텍스트 오버레이
4. **미리보기** - 실시간 프리뷰 확인
5. **다운로드 & 공유** - 갤러리 저장 및 SNS 직접 공유

### 🎨 6가지 감각적인 레이아웃

1. **Classic** - 깔끔한 그리드 레이아웃
2. **Split** - 역동적인 분할 화면
3. **Mosaic** - 예술적인 모자이크 패턴
4. **Film** - 빈티지 필름 스트립 스타일
5. **Polaroid** - 폴라로이드 카메라 감성
6. **Bubbles** - 재미있는 원형 배치

### 💎 핵심 기능

- 📱 **1-10장 사진 선택** - 갤러리 & 카메라 지원
- 🎨 **6가지 프레임 템플릿** - 다양한 스타일
- ✍️ **텍스트 오버레이** - 폰트 선택 및 문구 삽입
- 💾 **갤러리 저장** - 고화질 이미지 저장
- 🔗 **SNS 직접 공유** - Instagram, TikTok, Snapchat 등
- 🎯 **프로젝트 관리** - 작업 내역 저장 및 불러오기
- 🌈 **GenZ 감성 디자인** - 라이트/다크 테마 지원
- ⚡ **빠른 퍼포먼스** - Provider 기반 상태 관리

---

## 📋 필수 요구사항

- **Flutter SDK** (3.0.0 이상)
- **Dart SDK**
- **Android Studio / Xcode** (모바일 개발용)
- **VS Code** 또는 다른 코드 에디터

---

## 🚀 설치 및 실행

### 1. 저장소 클론
```bash
git clone https://github.com/Komjirak/komjirak-frame.git
cd komjirak-frame
```

### 2. 의존성 설치
```bash
flutter pub get
```

### 3. 앱 실행
```bash
# 연결된 기기/에뮬레이터에서 실행
flutter run

# 특정 기기 선택
flutter devices
flutter run -d <device_id>

# 릴리즈 모드로 빌드
flutter build apk  # Android
flutter build ios  # iOS
```

---

## 📦 사용된 패키지

### 핵심 패키지
- **provider** (^6.1.1) - 상태 관리
- **image_picker** (^1.0.7) - 사진 선택
- **image** (^4.1.7) - 이미지 처리
- **flutter_image_compress** (^2.1.0) - 이미지 압축

### 저장 & 권한
- **path_provider** (^2.1.2) - 파일 시스템 접근
- **permission_handler** (^11.2.0) - 권한 관리
- **image_gallery_saver** (^2.0.3) - 갤러리 저장

### 공유 & UI
- **share_plus** (^7.2.2) - SNS 공유
- **flutter_staggered_grid_view** (^0.7.0) - 그리드 레이아웃
- **photo_view** (^0.14.0) - 사진 확대/축소

### 유틸리티
- **uuid** (^4.3.3) - 고유 ID 생성
- **intl** (^0.19.0) - 국제화 지원

전체 의존성은 [pubspec.yaml](pubspec.yaml)을 참조하세요.

---

## 🏗️ 프로젝트 구조

```
komjirak-frame/
├── lib/
│   ├── main.dart                      # 앱 진입점 + Provider 설정
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart         # 라이트/다크 테마
│   ├── models/
│   │   ├── collage_layout.dart        # 레이아웃 데이터 모델
│   │   ├── frame_template.dart        # 프레임 템플릿
│   │   └── project_model.dart         # 프로젝트 모델
│   ├── providers/
│   │   ├── photo_provider.dart        # 사진 상태 관리
│   │   └── project_provider.dart      # 프로젝트 상태 관리
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart       # 메인 화면
│   │   ├── photo_selection/
│   │   │   └── photo_selection_screen.dart  # 사진 선택
│   │   ├── collage_edit/
│   │   │   └── collage_edit_screen.dart     # 콜라주 편집
│   │   ├── preview/
│   │   │   └── preview_screen.dart    # 미리보기
│   │   └── export/
│   │       └── export_screen.dart     # 내보내기 & 공유
│   ├── services/
│   │   ├── image_service.dart         # 이미지 처리
│   │   ├── storage_service.dart       # 로컬 저장소 관리
│   │   └── share_service.dart         # SNS 공유
│   ├── widgets/
│   │   ├── collage_canvas.dart        # 콜라주 캔버스
│   │   ├── frame_selector.dart        # 프레임 선택기
│   │   ├── photo_grid_item.dart       # 사진 그리드 아이템
│   │   └── project_card.dart          # 프로젝트 카드
│   └── utils/
│       └── constants.dart             # 상수 정의
├── docs/
│   └── FEATURES.md                    # 기능 명세서
├── pubspec.yaml                       # 프로젝트 설정
└── README.md                          # 이 파일
```

---

## 💻 개발 가이드

### 주요 화면 플로우

```
HomeScreen (프로젝트 관리)
    ↓
PhotoSelectionScreen (사진 선택: 1-10장)
    ↓
CollageEditScreen (프레임 선택 & 텍스트 삽입)
    ↓
PreviewScreen (미리보기)
    ↓
ExportScreen (저장 & 공유)
```

# Run with hot reload enabled (default)
flutter run --hot

# Run in debug mode
flutter run --debug
```

### Code Quality

```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format .

# Run tests
flutter test
```

### Adding New Layouts

1. Create a new layout file in `lib/layouts/`
2. Implement the layout widget extending the base layout class
3. Register the layout in the layout manager
4. Add preview assets if needed

## 🏭 Building for Production

### Android APK

```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release

# Split APK by ABI (reduces size)
flutter build apk --split-per-abi --release
```

The generated APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
# Build for iOS
flutter build ios --release

# Build IPA (requires Mac)
flutter build ipa --release
```

**Note:** iOS builds require a Mac with Xcode installed and proper code signing setup.

### Web

```bash
# Build for web
flutter build web --release

# Build with web renderer options
flutter build web --web-renderer canvaskit --release  # Better performance
flutter build web --web-renderer html --release       # Smaller size
```

The web build output will be in the `build/web/` directory.

### Desktop

```bash
# Build for Windows
flutter build windows --release

# Build for macOS
flutter build macos --release

# Build for Linux
flutter build linux --release
```

## 🚀 Deployment

### Web Deployment (GitHub Pages)

The project is deployed at: https://komjirak.github.io/komjirak-frame/

To deploy updates:
```bash
flutter build web --release --base-href "/komjirak-frame/"
# Copy contents of build/web/ to your deployment target
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Komjirak**

- GitHub: [@Komjirak](https://github.com/Komjirak)
- Project Link: [https://github.com/Komjirak/komjirak-frame](https://github.com/Komjirak/komjirak-frame)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- All contributors who have helped improve this project
- The open-source community for the excellent packages used in this project

## 📧 Support

If you encounter any issues or have questions, please [open an issue](https://github.com/Komjirak/komjirak-frame/issues) on GitHub.

---

Made with ❤️ using Flutter
