import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'series_screen.dart';
import '../../services/student_api_service.dart';

class ClassesScreen extends StatefulWidget {
  final int levelId;
  final String levelName;
  final String sectionName;

  const ClassesScreen({
    super.key,
    required this.levelId,
    required this.levelName,
    required this.sectionName,
  });

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List<dynamic> classes = [];
  bool isLoading = true;
  String? errorMessage;
  final StudentApiService _apiService = StudentApiService();

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    print('');
    print('🚀 ========== DÉBUT RÉCUPÉRATION DES CLASSES ==========');
    print('📍 Level ID: ${widget.levelId}');
    print('📚 Niveau: ${widget.levelName}');
    print('🔄 Appel de l\'API...');
    
    try {
      final response = await _apiService.getClassesByLevel(widget.levelId);
      
      if (response.success) {
        print('');
        print('📊 ========== ANALYSE DE LA RÉPONSE ==========');
        print('✅ Réponse reçue: SUCCÈS');
        print('📋 Données reçues: ${response.data}');
        
        final classesList = response.data as List<dynamic>;
        print('📊 Nombre de classes trouvées: ${classesList.length}');
        
        // Log de chaque classe trouvée
        for (int i = 0; i < classesList.length; i++) {
          final schoolClass = classesList[i];
          print('🎯 Classe ${i + 1}:');
          print('   🆔 ID: ${schoolClass['id']}');
          print('   📚 Nom: ${schoolClass['name']}');
          print('   🏫 Level ID: ${schoolClass['level_id']}');
        }
        
        setState(() {
          classes = classesList;
          isLoading = false;
        });
        
        print('');
        print('✅ ========== CHARGEMENT RÉUSSI ==========');
        print('🎉 ${classesList.length} classes chargées avec succès!');
        
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
        errorMessage = 'Erreur lors du chargement des classes: $e';
        isLoading = false;
      });
    }
  }

  Color _getClassColor(int index) {
    List<Color> colors = [
      Colors.indigo[400]!,
      Colors.cyan[400]!,
      Colors.amber[600]!,
      Colors.deepPurple[400]!,
      Colors.green[500]!,
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
                            'Classes - ${widget.levelName}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${widget.sectionName} • Sélectionnez la classe',
                            style: const TextStyle(
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
                          : classes.isEmpty
                              ? _buildEmptyWidget()
                              : ListView.builder(
                                  padding: const EdgeInsets.all(24),
                                  itemCount: classes.length,
                                  itemBuilder: (context, index) {
                                    final schoolClass = classes[index];
                                    final color = _getClassColor(index);

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: _ClassCard(
                                        title: schoolClass['name'] ?? 'Classe sans nom',
                                        studentCount: 0, // Les données réelles nécessiteront un appel API séparé
                                        seriesCount: 0,  // Les données réelles nécessiteront un appel API séparé
                                        color: color,
                                        onTap: () {
                                          print('');
                                          print('🎯 ========== NAVIGATION VERS LES SÉRIES ==========');
                                          print('📚 Classe sélectionnée: ${schoolClass['name']}');
                                          print('🆔 ID de la classe: ${schoolClass['id']}');
                                          print('🔄 Redirection vers SeriesScreen...');
                                          print('📍 Endpoint suivant: /api/mobile/classes/${schoolClass['id']}/series');
                                          
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => SeriesScreen(
                                                classId: schoolClass['id'],
                                                className: schoolClass['name'],
                                                levelName: widget.levelName,
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
              fetchClasses();
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
            Icons.class_,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune classe disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Il n\'y a pas de classes configurées\npour ce niveau.',
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

class _ClassCard extends StatelessWidget {
  final String title;
  final int studentCount;
  final int seriesCount;
  final Color color;
  final VoidCallback onTap;

  const _ClassCard({
    required this.title,
    required this.studentCount,
    required this.seriesCount,
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
              child: Icon(
                Icons.class_,
                size: 28,
                color: color,
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (studentCount > 0) ...[
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$studentCount élèves',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (seriesCount > 0) const SizedBox(width: 16),
                      ],
                      if (seriesCount > 0) ...[
                        Icon(
                          Icons.format_list_bulleted,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$seriesCount série${seriesCount > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (studentCount == 0 && seriesCount == 0) ...[
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Appuyez pour voir les séries',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
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
