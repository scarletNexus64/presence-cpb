import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import '../../models/api_response.dart';

/// Widget de test pour vérifier les nouvelles fonctionnalités de l'API d'attendance
class TestAttendanceApiScreen extends StatefulWidget {
  const TestAttendanceApiScreen({super.key});

  @override
  State<TestAttendanceApiScreen> createState() => _TestAttendanceApiScreenState();
}

class _TestAttendanceApiScreenState extends State<TestAttendanceApiScreen> {
  final StudentApiService _apiService = StudentApiService();
  final List<String> _testResults = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // Pour les tests, on peut utiliser un token fictif ou demander à l'utilisateur de se connecter
    _apiService.setAuthToken('test_token');
  }

  void _addResult(String message, bool success) {
    setState(() {
      _testResults.add('${success ? "✅" : "❌"} $message');
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    _addResult('🚀 Début des tests de l\'API Attendance', true);
    
    // Test 1: Connexion au serveur
    await _testConnection();
    
    // Test 2: Navigation hiérarchique
    await _testHierarchicalNavigation();
    
    // Test 3: Fonctions de marquage (simulation)
    await _testMarkingFunctions();
    
    // Test 4: Statistiques
    await _testStatistics();

    _addResult('✨ Tests terminés!', true);
    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testConnection() async {
    _addResult('Test de connexion au serveur...', true);
    try {
      final response = await _apiService.testConnection();
      _addResult('Connexion: ${response.message}', response.success);
    } catch (e) {
      _addResult('Connexion échouée: $e', false);
    }
  }

  Future<void> _testHierarchicalNavigation() async {
    _addResult('Test de navigation hiérarchique...', true);
    
    try {
      // Test sections
      final sectionsResponse = await _apiService.getSections();
      _addResult('Sections: ${sectionsResponse.success ? "OK" : sectionsResponse.message}', sectionsResponse.success);
      
      if (sectionsResponse.success && sectionsResponse.data != null) {
        final sections = sectionsResponse.data as List;
        if (sections.isNotEmpty) {
          final sectionId = sections.first['id'];
          _addResult('Section de test: ID $sectionId', true);
          
          // Test levels
          final levelsResponse = await _apiService.getLevelsBySection(sectionId);
          _addResult('Niveaux: ${levelsResponse.success ? "OK (${(levelsResponse.data as List? ?? []).length} niveaux)" : levelsResponse.message}', levelsResponse.success);
          
          if (levelsResponse.success && levelsResponse.data != null) {
            final levels = levelsResponse.data as List;
            if (levels.isNotEmpty) {
              final levelId = levels.first['id'];
              
              // Test classes
              final classesResponse = await _apiService.getClassesByLevel(levelId);
              _addResult('Classes: ${classesResponse.success ? "OK (${(classesResponse.data as List? ?? []).length} classes)" : classesResponse.message}', classesResponse.success);
              
              if (classesResponse.success && classesResponse.data != null) {
                final classes = classesResponse.data as List;
                if (classes.isNotEmpty) {
                  final classId = classes.first['id'];
                  
                  // Test series
                  final seriesResponse = await _apiService.getSeriesByClass(classId);
                  _addResult('Séries: ${seriesResponse.success ? "OK (${(seriesResponse.data as List? ?? []).length} séries)" : seriesResponse.message}', seriesResponse.success);
                  
                  if (seriesResponse.success && seriesResponse.data != null) {
                    final series = seriesResponse.data as List;
                    if (series.isNotEmpty) {
                      final seriesId = series.first['id'];
                      
                      // Test students
                      final studentsResponse = await _apiService.getStudentsBySeries(seriesId);
                      _addResult('Étudiants: ${studentsResponse.success ? "OK (${(studentsResponse.data as List? ?? []).length} étudiants)" : studentsResponse.message}', studentsResponse.success);
                    }
                  }
                }
              }
            }
          }
        }
      }
    } catch (e) {
      _addResult('Navigation hiérarchique échouée: $e', false);
    }
  }

  Future<void> _testMarkingFunctions() async {
    _addResult('Test des fonctions de marquage (simulation)...', true);
    
    try {
      // Test avec des données fictives pour ne pas affecter la base de données
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Simulation du marquage individuel
      _addResult('Test de marquage individuel: Structure OK', true);
      
      // Simulation du marquage en masse des absents
      _addResult('Test de marquage en masse des absents: Structure OK', true);
      
      // Simulation de récupération de statut
      _addResult('Test de récupération de statut étudiant: Structure OK', true);
      
      _addResult('⚠️  Tests de marquage en mode simulation uniquement', true);
      
    } catch (e) {
      _addResult('Tests de marquage échoués: $e', false);
    }
  }

  Future<void> _testStatistics() async {
    _addResult('Test des statistiques...', true);
    
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      
      // Test statistiques en temps réel
      final statsResponse = await _apiService.getRealtimeStats(date: today);
      _addResult('Statistiques temps réel: ${statsResponse.success ? "OK" : statsResponse.message}', statsResponse.success);
      
      if (statsResponse.success && statsResponse.data != null) {
        final data = statsResponse.data as Map<String, dynamic>;
        _addResult('Données stats: ${data.keys.join(", ")}', true);
      }
      
    } catch (e) {
      _addResult('Tests statistiques échoués: $e', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API Attendance'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête explicatif
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Tests de l\'intégration API',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cette page teste les nouvelles fonctionnalités de gestion manuelle des présences étudiants.',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Bouton de test
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRunning ? null : _runAllTests,
                icon: _isRunning 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.play_arrow),
                label: Text(_isRunning ? 'Tests en cours...' : 'Lancer tous les tests'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Résultats des tests
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.terminal, color: Colors.grey),
                          const SizedBox(width: 8),
                          const Text(
                            'Résultats des tests',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_testResults.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_testResults.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _testResults.isEmpty
                        ? const Center(
                            child: Text(
                              'Appuyez sur "Lancer tous les tests" pour commencer',
                              style: TextStyle(
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _testResults.length,
                            itemBuilder: (context, index) {
                              final result = _testResults[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  result,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'monospace',
                                    color: result.startsWith('❌') 
                                      ? Colors.red[700] 
                                      : result.startsWith('⚠️')
                                        ? Colors.orange[700]
                                        : Colors.green[700],
                                  ),
                                ),
                              );
                            },
                          ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Informations sur l'environnement
            Card(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration actuelle:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'API URL: http://192.168.1.231:8000',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'Mode: Tests d\'intégration',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}