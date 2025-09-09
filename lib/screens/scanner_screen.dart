import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';
import '../services/attendance_api_service.dart';
import '../models/api_response.dart';
import 'home_screen.dart';

class ScannerScreen extends StatefulWidget {
  final ScanType scanType;

  const ScannerScreen({
    super.key,
    required this.scanType,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController controller = MobileScannerController();
  final AttendanceApiService _apiService = AttendanceApiService();
  bool isProcessing = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final connected = await _apiService.checkConnection();
    if (mounted) {
      setState(() {
        isConnected = connected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.scanType == ScanType.arrival 
              ? 'Scanner - Arrivée' 
              : 'Scanner - Départ',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: widget.scanType == ScanType.arrival 
            ? Colors.green[700] 
            : Colors.red[700],
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _checkConnection,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: widget.scanType == ScanType.arrival 
                ? Colors.green[50] 
                : Colors.red[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      widget.scanType == ScanType.arrival 
                          ? Icons.login 
                          : Icons.logout,
                      color: widget.scanType == ScanType.arrival 
                          ? Colors.green[700] 
                          : Colors.red[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Scannez le QR code (format: STAFF_123) pour ${widget.scanType == ScanType.arrival ? "l'arrivée" : "le départ"}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isConnected) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[600], size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Mode hors ligne - Vérifiez votre connexion',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // Scanner camera
                MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        _processQrCode(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
                // Overlay avec cadre de visée
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: widget.scanType == ScanType.arrival 
                              ? Colors.green 
                              : Colors.red,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          // Coins animés pour indiquer la zone de scan
                          ...List.generate(4, (index) {
                            return Positioned(
                              top: index < 2 ? 0 : null,
                              bottom: index >= 2 ? 0 : null,
                              left: index == 0 || index == 2 ? 0 : null,
                              right: index == 1 || index == 3 ? 0 : null,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: (index < 2) ? BorderSide(
                                      color: widget.scanType == ScanType.arrival 
                                          ? Colors.green 
                                          : Colors.red,
                                      width: 4,
                                    ) : BorderSide.none,
                                    bottom: (index >= 2) ? BorderSide(
                                      color: widget.scanType == ScanType.arrival 
                                          ? Colors.green 
                                          : Colors.red,
                                      width: 4,
                                    ) : BorderSide.none,
                                    left: (index == 0 || index == 2) ? BorderSide(
                                      color: widget.scanType == ScanType.arrival 
                                          ? Colors.green 
                                          : Colors.red,
                                      width: 4,
                                    ) : BorderSide.none,
                                    right: (index == 1 || index == 3) ? BorderSide(
                                      color: widget.scanType == ScanType.arrival 
                                          ? Colors.green 
                                          : Colors.red,
                                      width: 4,
                                    ) : BorderSide.none,
                                  ),
                                ),
                              ),
                            );
                          }),
                          // Instructions au centre
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 180),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Placez le QR code\ndans ce cadre',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Boutons de contrôle
                Positioned(
                  top: 20,
                  right: 20,
                  child: Column(
                    children: [
                      // Bouton torche
                      CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: IconButton(
                          icon: Icon(
                            Icons.flash_on,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            controller.toggleTorch();
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Bouton flip camera
                      CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: IconButton(
                          icon: Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            controller.switchCamera();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEEE dd MMMM yyyy - HH:mm')
                        .format(DateTime.now()),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (isProcessing)
                    const Column(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Connexion au serveur...',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      isConnected 
                          ? 'En attente du scan...' 
                          : 'Hors ligne - Reconnexion requise',
                      style: TextStyle(
                        fontSize: 12,
                        color: isConnected ? Colors.grey[500] : Colors.red[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processQrCode(String qrCode) async {
    if (isProcessing) return;
    
    // Vérifier le format du QR code
    if (!qrCode.startsWith('STAFF_')) {
      _showErrorDialog(
        'Format QR invalide',
        'Le QR code doit avoir le format STAFF_XXX\nCode scanné: $qrCode',
      );
      return;
    }

    if (!isConnected) {
      _showErrorDialog(
        'Pas de connexion',
        'Impossible de traiter le scan. Vérifiez votre connexion réseau.',
      );
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      controller.stop();
      
      // Récupérer l'user_id depuis le JWT token
      int supervisorId = _apiService.getCurrentUserId() ?? 82; // Fallback sur 82 si JWT invalide
      
      // Déterminer l'event_type selon le bouton sélectionné dans HomeScreen
      String eventType = widget.scanType == ScanType.arrival ? 'entry' : 'exit';
      
      // Envoyer la demande à l'API Laravel avec event_type strict
      final response = await _apiService.scanQRCode(
        qrCode: qrCode,
        supervisorId: supervisorId,
        eventType: eventType, // 'entry' pour Arrivée, 'exit' pour Départ
      );
      
      if (response.success) {
        final staffMember = response.staffMember;
        final attendance = response.attendance;
        
        if (staffMember != null && attendance != null) {
          _showSuccessDialog(
            staffMember.name,
            _getEventTypeDisplay(response.eventType ?? attendance.eventType),
            DateFormat('HH:mm').format(attendance.scannedAt),
            staffMember.staffType,
            attendance.lateMinutes,
            response.dailyWorkTime,
          );
        } else {
          _showSuccessDialog(
            'Personnel',
            response.eventType ?? 'Événement',
            response.scanTime ?? DateFormat('HH:mm').format(DateTime.now()),
            'N/A',
            0,
            response.dailyWorkTime,
          );
        }
      } else {
        _showErrorDialog(
          _getErrorTitle(response.errorCode, response.data),
          response.message,
          errorData: response.data,
        );
      }
      
    } catch (e) {
      _showErrorDialog(
        'Erreur de connexion',
        'Impossible de communiquer avec le serveur: $e',
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  String _getEventTypeDisplay(String eventType) {
    switch (eventType) {
      case 'entry':
        return 'Arrivée';
      case 'exit':
        return 'Départ';
      default:
        return eventType;
    }
  }

  String _getErrorTitle(int? errorCode, Map<String, dynamic>? errorData) {
    // Vérifier d'abord les codes d'erreur spécifiques
    if (errorData != null) {
      final String? specificError = errorData['error_code'];
      switch (specificError) {
        case 'DAILY_SCAN_LIMIT_EXCEEDED':
          return 'Limite quotidienne atteinte';
        case 'ENTRY_ALREADY_RECORDED':
          return 'Entrée déjà enregistrée';
        case 'EXIT_ALREADY_RECORDED':
          return 'Sortie déjà enregistrée';
        case 'NO_ENTRY_RECORDED':
          return 'Aucune entrée trouvée';
      }
    }

    // Fallback sur les codes HTTP standards
    switch (errorCode) {
      case 404:
        return 'Personnel non trouvé';
      case 403:
        return 'Accès non autorisé';
      case 429:
        return 'Scan trop récent';
      case 422:
        return 'Action non autorisée';
      case 400:
        return 'Données invalides';
      default:
        return 'Erreur';
    }
  }

  void _showSuccessDialog(
    String employeeName, 
    String action, 
    String time,
    String staffType,
    int lateMinutes,
    double? dailyWorkTime,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 32,
              ),
              const SizedBox(width: 12),
              const Text('Succès'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                employeeName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('$action enregistrée à $time'),
              const SizedBox(height: 8),
              Text(
                'Type: $staffType',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (lateMinutes > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Retard: ${lateMinutes} minutes',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (dailyWorkTime != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Temps de travail: ${dailyWorkTime.toStringAsFixed(1)}h',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Retour à l\'accueil'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.start();
              },
              child: const Text('Continuer le scan'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message, {Map<String, dynamic>? errorData}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error,
                color: Colors.red[600],
                size: 32,
              ),
              const SizedBox(width: 12),
              Flexible(child: Text(title)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                // Afficher des détails supplémentaires pour les erreurs de limite
                if (errorData != null) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildErrorDetails(errorData),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Retour à l\'accueil'),
            ),
            // Masquer le bouton "Réessayer" pour les erreurs de limite quotidienne
            if (!_isDailyLimitError(errorData))
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  controller.start();
                  _checkConnection(); // Vérifier la connexion
                },
                child: const Text('Réessayer'),
              ),
          ],
        );
      },
    );
  }

  // Vérifier si c'est une erreur de limite quotidienne
  bool _isDailyLimitError(Map<String, dynamic>? errorData) {
    if (errorData == null) return false;
    final String? errorCode = errorData['error_code'];
    return errorCode == 'DAILY_SCAN_LIMIT_EXCEEDED' ||
           errorCode == 'ENTRY_ALREADY_RECORDED' ||
           errorCode == 'EXIT_ALREADY_RECORDED';
  }

  // Construire les détails d'erreur selon le type
  Widget _buildErrorDetails(Map<String, dynamic> errorData) {
    final String? errorCode = errorData['error_code'];
    
    switch (errorCode) {
      case 'DAILY_SCAN_LIMIT_EXCEEDED':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text('• Entrées aujourd\'hui: ${errorData['entries_today'] ?? 0}/1'),
            Text('• Sorties aujourd\'hui: ${errorData['exits_today'] ?? 0}/1'),
            if (errorData['first_entry'] != null)
              Text('• Première entrée: ${_formatDateTime(errorData['first_entry'])}'),
            if (errorData['first_exit'] != null)
              Text('• Première sortie: ${_formatDateTime(errorData['first_exit'])}'),
          ],
        );
      
      case 'ENTRY_ALREADY_RECORDED':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entrée déjà enregistrée:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text('${_formatDateTime(errorData['first_entry'])}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 Vous pouvez maintenant scanner votre sortie',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );

      case 'EXIT_ALREADY_RECORDED':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sortie déjà enregistrée:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text('${_formatDateTime(errorData['first_exit'])}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '✅ Votre journée de travail est terminée',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        );

      case 'NO_ENTRY_RECORDED':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '⚠️ ${errorData['suggestion'] ?? 'Veuillez d\'abord scanner votre entrée'}',
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 13,
            ),
          ),
        );

      default:
        return Text(
          'Code d\'erreur: $errorCode',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        );
    }
  }

  // Formater une date/heure
  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('dd/MM/yyyy à HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
}