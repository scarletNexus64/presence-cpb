import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'attendance_screen.dart';
import '../../services/student_api_service.dart';

class StudentsListScreen extends StatefulWidget {
  final int seriesId;
  final String seriesName;
  final String className;
  final String levelName;
  final String sectionName;

  const StudentsListScreen({
    super.key,
    required this.seriesId,
    required this.seriesName,
    required this.className,
    required this.levelName,
    required this.sectionName,
  });

  @override
  State<StudentsListScreen> createState() => _StudentsListScreenState();
}

class _StudentsListScreenState extends State<StudentsListScreen> {
  List<dynamic> students = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedMode = 'entry'; // 'entry' ou 'exit'
  final StudentApiService _apiService = StudentApiService();
  
  // Statut des appels pour la journée
  bool hasEntryToday = false;
  bool hasExitToday = false;
  bool isLoadingStatus = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    await Future.wait([
      fetchStudents(),
      _checkAttendanceStatus(),
    ]);
  }
  
  Future<void> _checkAttendanceStatus() async {
    try {
      final response = await _apiService.getAttendanceStatus(
        seriesId: widget.seriesId,
      );
      
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        
        setState(() {
          hasEntryToday = (data['entry_count'] ?? 0) > 0;
          hasExitToday = (data['exit_count'] ?? 0) > 0;
          isLoadingStatus = false;
          
          // Adapter le mode par défaut selon le statut
          if (hasEntryToday && !hasExitToday) {
            selectedMode = 'exit'; // Si l'entrée est faite, proposer la sortie
          } else if (!hasEntryToday) {
            selectedMode = 'entry'; // Si rien n'est fait, commencer par l'entrée
          }
        });
        
        print('📊 Statut des appels pour ${widget.seriesName}:');
        print('   🌅 Entrée faite: ${hasEntryToday ? 'OUI' : 'NON'}');
        print('   🌆 Sortie faite: ${hasExitToday ? 'OUI' : 'NON'}');
        print('   🎯 Mode suggéré: $selectedMode');
      }
    } catch (e) {
      print('⚠️ Erreur lors de la vérification du statut: $e');
      setState(() {
        isLoadingStatus = false;
      });
    }
  }

  Future<void> fetchStudents() async {
    print('');
    print('🚀 ========== DÉBUT RÉCUPÉRATION DES ÉLÈVES ==========');
    print('📍 Series ID: ${widget.seriesId}');
    print('📚 Série: ${widget.seriesName}');
    print('🔄 Appel de l\'API...');
    
    try {
      final response = await _apiService.getStudentsBySeries(widget.seriesId);
      
      if (response.success) {
        print('');
        print('📊 ========== ANALYSE DE LA RÉPONSE ==========');
        print('✅ Réponse reçue: SUCCÈS');
        print('📋 Données reçues: ${response.data}');
        
        // Gérer le nouveau format de réponse avec students, series_info, attendance_state
        List<dynamic> studentsList;
        if (response.data is Map<String, dynamic> && response.data.containsKey('students')) {
          // Nouveau format
          studentsList = response.data['students'] as List<dynamic>;
          print('📊 Nouveau format détecté avec informations supplémentaires');
          print('📋 Informations série: ${response.data['series_info']}');
          print('🎯 État d\'appel: ${response.data['attendance_state']}');
        } else {
          // Ancien format
          studentsList = response.data as List<dynamic>;
          print('📊 Ancien format détecté');
        }
        
        print('📊 Nombre d\'élèves trouvés: ${studentsList.length}');
        
        // Log de chaque élève trouvé
        for (int i = 0; i < studentsList.length && i < 5; i++) { // Limiter à 5 pour les logs
          final student = studentsList[i];
          print('🎯 Élève ${i + 1}:');
          print('   🆔 ID: ${student['id']}');
          print('   📝 Matricule: ${student['student_number']}');
          print('   👤 Prénom: ${student['first_name']}');
          print('   👤 Nom: ${student['last_name']}');
          print('   📊 Ordre: ${student['order']}');
        }
        
        if (studentsList.length > 5) {
          print('   ... et ${studentsList.length - 5} autres élèves');
        }
        
        setState(() {
          students = studentsList;
          isLoading = false;
        });
        
        print('');
        print('✅ ========== CHARGEMENT RÉUSSI ==========');
        print('🎉 ${studentsList.length} élèves chargés avec succès!');
        
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
        errorMessage = 'Erreur lors du chargement des élèves: $e';
        isLoading = false;
      });
    }
  }

  void _showModeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sélectionner le type d\'appel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _ModeCard(
              title: 'Entrée',
              subtitle: hasEntryToday ? 
                '✅ Appel d\'entrée effectué aujourd\'hui' :
                'Appel du matin / Début de journée',
              icon: Icons.login,
              color: hasEntryToday ? Colors.grey[600]! : Colors.green[600]!,
              isSelected: selectedMode == 'entry',
              isDisabled: hasEntryToday,
              onTap: hasEntryToday ? null : () {
                setState(() {
                  selectedMode = 'entry';
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            _ModeCard(
              title: 'Sortie',
              subtitle: hasExitToday ? 
                '✅ Appel de sortie effectué aujourd\'hui' :
                !hasEntryToday ? 
                  '⚠️ Faire d\'abord l\'appel d\'entrée' :
                  'Appel du soir / Fin de journée',
              icon: Icons.logout,
              color: hasExitToday ? Colors.grey[600]! : Colors.orange[600]!,
              isSelected: selectedMode == 'exit',
              isDisabled: hasExitToday || !hasEntryToday,
              onTap: (hasExitToday || !hasEntryToday) ? null : () {
                setState(() {
                  selectedMode = 'exit';
                });
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getModeTitle() {
    return selectedMode == 'entry' ? 'Appel d\'Entrée' : 'Appel de Sortie';
  }

  Color _getModeColor() {
    return selectedMode == 'entry' ? Colors.green[600]! : Colors.orange[600]!;
  }

  IconData _getModeIcon() {
    return selectedMode == 'entry' ? Icons.login : Icons.logout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.seriesName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.sectionName} • ${widget.levelName} • ${widget.className}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _showModeSelector,
            icon: Icon(_getModeIcon()),
            tooltip: 'Changer le mode',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green),
            )
          : errorMessage != null
              ? _buildErrorWidget()
              : students.isEmpty
                  ? _buildEmptyWidget()
                  : Column(
                      children: [
                        // En-tête avec mode et statistiques
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _getModeColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getModeColor().withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getModeColor().withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getModeIcon(),
                                  color: _getModeColor(),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getModeTitle(),
                                      style: TextStyle(
                                        color: _getModeColor(),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${students.length} élèves à pointer',
                                      style: TextStyle(
                                        color: _getModeColor().withOpacity(0.8),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: _showModeSelector,
                                child: Text(
                                  'Changer',
                                  style: TextStyle(
                                    color: _getModeColor(),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Liste des élèves
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _StudentCard(
                                  student: student,
                                  onAttendanceChanged: (status) {
                                    setState(() {
                                      students[index]['attendance_status'] = status;
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: students.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AttendanceScreen(
                      seriesId: widget.seriesId,
                      seriesName: widget.seriesName,
                      className: widget.className,
                      levelName: widget.levelName,
                      sectionName: widget.sectionName,
                      students: students,
                      mode: selectedMode,
                    ),
                  ),
                ).then((result) {
                  // Si l'appel a été terminé avec succès, rafraîchir le statut
                  if (result == true) {
                    _checkAttendanceStatus();
                  }
                });
              },
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              icon: const Icon(Icons.checklist),
              label: const Text('Faire l\'appel'),
            )
          : null,
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
              fetchStudents();
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
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun élève trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Il n\'y a pas d\'élèves inscrits\ndans cette série.',
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

class _ModeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDisabled;

  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[100] : 
                 (isSelected ? color.withOpacity(0.1) : Colors.grey[50]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled ? Colors.grey[300]! :
                   (isSelected ? color : Colors.grey[300]!),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey[200] :
                       (isSelected ? color.withOpacity(0.2) : Colors.grey[200]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isDisabled ? Colors.grey[400] :
                       (isSelected ? color : Colors.grey[600]),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDisabled ? Colors.grey[500] :
                             (isSelected ? color : Colors.grey[800]),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDisabled ? Colors.grey[400] :
                             (isSelected ? color.withOpacity(0.8) : Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final Function(String?) onAttendanceChanged;

  const _StudentCard({
    required this.student,
    required this.onAttendanceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = student['attendance_status'];
    Color cardColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    
    if (status == 'present') {
      cardColor = Colors.green[50]!;
      borderColor = Colors.green[300]!;
    } else if (status == 'absent') {
      cardColor = Colors.red[50]!;
      borderColor = Colors.red[300]!;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          // Numéro et infos élève
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '#${student['order']}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${student['last_name']} ${student['first_name']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Matricule: ${student['student_number']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Boutons présent/absent
          Row(
            children: [
              _AttendanceButton(
                label: 'Présent',
                icon: Icons.check,
                color: Colors.green,
                isSelected: status == 'present',
                onTap: () => onAttendanceChanged(
                  status == 'present' ? null : 'present'
                ),
              ),
              const SizedBox(width: 8),
              _AttendanceButton(
                label: 'Absent',
                icon: Icons.close,
                color: Colors.red,
                isSelected: status == 'absent',
                onTap: () => onAttendanceChanged(
                  status == 'absent' ? null : 'absent'
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AttendanceButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
