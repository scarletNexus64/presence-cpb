import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/attendance_api_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final AttendanceApiService _apiService = AttendanceApiService();
  String _statusMessage = "Initialisation...";
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    
    // Animation du loader rotatif
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    // Animation de fade pour les messages
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
    
    // Démarrer la vérification de connexion
    _initializeApp();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Étape 1: Préparation du système
    await _updateStatus("Préparation du système...");
    await Future.delayed(const Duration(seconds: 1));

    // Étape 2: Vérification de l'authentification
    await _updateStatus("Vérification de l'authentification...");
    await Future.delayed(const Duration(milliseconds: 500));
    
    bool isAuthenticated = await _checkAuthentication();
    
    // Étape 3: Vérification de la connexion
    await _updateStatus("Vérification de la connexion...");
    await Future.delayed(const Duration(milliseconds: 500));

    bool connected = await _apiService.checkConnection();
    
    if (connected) {
      _isConnected = true;
      await _updateStatus("Connexion établie ✓");
      await Future.delayed(const Duration(milliseconds: 800));
      
      if (isAuthenticated) {
        // Test de l'authentification JWT
        await _updateStatus("Vérification du token...");
        final jwtTest = await _apiService.testJWTAuth();
        
        if (jwtTest.success) {
          await _updateStatus("Authentifié ✓");
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          await _updateStatus("Authentification expirée");
          isAuthenticated = false;
          await Future.delayed(const Duration(seconds: 1));
        }
      }
      
      await _updateStatus("Système prêt !");
      await Future.delayed(const Duration(milliseconds: 500));
    } else {
      await _updateStatus("Mode hors ligne");
      await Future.delayed(const Duration(seconds: 1));
      
      await _updateStatus("Tentative de reconnexion...");
      await Future.delayed(const Duration(seconds: 1));
      
      // Deuxième tentative
      connected = await _apiService.checkConnection();
      if (connected) {
        _isConnected = true;
        await _updateStatus("Connexion établie ✓");
        await Future.delayed(const Duration(milliseconds: 800));
      } else {
        await _updateStatus("Fonctionnement hors ligne");
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // Navigation vers l'écran approprié
    if (mounted) {
      if (isAuthenticated && connected) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  /// Vérifier si l'utilisateur est déjà authentifié
  Future<bool> _checkAuthentication() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> _updateStatus(String message) async {
    await _fadeController.reverse();
    setState(() {
      _statusMessage = message;
    });
    await _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[800]!,
              Colors.blue[600]!,
              Colors.blue[400]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo et titre
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Présence CPB',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Système de gestion de présence',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Loader animé
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * 3.14159,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Message de statut
              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Indicateur de connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isConnected ? Icons.wifi : Icons.wifi_off,
                    color: _isConnected 
                        ? Colors.green[300] 
                        : Colors.orange[300],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isConnected ? 'En ligne' : 'Hors ligne',
                    style: TextStyle(
                      fontSize: 14,
                      color: _isConnected 
                          ? Colors.green[300] 
                          : Colors.orange[300],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Version info
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'Version 1.0.0 • CPB Douala',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}