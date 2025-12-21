import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/photo_selection_screen.dart';
import 'screens/collage_edit_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/export_screen.dart';
import 'providers/photo_provider.dart';
import 'providers/project_provider.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const KomjirakFrameApp());
}

class KomjirakFrameApp extends StatelessWidget {
  const KomjirakFrameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PhotoProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: MaterialApp(
        title: 'Komjirak Frame',
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        // Set the initial route to splash screen
        initialRoute: '/',
        // Define all application routes
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/photo-selection': (context) => const PhotoSelectionScreen(),
          '/preview': (context) => const PreviewScreen(),
          '/export': (context) => const ExportScreen(),
        },
        // Handle routes with arguments
        onGenerateRoute: (settings) {
          if (settings.name == '/collage-edit') {
            final args = settings.arguments as Map<String, dynamic>?;
            final photos = args?['photos'] as List<XFile>? ?? [];
            return MaterialPageRoute(
              builder: (context) => CollageEditScreen(photos: photos),
            );
          }
          return null;
        },
        // Handle unknown routes
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          );
        },
      ),
    );
  }
}
