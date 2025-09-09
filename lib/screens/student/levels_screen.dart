import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'classes_screen.dart';
import '../../services/student_api_service.dart';

class LevelsScreen extends StatefulWidget {
  final int sectionId;
  final String sectionName;

  const LevelsScreen({
    super.key,
    required this.sectionId,
    required this.sectionName,
  });

  @override
  State<LevelsScreen> createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  List<dynamic> levels = [];
  bool isLoading = true;
  String? errorMessage;
  final StudentApiService _apiService = StudentApiService();

  @override
  void initState() {
    super.initState();
    fetchLevels();
  }

  Future<void> fetchLevels() async {
    print('');
    print('🚀 ========== DÉBUT RÉCUPÉRATION DES NIVEAUX ==========');
    print('📍 Section ID: ${widget.sectionId}');
    print('🔄 Appel de l\'API...');
    
    try {
      final response = await _apiService.getLevelsBySection(widget.sectionId);
      
      if (response.success) {
        print('');
        print('📊 ========== ANALYSE DE LA RÉPONSE ==========');
        print('✅ Réponse reçue: SUCCÈS');
        print('📋 Données reçues: ${response.data}');
        
        final levelsList = response.data as List<dynamic>;
        print('📊 Nombre de niveaux trouvés: ${levelsList.length}');
        
        // Log de chaque niveau trouvé
        for (int i = 0; i < levelsList.length; i++) {
          final level = levelsList[i];
          print('🎯 Niveau ${i + 1}:');
          print('   🆔 ID: ${level['id']}');
          print('   📚 Nom: ${level['name']}');
          print('   🏷️ Abréviation: ${level['abbreviation'] ?? 'N/A'}');
          print('   📊 Ordre: ${level['order']}');
        }
        
        setState(() {
          levels = levelsList;
          isLoading = false;
        });
        
        print('');
        print('✅ ========== CHARGEMENT RÉUSSI ==========');
        print('🎉 ${levelsList.length} niveaux chargés avec succès!');
        
      } else {
        print('');
        print('❌ ========== ERREUR API ==========');
        print('🔴 Message d\'erreur: ${response.message}');
        
        setState(() {
          errorMessage = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      print('');
      print('💥 ========== EXCEPTION ATTRAPÉE ==========');
      print('🔴 Erreur: $e');
      
      setState(() {
        errorMessage = 'Erreur lors du chargement des niveaux: $e';
        isLoading = false;
      });
    }
  }

  Color _getLevelColor(int index) {
    List<Color> colors = [
      Colors.blue[400]!,
      Colors.purple[400]!,
      Colors.orange[400]!,
      Colors.teal[400]!,
      Colors.pink[400]!,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[800]!,
              Colors.green[600]!,
              Colors.green[400]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Niveaux - ${widget.sectionName}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            'Sélectionnez le niveau',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.green,
                          ),
                        )
                      : errorMessage != null
                          ? _buildErrorWidget()
                          : levels.isEmpty
                              ? _buildEmptyWidget()
                              : ListView.builder(
                                  padding: const EdgeInsets.all(24),
                                  itemCount: levels.length,
                                  itemBuilder: (context, index) {
                                    final level = levels[index];
                                    final color = _getLevelColor(index);

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _LevelCard(
                                        title: level['name'] ?? 'Niveau sans nom',
                                        abbreviation: level['abbreviation'] ?? level['name']?.substring(0, 3) ?? 'N/A',
                                        order: level['order'] ?? index + 1,
                                        color: color,
                                        onTap: () {
                                          print('');
                                          print('🎯 ========== NAVIGATION VERS LES CLASSES ==========');
                                          print('📚 Niveau sélectionné: ${level['name']}');
                                          print('🆔 ID du niveau: ${level['id']}');
                                          print('🔄 Redirection vers ClassesScreen...');
                                          print('📍 Endpoint suivant: /api/mobile/levels/${level['id']}/classes');
                                          
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => ClassesScreen(
                                                levelId: level['id'],
                                                levelName: level['name'],
                                                sectionName: widget.sectionName,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              fetchLevels();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun niveau disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Il n\'y a pas de niveaux configurés\npour cette section.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final String title;
  final String abbreviation;
  final int order;
  final Color color;
  final VoidCallback onTap;

  const _LevelCard({
    required this.title,
    required this.abbreviation,
    required this.order,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  abbreviation,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Niveau $order',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
