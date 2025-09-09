import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_selection_screen.dart';
import 'screens/home_screen.dart';
import 'screens/teacher_management_screen.dart';
import 'screens/student/student_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Charger le fichier .env
  await dotenv.load(fileName: ".env");
  
  runApp(const PresenceCPBApp());
}

class PresenceCPBApp extends StatelessWidget {
  const PresenceCPBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Présence CPB',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/profile-selection': (context) => const ProfileSelectionScreen(),
        '/home': (context) => const HomeScreen(),
        '/teacher-management': (context) => const TeacherManagementScreen(),
        '/student-home': (context) => const StudentHomeScreen(),
      },
    );
  }
}