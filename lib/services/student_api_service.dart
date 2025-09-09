import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';

class StudentApiService {
  static final String baseUrl =
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';

  // Token d'authentification (à gérer selon votre système)
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Récupérer le token JWT sauvegardé
  Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token != null) {
        _authToken = token;
        print(
          '🔑 Token récupéré depuis le stockage: ${token.substring(0, 20)}...',
        );
      } else {
        print('⚠️ Aucun token trouvé dans le stockage');
      }
      return token;
    } catch (e) {
      print('❌ Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  Future<Map<String, String>> get _headers async {
    // Récupérer le token si pas encore fait
    if (_authToken == null) {
      await _getStoredToken();
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      print(
        '🔑 Header Authorization ajouté avec token de ${_authToken!.length} caractères',
      );
    } else {
      print('⚠️ Aucun token disponible - requête sans authentification');
    }

    return headers;
  }

  /// Récupérer toutes les sections
  Future<ApiResponse> getSections() async {
    try {
      // 🌐 Logs détaillés de la requête API
      final url = '$baseUrl/api/sections';
      final headers =
          await _headers; // Récupération asynchrone des headers avec token

      print('');
      print('🌐 ========== REQUÊTE API SECTIONS ==========');
      print('📡 URL complète: $url');
      print('🔑 Headers: $headers');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('🚀 Envoi de la requête HTTP GET...');

      final response = await http.get(Uri.parse(url), headers: headers);

      // 📨 Log de la réponse
      print('');
      print('📨 ========== RÉPONSE DU SERVEUR ==========');
      print('🎯 Status Code: ${response.statusCode}');
      print('📏 Taille de la réponse: ${response.body.length} caractères');
      print('🏷️ Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 📊 Analyse détaillée des données
        print('');
        print('📊 ========== ANALYSE DES DONNÉES ==========');
        print('✅ Parsing JSON réussi');
        print('🔍 Structure des données:');
        if (data is Map) {
          print('   📋 Type: Map avec ${data.keys.length} clés');
          print('   🔑 Clés disponibles: ${data.keys.join(", ")}');

          if (data.containsKey('data')) {
            final sections = data['data'];
            if (sections is List) {
              print('   📊 Nombre de sections: ${sections.length}');

              // Log de chaque section trouvée
              for (int i = 0; i < sections.length; i++) {
                final section = sections[i] as Map<String, dynamic>;
                print(
                  '   🏫 Section ${i + 1}: ${section['name']} (ID: ${section['id']})',
                );
              }
            }
          }
        }

        // Retourner directement la liste des sections
        final sections = data['data'] ?? [];
        return ApiResponse(
          success: true,
          data: sections,
          message: 'Sections récupérées avec succès',
        );
      } else {
        // ❌ Gestion des erreurs HTTP
        print('');
        print('❌ ========== ERREUR HTTP ==========');
        print('🔴 Status Code: ${response.statusCode}');
        print('📝 Corps de la réponse: ${response.body}');
        print('🏷️ Raison: ${response.reasonPhrase}');

        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      // 💥 Gestion des exceptions
      print('');
      print('💥 ========== EXCEPTION ATTRAPÉE ==========');
      print('🔴 Type: ${e.runtimeType}');
      print('📝 Message: $e');
      print('⚡ Stack trace disponible pour débogage');

      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Récupérer les niveaux d'une section
  Future<ApiResponse> getLevelsBySection(int sectionId) async {
    try {
      // 🌐 Logs détaillés de la requête API pour les niveaux
      final url = '$baseUrl/api/mobile/sections/$sectionId/levels';
      print('');
      print('🌐 ========== REQUÊTE API NIVEAUX ==========');
      print('📡 URL complète: $url');
      print('🆔 Section ID: $sectionId');
      print('🔑 Headers: ${await _headers}');
      print('⏰ Timestamp: ${DateTime.now().toIso8601String()}');
      print('🚀 Envoi de la requête HTTP GET pour les niveaux...');

      final response = await http.get(Uri.parse(url), headers: await _headers);

      // 📨 Log de la réponse
      print('');
      print('📨 ========== RÉPONSE DU SERVEUR (NIVEAUX) ==========');
      print('🎯 Status Code: ${response.statusCode}');
      print('📏 Taille de la réponse: ${response.body.length} caractères');
      print('🏷️ Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 📊 Analyse détaillée des données
        print('');
        print('📊 ========== ANALYSE DES NIVEAUX ==========');
        print('✅ Parsing JSON réussi');
        print('🔍 Structure des données:');
        if (data is Map) {
          print('   📋 Type: Map avec ${data.keys.length} clés');
          print('   🔑 Clés disponibles: ${data.keys.join(", ")}');

          if (data.containsKey('data')) {
            final levels = data['data'];
            if (levels is List) {
              print('   📊 Nombre de niveaux: ${levels.length}');

              // Log de chaque niveau trouvé
              for (int i = 0; i < levels.length; i++) {
                final level = levels[i];
                print(
                  '   🎓 Niveau ${i + 1}: ${level['name']} (ID: ${level['id']})',
                );
              }
            }
          }
        }

        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: 'Niveaux récupérés avec succès',
        );
      } else {
        // ❌ Gestion des erreurs HTTP
        print('');
        print('❌ ========== ERREUR HTTP (NIVEAUX) ==========');
        print('🔴 Status Code: ${response.statusCode}');
        print('📝 Corps de la réponse: ${response.body}');
        print('🏷️ Raison: ${response.reasonPhrase}');

        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      // 💥 Gestion des exceptions
      print('');
      print('💥 ========== EXCEPTION (NIVEAUX) ==========');
      print('🔴 Type: ${e.runtimeType}');
      print('📝 Message: $e');
      print('⚡ Stack trace disponible pour débogage');

      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Récupérer les classes d'un niveau
  Future<ApiResponse> getClassesByLevel(int levelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/levels/$levelId/classes'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: 'Classes récupérées avec succès',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Récupérer les séries d'une classe
  Future<ApiResponse> getSeriesByClass(int classId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/classes/$classId/series'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: 'Séries récupérées avec succès',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Récupérer les élèves d'une série
  Future<ApiResponse> getStudentsBySeries(int seriesId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mobile/students/series/$seriesId'),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;

        // Nouvelle structure : vérifier si c'est le nouveau format avec students/series_info/attendance_state
        if (data is Map<String, dynamic> && data.containsKey('students')) {
          // Nouveau format - retourner toute la structure
          return ApiResponse(
            success: true,
            data: data,
            message: 'Élèves récupérés avec succès',
          );
        } else {
          // Ancien format - retourner directement les données
          return ApiResponse(
            success: true,
            data: data,
            message: 'Élèves récupérés avec succès',
          );
        }
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Soumettre les présences d'une série (Bulk Attendance)
  Future<ApiResponse> submitBulkAttendance({
    required int seriesId,
    required String eventType, // 'entry' ou 'exit'
    required List<Map<String, dynamic>> students,
    String? notes,
    String? attendanceDate,
  }) async {
    print('');
    print('🚀 ========== DÉBUT SOUMISSION DES PRÉSENCES ==========');
    print('📍 Series ID: $seriesId');
    print('🔄 Event Type: $eventType');
    print('📊 Nombre d\'élèves: ${students.length}');
    print('🗓️ Date: ${DateTime.now().toIso8601String().split('T')[0]}');
    print('📝 Notes: ${notes ?? 'Aucune'}');

    try {
      // Formater la date au bon format (YYYY-MM-DD)
      final String finalDate;
      if (attendanceDate != null) {
        finalDate = attendanceDate;
      } else {
        final today = DateTime.now();
        finalDate =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      }

      final requestBody = {
        'series_id': seriesId,
        'event_type': eventType,
        'attendance_date': finalDate,
        'students': students
            .map(
              (student) => {
                'student_id': student['id'],
                'is_present': student['attendance_status'] == 'present',
                'student_number': student['student_number'],
              },
            )
            .toList(),
        'notes': notes,
      };

      print('');
      print('📤 ========== CORPS DE LA REQUÊTE ==========');
      print('🎯 Endpoint: /api/attendance/students/submit');
      print('📋 Body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl/api/attendance/students/submit'),
        headers: await _headers,
        body: json.encode(requestBody),
      );

      print('');
      print('📨 ========== RÉPONSE DU SERVEUR ==========');
      print('🎯 Status Code: ${response.statusCode}');
      print('📏 Taille de la réponse: ${response.body.length} caractères');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Réponse: SUCCÈS');
        print('📊 Données: ${data['data']}');

        print('');
        print('✅ ========== PRÉSENCES ENREGISTRÉES ==========');
        print('🎉 ${data['message'] ?? 'Présences enregistrées avec succès'}');

        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: data['message'] ?? 'Présences enregistrées avec succès',
        );
      } else {
        print('❌ Réponse: ÉCHEC');
        print('🔴 Corps de la réponse: ${response.body}');

        final errorData = json.decode(response.body);
        print('');
        print('❌ ========== ERREUR API ==========');
        print('🔴 Message: ${errorData['message']}');

        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erreur lors de l\'enregistrement',
        );
      }
    } catch (e) {
      print('');
      print('💥 ========== EXCEPTION ATTRAPÉE ==========');
      print('🔴 Erreur: $e');

      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Vérifier le statut des appels pour une série et une date
  Future<ApiResponse> getAttendanceStatus({
    required int seriesId,
    String? date,
  }) async {
    try {
      final queryDate = date ?? DateTime.now().toIso8601String().split('T')[0];

      final response = await http.get(
        Uri.parse(
          '$baseUrl/api/attendance/stats?date=$queryDate&series_id=$seriesId',
        ),
        headers: await _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: 'Statut récupéré avec succès',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Récupérer les statistiques de présence pour une date et un filtre
  Future<ApiResponse> getAttendanceStats({
    required String date,
    int? sectionId,
    int? levelId,
    int? classId,
    int? seriesId,
  }) async {
    try {
      final queryParams = <String, String>{'date': date};

      if (sectionId != null) queryParams['section_id'] = sectionId.toString();
      if (levelId != null) queryParams['level_id'] = levelId.toString();
      if (classId != null) queryParams['class_id'] = classId.toString();
      if (seriesId != null) queryParams['series_id'] = seriesId.toString();

      final uri = Uri.parse(
        '$baseUrl/api/attendance/students/mobile/stats',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: 'Statistiques récupérées avec succès',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Récupérer les présences détaillées pour une date et un filtre
  Future<ApiResponse> getAttendanceDetails({
    required String date,
    int? sectionId,
    int? levelId,
    int? classId,
    int? seriesId,
  }) async {
    try {
      final queryParams = <String, String>{'date': date};

      if (sectionId != null) queryParams['section_id'] = sectionId.toString();
      if (levelId != null) queryParams['level_id'] = levelId.toString();
      if (classId != null) queryParams['class_id'] = classId.toString();
      if (seriesId != null) queryParams['series_id'] = seriesId.toString();

      final uri = Uri.parse(
        '$baseUrl/api/attendance/students',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: 'Présences récupérées avec succès',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Scanner un QR code d'élève (pour le mode automatique futur)
  Future<ApiResponse> scanStudentQR({
    required String qrCode,
    required String eventType, // 'entry' ou 'exit'
  }) async {
    try {
      final requestBody = {
        'qr_code': qrCode,
        'event_type': eventType,
        'scanned_at': DateTime.now().toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/attendance/students/scan'),
        headers: await _headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: data['message'] ?? 'Présence enregistrée avec succès',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erreur lors du scan',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Marquer manuellement la présence/absence d'un étudiant
  Future<ApiResponse> markStudentAttendance({
    required int studentId,
    required String eventType, // 'entry' ou 'exit'
    required String attendanceDate,
    required bool isPresent,
    String? notes,
  }) async {
    try {
      final requestBody = {
        'student_id': studentId,
        'event_type': eventType,
        'attendance_date': attendanceDate,
        'is_present': isPresent,
        'notes': notes ?? '',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/attendance/students/mark'),
        headers: await _headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: data['message'] ?? 'Présence marquée avec succès',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erreur lors du marquage',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Marquer tous les Eleves absents d'une série
  Future<ApiResponse> markAllAbsentInSeries({
    required int seriesId,
    required String attendanceDate,
    String? notes,
  }) async {
    try {
      final requestBody = {
        'series_id': seriesId,
        'attendance_date': attendanceDate,
        'notes': notes ?? 'Marquage automatique des absents',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/attendance/students/mark-absent-series'),
        headers: await _headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: data['message'] ?? 'Absences marquées avec succès',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message:
              errorData['message'] ?? 'Erreur lors du marquage des absences',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Obtenir le statut actuel d'un étudiant
  Future<ApiResponse> getStudentStatus({
    required int studentId,
    String? date,
  }) async {
    try {
      final queryParams = <String, String>{'student_id': studentId.toString()};

      if (date != null) {
        queryParams['date'] = date;
      }

      final uri = Uri.parse(
        '$baseUrl/api/attendance/students/status',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: 'Statut récupéré avec succès',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message:
              errorData['message'] ??
              'Erreur lors de la récupération du statut',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Obtenir les statistiques de présence en temps réel
  Future<ApiResponse> getRealtimeStats({
    String? date,
    int? sectionId,
    int? levelId,
    int? classId,
    int? seriesId,
  }) async {
    try {
      final queryParams = <String, String>{
        'date': date ?? DateTime.now().toIso8601String().split('T')[0],
      };

      if (sectionId != null) queryParams['section_id'] = sectionId.toString();
      if (levelId != null) queryParams['level_id'] = levelId.toString();
      if (classId != null) queryParams['class_id'] = classId.toString();
      if (seriesId != null) queryParams['series_id'] = seriesId.toString();

      final uri = Uri.parse(
        '$baseUrl/api/attendance/students/mobile/stats',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'] ?? data,
          message: 'Statistiques récupérées avec succès',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Utilitaires pour formater les dates
  String formatDateForApi(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  /// Obtenir la date d'aujourd'hui formatée pour l'API
  String getTodayFormatted() {
    return formatDateForApi(DateTime.now());
  }

  /// Obtenir les états d'appel quotidiens
  Future<ApiResponse> getDailyAttendanceStates({
    String? date,
    int? sectionId,
    int? levelId,
    int? classId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (date != null) queryParams['date'] = date;
      if (sectionId != null) queryParams['section_id'] = sectionId.toString();
      if (levelId != null) queryParams['level_id'] = levelId.toString();
      if (classId != null) queryParams['class_id'] = classId.toString();

      final uri = Uri.parse(
        '$baseUrl/api/attendance/daily-states',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'],
          message: 'États d\'appel récupérés avec succès',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Obtenir l'état d'appel d'une série
  Future<ApiResponse> getSeriesAttendanceState({
    required int seriesId,
    String? date,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (date != null) queryParams['date'] = date;

      final uri = Uri.parse(
        '$baseUrl/api/attendance/series/$seriesId/state',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await http.get(uri, headers: await _headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'],
          message: 'État d\'appel récupéré avec succès',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Réinitialiser l'état d'appel d'une série (admin seulement)
  Future<ApiResponse> resetSeriesAttendanceState({
    required int seriesId,
    required String resetType, // 'entry', 'exit', 'both'
    String? date,
  }) async {
    try {
      final requestBody = {'reset_type': resetType};
      if (date != null) requestBody['date'] = date;

      final response = await http.post(
        Uri.parse('$baseUrl/api/attendance/series/$seriesId/reset-state'),
        headers: await _headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return ApiResponse(
          success: true,
          data: data['data'],
          message: data['message'] ?? 'État réinitialisé avec succès',
        );
      } else {
        final errorData = json.decode(response.body);
        return ApiResponse(
          success: false,
          message: errorData['message'] ?? 'Erreur lors de la réinitialisation',
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Erreur de connexion: $e');
    }
  }

  /// Test de connexion sans authentification
  Future<ApiResponse> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/test'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          success: true,
          message: 'Connexion au serveur réussie',
        );
      } else {
        return ApiResponse(
          success: false,
          message: 'Erreur de connexion: ${response.statusCode}',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Impossible de se connecter au serveur: $e',
      );
    }
  }
}
