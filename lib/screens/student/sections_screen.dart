import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';
import 'levels_screen.dart';
import '../profile_selection_screen.dart';

class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  List<dynamic> sections = [];
  bool isLoading = true;
  String? errorMessage;
  final StudentApiService _apiService = StudentApiService();

  @override
  void initState() {
    super.initState();
    fetchSections();
  }

  Future<void> fetchSections() async {
    try {
      // 🚀 Début de la récupération des sections/cycles
      print('🚀 ========== DÉBUT RÉCUPÉRATION DES SECTIONS ==========');
      print('📍 Endpoint ciblé: /api/sections');
      print('🔄 Envoi de la requête API...');

      final response = await _apiService.getSections();

      // 📊 Analyse de la réponse
      print('');
      print('📊 ========== ANALYSE DE LA RÉPONSE DANS SCREEN ==========');
      print('✅ Réponse reçue: ${response.success ? "SUCCÈS" : "ÉCHEC"}');
      print('📝 Message: ${response.message}');
      print('🔍 Type de response.data: ${response.data.runtimeType}');
      print('📦 response.data est null?: ${response.data == null}');

      if (response.success && response.data != null) {
        // 🔍 Debug détaillé du type de données
        print('');
        print('🔍 ========== DEBUG TYPE DE DONNÉES ==========');
        print('📊 Type exact de response.data: ${response.data.runtimeType}');

        List<dynamic> data = [];

        // Gestion du type de données avec logs détaillés
        if (response.data is List) {
          print('✅ response.data est bien une List');
          data = response.data as List<dynamic>;
          print('📊 Conversion directe en List<dynamic> réussie');
        } else if (response.data is Map &&
            (response.data as Map).containsKey('data')) {
          print('⚠️ response.data est un Map, extraction de data["data"]');
          final mapData = response.data as Map<String, dynamic>;
          if (mapData['data'] is List) {
            data = mapData['data'] as List<dynamic>;
            print('✅ Extraction de la liste depuis Map["data"] réussie');
          } else {
            print(
              '❌ Map["data"] n\'est pas une List: ${mapData['data'].runtimeType}',
            );
          }
        } else {
          print(
            '❌ Type inattendu pour response.data: ${response.data.runtimeType}',
          );
          print('📝 Contenu de response.data: $response.data');
        }

        // 📋 Détails des données reçues
        print('');
        print('📋 ========== DONNÉES FINALES ==========');
        print('📊 Nombre de sections trouvées: ${data.length}');
        print('🔍 Type de la liste finale: ${data.runtimeType}');

        // 🎯 Affichage détaillé de chaque section
        for (int i = 0; i < data.length; i++) {
          print('');
          print('🎯 ========== Section ${i + 1}/${data.length} ==========');
          final section = data[i];
          print('   🔍 Type de l\'élément: ${section.runtimeType}');

          if (section is Map) {
            final sectionMap = section as Map<String, dynamic>;
            print(
              '   🆔 ID: ${sectionMap['id']} (Type: ${sectionMap['id'].runtimeType})',
            );
            print(
              '   📚 Nom: ${sectionMap['name']} (Type: ${sectionMap['name'].runtimeType})',
            );
            print(
              '   📝 Description: ${sectionMap['description'] ?? "Non définie"}',
            );
            print('   🎨 Couleur: ${sectionMap['color'] ?? "#4ECDC4"}');
            print('   🎭 Icône: ${sectionMap['icon'] ?? "school"}');
            print('   ✅ Active: ${sectionMap['is_active'] ?? true}');
            print('   🔑 Toutes les clés: ${sectionMap.keys.join(", ")}');
          } else {
            print('   ❌ L\'élément n\'est pas un Map: $section');
          }
        }

        setState(() {
          sections = data;
          isLoading = false;
        });

        print('');
        print('✅ ========== CHARGEMENT RÉUSSI ==========');
        print('🎉 ${data.length} sections chargées avec succès!');
        print('🖼️ Interface mise à jour avec setState');
      } else {
        // ⚠️ Échec de la récupération
        print('');
        print('⚠️ ========== ÉCHEC DE L\'API ==========');
        print('❌ response.success: ${response.success}');
        print('❌ response.data null?: ${response.data == null}');
        print('❌ Message d\'erreur: ${response.message}');
        print('🚫 Aucune donnée disponible - affichage vide');

        setState(() {
          sections = [];
          isLoading = false;
          errorMessage = response.message ?? 'Erreur de connexion à l\'API';
        });
      }
    } catch (e, stackTrace) {
      // 🔴 Gestion des erreurs avec stack trace
      print('');
      print('🔴 ========== ERREUR CRITIQUE ==========');
      print('❌ Type d\'erreur: ${e.runtimeType}');
      print('📝 Message: $e');
      print('📍 Stack Trace:');
      print(stackTrace.toString().split('\n').take(10).join('\n'));
      print('🚫 Aucune donnée disponible - affichage vide');

      setState(() {
        sections = [];
        isLoading = false;
        errorMessage =
            'Impossible de charger les sections. Vérifiez votre connexion Internet et réessayez.';
      });
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return const Color(0xFF4ECDC4); // Couleur par défaut
    }
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      print('⚠️ Erreur parsing couleur "$colorHex": $e');
      return const Color(0xFF4ECDC4); // Couleur par défaut en cas d'erreur
    }
  }

  IconData _parseIcon(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return Icons.school; // Icône par défaut
    }
    switch (iconName.toLowerCase()) {
      case 'child_care':
        return Icons.child_care;
      case 'school':
        return Icons.school;
      case 'menu_book':
        return Icons.menu_book;
      default:
        return Icons.school; // Icône par défaut pour les noms non reconnus
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sélection du Cycle',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Choisissez le cycle d\'enseignement',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Menu déroulant
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'change_mode':
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ProfileSelectionScreen(),
                              ),
                            );
                            break;
                          case 'logout':
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                            break;
                        }
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                        size: 24,
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'change_mode',
                          child: Row(
                            children: [
                              Icon(Icons.swap_horiz, color: Colors.blue),
                              SizedBox(width: 12),
                              Text('Changer de mode'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 12),
                              Text('Se déconnecter'),
                            ],
                          ),
                        ),
                      ],
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
                          child: CircularProgressIndicator(color: Colors.green),
                        )
                      : errorMessage != null
                      ? Center(
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                child: Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isLoading = true;
                                    errorMessage = null;
                                  });
                                  fetchSections();
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
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24),
                          itemCount: sections.length,
                          itemBuilder: (context, index) {
                            print(
                              '🖼️ Construction de la carte ${index + 1}/${sections.length}',
                            );
                            final section = sections[index];
                            print(
                              '   Type de section[$index]: ${section.runtimeType}',
                            );

                            // Vérification et cast sécurisé
                            if (section is! Map) {
                              print('   ❌ Section n\'est pas un Map, skip');
                              return const SizedBox.shrink();
                            }

                            final sectionMap = section as Map<String, dynamic>;
                            final color = _parseColor(sectionMap['color']);
                            final icon = _parseIcon(sectionMap['icon']);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _SectionCard(
                                title: sectionMap['name'] ?? 'Sans nom',
                                description: sectionMap['description'] ?? '',
                                icon: icon,
                                color: color,
                                onTap: () {
                                  // 🎯 Navigation vers les niveaux/cycles
                                  print('');
                                  print(
                                    '🎯 ========== NAVIGATION VERS LES NIVEAUX ==========',
                                  );
                                  print(
                                    '📚 Section sélectionnée: ${sectionMap['name']}',
                                  );
                                  print(
                                    '🆔 ID de la section: ${sectionMap['id']}',
                                  );
                                  print('🔄 Redirection vers LevelsScreen...');
                                  print(
                                    '📍 Endpoint suivant: /api/mobile/sections/${sectionMap['id']}/levels',
                                  );

                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => LevelsScreen(
                                        sectionId: sectionMap['id'],
                                        sectionName: sectionMap['name'],
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
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SectionCard({
    required this.title,
    required this.description,
    required this.icon,
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
          border: Border.all(color: color.withOpacity(0.3), width: 2),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
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
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
