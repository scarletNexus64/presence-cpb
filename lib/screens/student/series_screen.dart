import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'students_list_screen.dart';
import '../../services/student_api_service.dart';

class SeriesScreen extends StatefulWidget {
  final int classId;
  final String className;
  final String levelName;
  final String sectionName;

  const SeriesScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.levelName,
    required this.sectionName,
  });

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  List<dynamic> series = [];
  bool isLoading = true;
  String? errorMessage;
  final StudentApiService _apiService = StudentApiService();

  @override
  void initState() {
    super.initState();
    fetchSeries();
  }

  Future<void> fetchSeries() async {
    print('');
    print('🚀 ========== DÉBUT RÉCUPÉRATION DES SÉRIES ==========');
    print('📍 Class ID: ${widget.classId}');
    print('📚 Classe: ${widget.className}');
    print('🔄 Appel de l\'API...');
    
    try {
      final response = await _apiService.getSeriesByClass(widget.classId);
      
      if (response.success) {
        print('');
        print('📊 ========== ANALYSE DE LA RÉPONSE ==========');
        print('✅ Réponse reçue: SUCCÈS');
        print('📋 Données reçues: ${response.data}');
        
        final seriesList = response.data as List<dynamic>;
        print('📊 Nombre de séries trouvées: ${seriesList.length}');
        
        // Log de chaque série trouvée
        for (int i = 0; i < seriesList.length; i++) {
          final seriesItem = seriesList[i];
          print('🎯 Série ${i + 1}:');
          print('   🆔 ID: ${seriesItem['id']}');
          print('   📚 Nom: ${seriesItem['name']}');
          print('   🏫 Class ID: ${seriesItem['class_id']}');
          print('   📋 Nom complet: ${seriesItem['full_name'] ?? 'N/A'}');
        }
        
        setState(() {
          series = seriesList;
          isLoading = false;
        });
        
        print('');
        print('✅ ========== CHARGEMENT RÉUSSI ==========');
        print('🎉 ${seriesList.length} séries chargées avec succès!');
        
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
        errorMessage = 'Erreur lors du chargement des séries: $e';
        isLoading = false;
      });
    }
  }

  Color _getSeriesColor(int index) {
    List<Color> colors = [
      Colors.blue[600]!,
      Colors.purple[600]!,
      Colors.orange[600]!,
      Colors.teal[600]!,
      Colors.red[600]!,
    ];
    return colors[index % colors.length];
  }

  IconData _getSeriesIcon(String seriesName) {
    if (seriesName.toLowerCase().contains('littéraire') || 
        seriesName.toLowerCase().contains('littér')) {
      return Icons.menu_book;
    } else if (seriesName.toLowerCase().contains('scientifique') || 
               seriesName.toLowerCase().contains('science')) {
      return Icons.science;
    } else if (seriesName.toLowerCase().contains('technique') || 
               seriesName.toLowerCase().contains('tech')) {
      return Icons.engineering;
    } else {
      return Icons.group;
    }
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
                            'Séries - ${widget.className}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '${widget.sectionName} • ${widget.levelName}',
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
                          : series.isEmpty
                              ? _buildEmptyWidget()
                              : Column(
                                  children: [
                                    // En-tête avec instruction
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.all(24),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.green[200]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Colors.green[700],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Sélectionnez une série pour commencer la prise de présence',
                                              style: TextStyle(
                                                color: Colors.green[700],
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Liste des séries
                                    Expanded(
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        itemCount: series.length,
                                        itemBuilder: (context, index) {
                                          final seriesItem = series[index];
                                          final color = _getSeriesColor(index);
                                          final icon = _getSeriesIcon(seriesItem['name']);

                                          return Padding(
                                            padding: const EdgeInsets.only(bottom: 16),
                                            child: _SeriesCard(
                                              title: seriesItem['name'] ?? 'Série sans nom',
                                              studentCount: 0, // Les compteurs nécessitent un appel API séparé
                                              isActive: true,  // On considère toutes les séries comme actives par défaut
                                              color: color,
                                              icon: icon,
                                              onTap: () {
                                                print('');
                                                print('🎯 ========== NAVIGATION VERS LA LISTE DES ÉLÈVES ==========');
                                                print('📚 Série sélectionnée: ${seriesItem['name']}');
                                                print('🆔 ID de la série: ${seriesItem['id']}');
                                                print('🔄 Redirection vers StudentsListScreen...');
                                                print('📍 Endpoint suivant: /api/mobile/students/series/${seriesItem['id']}');
                                                
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => StudentsListScreen(
                                                      seriesId: seriesItem['id'],
                                                      seriesName: seriesItem['name'] ?? seriesItem['full_name'] ?? 'Série sans nom',
                                                      className: widget.className,
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
                                  ],
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
              fetchSeries();
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
            Icons.format_list_bulleted,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune série disponible',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Il n\'y a pas de séries configurées\npour cette classe.',
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

class _SeriesCard extends StatelessWidget {
  final String title;
  final int studentCount;
  final bool isActive;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _SeriesCard({
    required this.title,
    required this.studentCount,
    required this.isActive,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color.withOpacity(0.3) : Colors.grey[300]!,
            width: 2,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isActive 
                    ? color.withOpacity(0.15) 
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 28,
                color: isActive ? color : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.grey[800] : Colors.grey[600],
                          ),
                        ),
                      ),
                      if (!isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Inactive',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (studentCount > 0) ...[
                        Icon(
                          Icons.people,
                          size: 16,
                          color: isActive ? Colors.grey[600] : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$studentCount élèves',
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive ? Colors.grey[600] : Colors.grey[500],
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: isActive ? Colors.grey[600] : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Appuyez pour voir les élèves',
                          style: TextStyle(
                            fontSize: 13,
                            color: isActive ? Colors.grey[600] : Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isActive)
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
