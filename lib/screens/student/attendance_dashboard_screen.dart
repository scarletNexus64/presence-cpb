import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../services/student_api_service.dart';
import 'attendance_screen.dart';

class AttendanceDashboardScreen extends StatefulWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  State<AttendanceDashboardScreen> createState() =>
      _AttendanceDashboardScreenState();
}

class _AttendanceDashboardScreenState extends State<AttendanceDashboardScreen> {
  final StudentApiService _apiService = StudentApiService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<dynamic> _attendanceStates = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadAttendanceStates();
  }

  Future<void> _loadAttendanceStates() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dateStr =
          _selectedDay?.toIso8601String().split('T')[0] ??
          DateTime.now().toIso8601String().split('T')[0];

      final response = await _apiService.getDailyAttendanceStates(
        date: dateStr,
      );

      if (mounted && response.success) {
        setState(() {
          _attendanceStates = response.data['states'] ?? [];
          _statistics = response.data['statistics'];
          _isLoading = false;
        });

        // Debug: Afficher les états récupérés
        print(
          '📊 États d\'appel récupérés: ${_attendanceStates.length} séries',
        );
        for (var state in _attendanceStates) {
          print(
            '📚 ${state['full_name']}: entrée=${state['entry_state']}, sortie=${state['exit_state']}',
          );
        }
      } else {
        setState(() {
          _error = response.message ?? 'Erreur lors du chargement';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur de connexion: $e';
        _isLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _loadAttendanceStates();
  }

  Future<void> _navigateToAttendance(
    Map<String, dynamic> seriesState,
    String mode,
  ) async {
    // D'abord, récupérer les Eleves de la série
    final studentsResponse = await _apiService.getStudentsBySeries(
      seriesState['series_id'],
    );

    if (!studentsResponse.success || !mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${studentsResponse.message}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Gérer le nouveau format de réponse
    List<dynamic> studentsList;
    if (studentsResponse.data is Map<String, dynamic> &&
        studentsResponse.data.containsKey('students')) {
      // Nouveau format
      studentsList = studentsResponse.data['students'];
    } else {
      // Ancien format
      studentsList = studentsResponse.data;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceScreen(
          seriesId: seriesState['series_id'],
          seriesName: seriesState['series_name'],
          className: seriesState['class_name'],
          levelName: seriesState['level_name'],
          sectionName: seriesState['section_name'],
          students: studentsList,
          mode: mode,
          selectedDate: _selectedDay,
        ),
      ),
    );

    // Recharger les états si l'appel a été fait
    if (result == true) {
      // Petite pause pour laisser le temps au backend de traiter
      await Future.delayed(const Duration(milliseconds: 500));
      _loadAttendanceStates();

      // Afficher un message de confirmation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Appel ${mode == 'entry' ? 'd\'entrée' : 'de sortie'} terminé - États mis à jour',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Color _getStateColor(String state) {
    switch (state) {
      case 'not_done':
        return Colors.grey[300]!;
      case 'in_progress':
        return Colors.orange[300]!;
      case 'completed':
        return Colors.green[300]!;
      default:
        return Colors.grey[300]!;
    }
  }

  Icon _getStateIcon(String state) {
    switch (state) {
      case 'not_done':
        return const Icon(Icons.schedule, color: Colors.grey);
      case 'in_progress':
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'completed':
        return const Icon(Icons.check_circle, color: Colors.green);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Tableau de bord des appels',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadAttendanceStates,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Actualiser les états',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendrier
          Container(
            margin: const EdgeInsets.all(16),
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
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: _onDaySelected,
              calendarFormat: CalendarFormat.week,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: TextStyle(color: Colors.grey[600]),
                selectedDecoration: BoxDecoration(
                  color: Colors.indigo[600],
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.indigo[300],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Statistiques
          if (_statistics != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
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
                  Expanded(
                    child: _StatCard(
                      title: 'Classes totales',
                      value: '${_statistics!['total_series']}',
                      color: Colors.blue,
                      icon: Icons.class_,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Entrées faites',
                      value: '${_statistics!['entries_completed']}',
                      color: Colors.green,
                      icon: Icons.login,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Sorties faites',
                      value: '${_statistics!['exits_completed']}',
                      color: Colors.orange,
                      icon: Icons.logout,
                    ),
                  ),
                ],
              ),
            ),

          // Date sélectionnée
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.indigo[600]),
                const SizedBox(width: 8),
                Text(
                  'Appels du ${_selectedDay?.day.toString().padLeft(2, '0')}/${_selectedDay?.month.toString().padLeft(2, '0')}/${_selectedDay?.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Liste des classes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadAttendanceStates,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  )
                : _attendanceStates.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune classe trouvée pour cette date',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _attendanceStates.length,
                    itemBuilder: (context, index) {
                      final seriesState = _attendanceStates[index];
                      return _ClassCard(
                        seriesState: seriesState,
                        onEntryTap: (seriesState['can_take_entry'] as bool)
                            ? () => _navigateToAttendance(seriesState, 'entry')
                            : null,
                        onExitTap: (seriesState['can_take_exit'] as bool)
                            ? () => _navigateToAttendance(seriesState, 'exit')
                            : null,
                        getStateColor: _getStateColor,
                        getStateIcon: _getStateIcon,
                      );
                    },
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
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ClassCard extends StatelessWidget {
  final Map<String, dynamic> seriesState;
  final VoidCallback? onEntryTap;
  final VoidCallback? onExitTap;
  final Color Function(String) getStateColor;
  final Icon Function(String) getStateIcon;

  const _ClassCard({
    required this.seriesState,
    required this.onEntryTap,
    required this.onExitTap,
    required this.getStateColor,
    required this.getStateIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = seriesState['is_day_completed'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(color: Colors.green[300]!, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de la classe
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.class_,
                    color: Colors.indigo[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seriesState['full_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${seriesState['section_name']} • ${seriesState['level_name']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[700],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Terminé',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Boutons d'actions
            Row(
              children: [
                // Bouton d'entrée
                Expanded(
                  child: _ActionButton(
                    label: 'Entrée',
                    state: seriesState['entry_state'],
                    completedAt: seriesState['entry_completed_at'],
                    icon: Icons.login,
                    color: Colors.green,
                    onTap: onEntryTap,
                    getStateColor: getStateColor,
                    getStateIcon: getStateIcon,
                  ),
                ),

                const SizedBox(width: 12),

                // Bouton de sortie
                Expanded(
                  child: _ActionButton(
                    label: 'Sortie',
                    state: seriesState['exit_state'],
                    completedAt: seriesState['exit_completed_at'],
                    icon: Icons.logout,
                    color: Colors.orange,
                    onTap: onExitTap,
                    getStateColor: getStateColor,
                    getStateIcon: getStateIcon,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String state;
  final String? completedAt;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final Color Function(String) getStateColor;
  final Icon Function(String) getStateIcon;

  const _ActionButton({
    required this.label,
    required this.state,
    required this.completedAt,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.getStateColor,
    required this.getStateIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    final bgColor = isEnabled ? color.withOpacity(0.1) : getStateColor(state);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? color.withOpacity(0.3) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isEnabled ? color : Colors.grey[600],
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isEnabled ? color : Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getStateIcon(state),
                const SizedBox(width: 4),
                Text(
                  _getStateLabel(state, completedAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStateLabel(String state, String? completedAt) {
    switch (state) {
      case 'not_done':
        return 'À faire';
      case 'in_progress':
        return 'En cours...';
      case 'completed':
        return completedAt != null ? 'Fait à $completedAt' : 'Terminé';
      default:
        return 'Inconnu';
    }
  }
}
