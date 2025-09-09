import 'package:flutter/material.dart';
import '../../services/student_api_service.dart';

class AttendanceScreen extends StatefulWidget {
  final int seriesId;
  final String seriesName;
  final String className;
  final String levelName;
  final String sectionName;
  final List<dynamic> students;
  final String mode; // 'entry' ou 'exit'
  final DateTime? selectedDate;

  const AttendanceScreen({
    super.key,
    required this.seriesId,
    required this.seriesName,
    required this.className,
    required this.levelName,
    required this.sectionName,
    required this.students,
    required this.mode,
    this.selectedDate,
  });

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isSubmitting = false;
  late List<dynamic> attendanceData;
  final StudentApiService _apiService = StudentApiService();

  @override
  void initState() {
    super.initState();
    attendanceData = List.from(widget.students);
  }

  int get totalStudents => attendanceData.length;
  int get presentCount =>
      attendanceData.where((s) => s['attendance_status'] == 'present').length;
  int get absentCount =>
      attendanceData.where((s) => s['attendance_status'] == 'absent').length;
  int get notMarkedCount =>
      attendanceData.where((s) => s['attendance_status'] == null).length;

  double get completionPercentage {
    if (totalStudents == 0) return 0.0;
    return ((presentCount + absentCount) / totalStudents) * 100;
  }

  String get modeTitle => widget.mode == 'entry' ? 'Entrée' : 'Sortie';
  Color get modeColor =>
      widget.mode == 'entry' ? Colors.green[600]! : Colors.orange[600]!;
  IconData get modeIcon => widget.mode == 'entry' ? Icons.login : Icons.logout;

  String get currentDate =>
      widget.selectedDate?.toIso8601String().split('T')[0] ??
      DateTime.now().toIso8601String().split('T')[0];

  Future<void> _markAllAbsent() async {
    final shouldContinue = await _showMarkAllAbsentDialog();
    if (!shouldContinue) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      final response = await _apiService.markAllAbsentInSeries(
        seriesId: widget.seriesId,
        attendanceDate: DateTime.now().toIso8601String().split('T')[0],
        notes: 'Marquage automatique des absents - ${widget.mode}',
      );

      if (mounted) {
        if (response.success) {
          // Mettre à jour l'affichage local pour refléter les changements
          setState(() {
            for (var student in attendanceData) {
              if (student['attendance_status'] == null) {
                student['attendance_status'] = 'absent';
              }
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'Eleves non marqués définis comme absents',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message ?? 'Erreur lors du marquage des absences',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du marquage: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  Future<void> _submitAttendance() async {
    if (notMarkedCount > 0) {
      final shouldContinue = await _showConfirmationDialog();
      if (!shouldContinue) return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      print('');
      print('🎯 ========== DÉBUT VALIDATION APPEL ==========');
      print('📚 Série: ${widget.seriesName}');
      print('🏫 Classe: ${widget.className}');
      print('📊 Mode: ${widget.mode} (${modeTitle})');
      print('👥 Total élèves: $totalStudents');
      print('✅ Présents: $presentCount');
      print('❌ Absents: $absentCount');
      print('⚪ Non marqués: $notMarkedCount');

      final response = await _apiService.submitBulkAttendance(
        seriesId: widget.seriesId,
        eventType: widget.mode,
        students: attendanceData.cast<Map<String, dynamic>>(),
        notes: 'Appel d\'${modeTitle.toLowerCase()} via application mobile',
        attendanceDate: currentDate,
      );

      if (mounted) {
        if (response.success) {
          print('');
          print('🎉 ========== SUCCÈS ENREGISTREMENT ==========');
          print('✅ ${response.message}');
          if (response.data != null) {
            final data = response.data as Map<String, dynamic>;
            print('📊 Statistiques:');
            print(
              '   👥 Total traités: ${data['total_students'] ?? totalStudents}',
            );
            print('   ✅ Présents: ${data['present_count'] ?? presentCount}');
            print('   ❌ Absents: ${data['absent_count'] ?? absentCount}');
            print(
              '   📅 Date: ${data['attendance_date'] ?? DateTime.now().toIso8601String().split('T')[0]}',
            );
          }

          // Message de succès plus détaillé
          final successMessage = response.data != null
              ? '✅ Appel d\'${modeTitle.toLowerCase()} validé!\n📊 ${response.data['present_count'] ?? presentCount} présents • ${response.data['absent_count'] ?? absentCount} absents'
              : response.message ??
                    'Présences d\'${modeTitle.toLowerCase()} enregistrées avec succès !';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );

          // Retourner avec succès
          Navigator.pop(context, true); // true indique que l'appel a été fait
        } else {
          print('');
          print('❌ ========== ÉCHEC ENREGISTREMENT ==========');
          print('🔴 ${response.message}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Échec de l\'enregistrement\n${response.message ?? 'Erreur lors de l\'enregistrement des présences'}',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Réessayer',
                textColor: Colors.white,
                onPressed: _submitAttendance,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<bool> _showMarkAllAbsentDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.person_remove_rounded, color: Colors.orange[600]),
                const SizedBox(width: 12),
                const Text('Marquer les absents'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marquer automatiquement comme absents les $notMarkedCount étudiant(s) non marqué(s) ?',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Cette action marquera automatiquement tous les Eleves non marqués comme absents.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Marquer absents'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmer l\'envoi'),
            content: Text(
              '$notMarkedCount élève(s) n\'ont pas été marqués.\n\n'
              'Ils seront automatiquement considérés comme absents.\n\n'
              'Voulez-vous continuer ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: modeColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Confirmer'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showNextActionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Appel terminé !', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'L\'appel d\'${modeTitle.toLowerCase()} pour ${widget.seriesName} a été enregistré.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatChip(
                        label: 'Présents',
                        value: presentCount.toString(),
                        color: Colors.green,
                      ),
                      _StatChip(
                        label: 'Absents',
                        value: absentCount.toString(),
                        color: Colors.red,
                      ),
                      _StatChip(
                        label: 'Total',
                        value: totalStudents.toString(),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Que souhaitez-vous faire maintenant ?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              Navigator.pop(
                context,
                true,
              ); // Retourner à la liste des Eleves avec indicateur de mise à jour
            },
            icon: const Icon(Icons.list),
            label: const Text('Autre classe'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Fermer le dialog
              // Retourner à l'accueil des Eleves
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Accueil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: modeColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: modeColor,
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
              'Appel d\'$modeTitle',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.seriesName} • ${widget.className}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Contenu principal
          Column(
            children: [
              // En-tête avec statistiques
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: modeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(modeIcon, color: modeColor, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.sectionName} • ${widget.levelName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${widget.className} - ${widget.seriesName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Barre de progression
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progression de l\'appel',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '${completionPercentage.toInt()}%',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: modeColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: completionPercentage / 100,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(modeColor),
                          minHeight: 6,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Statistiques
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Présents',
                            value: presentCount.toString(),
                            color: Colors.green,
                            icon: Icons.check_circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Absents',
                            value: absentCount.toString(),
                            color: Colors.red,
                            icon: Icons.cancel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'À faire',
                            value: notMarkedCount.toString(),
                            color: Colors.orange,
                            icon: Icons.schedule,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Liste des élèves avec leur statut
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    150,
                  ), // Padding en bas pour éviter le bouton fixe
                  itemCount: attendanceData.length,
                  itemBuilder: (context, index) {
                    final student = attendanceData[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _StudentSummaryCard(
                        student: student,
                        onStatusChanged: (status) {
                          setState(() {
                            attendanceData[index]['attendance_status'] = status;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ], // Fin de la Column
          ),

          // Bouton fixe en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouton pour marquer tous les absents (affiché seulement s'il y a des non-marqués)
                    if (notMarkedCount > 0) ...[
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton.icon(
                          onPressed: isSubmitting ? null : _markAllAbsent,
                          icon: Icon(
                            Icons.person_remove_rounded,
                            color: Colors.orange[600],
                            size: 20,
                          ),
                          label: Text(
                            'Marquer les $notMarkedCount non-marqués comme absents',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange[700],
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.orange[300]!,
                              width: 1,
                            ),
                            backgroundColor: Colors.orange[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Bouton principal de validation
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting ? null : _submitAttendance,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(modeIcon, size: 24),
                        label: Text(
                          isSubmitting
                              ? 'Enregistrement...'
                              : 'Valider l\'appel d\'$modeTitle (${presentCount + absentCount}/${widget.students.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: modeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StudentSummaryCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final Function(String?) onStatusChanged;

  const _StudentSummaryCard({
    required this.student,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final status = student['attendance_status'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(status), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar et informations de l'élève
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getAvatarColor(status),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      '${student['order'] ?? '?'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${student['first_name']} ${student['last_name']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (student['student_number'] != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          student['student_number'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Boutons d'action
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                label: 'P',
                color: Colors.green,
                isSelected: status == 'present',
                onPressed: () =>
                    onStatusChanged(status == 'present' ? null : 'present'),
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'A',
                color: Colors.red,
                isSelected: status == 'absent',
                onPressed: () =>
                    onStatusChanged(status == 'absent' ? null : 'absent'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBorderColor(String? status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey[300]!;
    }
  }

  Color _getAvatarColor(String? status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      default:
        return Colors.grey[400]!;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }
}
