# Komjirak Frame

A beautiful Flutter application for creating stunning photo collages with multiple layout options. Transform your memories into artistic frames with ease!

🌐 **[Live Demo](https://komjirak.github.io/komjirak-frame/)**

## ✨ Features

Komjirak Frame offers 6 unique layout styles to showcase your photos:

1. **Classic** - Traditional grid layout for a clean, organized look
2. **Split** - Dynamic split-screen arrangements for creative compositions
3. **Mosaic** - Artistic mosaic patterns for a unique visual appeal
4. **Film** - Vintage film strip style reminiscent of classic photography
5. **Polaroid** - Instant camera-inspired frames with authentic polaroid aesthetics
6. **Bubbles** - Playful circular arrangements for a fun, modern touch

### Key Capabilities

- 📸 Multiple photo selection and arrangement
- 🎨 Six distinct layout templates
- 💾 Save and share your creations
- 📱 Cross-platform support (Android, iOS, Web)
- 🎯 Intuitive and user-friendly interface
- 🔄 Real-time preview of layouts

## 📋 Prerequisites

- Flutter SDK (latest stable version recommended)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- A code editor (VS Code, Android Studio, or IntelliJ IDEA)

## 🚀 Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Komjirak/komjirak-frame.git
   cd komjirak-frame
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## 📦 Dependencies

This project uses the following Flutter packages:

- **provider** - State management solution for Flutter applications
- **image_picker** - Select images from gallery or camera
- **path_provider** - Access commonly used locations on the filesystem
- **share_plus** - Share content with other apps
- **permission_handler** - Manage app permissions across platforms

For the complete list of dependencies with versions, see [pubspec.yaml](pubspec.yaml).

## 🏗️ Project Structure

```
komjirak-frame/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── models/                   # Data models
│   ├── providers/                # State management (Provider)
│   ├── screens/                  # UI screens
│   ├── widgets/                  # Reusable widgets
│   ├── layouts/                  # Frame layout implementations
│   │   ├── classic_layout.dart
│   │   ├── split_layout.dart
│   │   ├── mosaic_layout.dart
│   │   ├── film_layout.dart
│   │   ├── polaroid_layout.dart
│   │   └── bubbles_layout.dart
│   └── utils/                    # Utility functions and helpers
├── assets/                       # Images, fonts, and other assets
├── test/                         # Unit and widget tests
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
├── web/                          # Web-specific files
└── pubspec.yaml                  # Project dependencies
```

## 💻 Development Guide

### Running in Development Mode

```bash
# Run on a connected device/emulator
flutter run

# Run on a specific device
flutter devices
flutter run -d <device_id>

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
