import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/photo_selection_screen.dart';
import 'screens/collage_edit_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/export_screen.dart';

void main() {
  runApp(const KomjirakFrameApp());
}

class KomjirakFrameApp extends StatelessWidget {
  const KomjirakFrameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Komjirak Frame',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Set the initial route
      initialRoute: '/',
      // Define all application routes
      routes: {
        '/': (context) => const HomeScreen(),
        '/photo-selection': (context) => const PhotoSelectionScreen(),
        '/collage-edit': (context) => const CollageEditScreen(),
        '/preview': (context) => const PreviewScreen(),
        '/export': (context) => const ExportScreen(),
      },
      // Handle unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      },
    );
  }
}
