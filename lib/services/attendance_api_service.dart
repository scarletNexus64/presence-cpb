import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/api_response.dart';
import '../models/staff_member.dart';
import '../models/staff_attendance.dart';

class AttendanceApiService {
  static final AttendanceApiService _instance =
      AttendanceApiService._internal();
  late final Dio _dio;
  String? _jwtToken;

  AttendanceApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? 'http://admin1.cpb-douala.com',
        connectTimeout: Duration(
          milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'),
        ),
        receiveTimeout: Duration(
          milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      ),
    );

    // Intercepteur pour ajouter automatiquement le JWT
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // TOUJOURS recharger le token depuis le storage pour s'assurer qu'il est à jour
          await _loadTokenFromStorage();

          // Ajouter le token JWT s'il existe
          if (_jwtToken != null) {
            options.headers['Authorization'] = 'Bearer $_jwtToken';
          }

          // Log pour debug du token
          print(
            '🔑 DEBUG TOKEN: ${_jwtToken != null ? 'Token présent (${_jwtToken!.length} chars)' : 'Aucun token'}',
          );

          // Log détaillé en mode debug
          if (dotenv.env['DEBUG_MODE'] == 'true') {
            print('🔗 REQUEST: ${options.method} ${options.uri}');
            print('📤 HEADERS: ${options.headers}');
            print('📦 DATA: ${options.data}');
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (dotenv.env['DEBUG_MODE'] == 'true') {
            print(
              '✅ RESPONSE: ${response.statusCode} ${response.statusMessage}',
            );
            print('📥 DATA: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (dotenv.env['DEBUG_MODE'] == 'true') {
            print('❌ ERROR: ${error.type} - ${error.message}');
            print('🔍 RESPONSE: ${error.response?.data}');
          }
          handler.next(error);
        },
      ),
    );

    // Ajouter des intercepteurs pour les logs détaillés
    if (dotenv.env['ENABLE_LOGGING'] == 'true') {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          logPrint: (obj) {
            print('🌐 HTTP LOG: $obj');
          },
        ),
      );
    }
  }

  factory AttendanceApiService() => _instance;

  /// Charger le token JWT depuis le stockage local
  Future<void> _loadTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _jwtToken = prefs.getString('jwt_token');

      if (dotenv.env['DEBUG_MODE'] == 'true') {
        print(
          '🔑 JWT Token loaded: ${_jwtToken != null ? 'YES (${_jwtToken!.length} chars)' : 'NO'}',
        );
      }
    } catch (e) {
      print('❌ Error loading JWT token: $e');
    }
  }

  /// Sauvegarder le token JWT
  Future<void> setJwtToken(String token) async {
    _jwtToken = token;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      if (dotenv.env['DEBUG_MODE'] == 'true') {
        print('🔑 JWT Token saved: ${token.length} chars');
      }
    } catch (e) {
      print('❌ Error saving JWT token: $e');
    }
  }

  /// Effacer le token JWT
  Future<void> clearJwtToken() async {
    _jwtToken = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');

      if (dotenv.env['DEBUG_MODE'] == 'true') {
        print('🔑 JWT Token cleared');
      }
    } catch (e) {
      print('❌ Error clearing JWT token: $e');
    }
  }

  /// Authentification avec username/password
  Future<ApiResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'username': username, 'password': password},
      );

      if (response.data['success'] == true) {
        final token = response.data['token'] ?? response.data['access_token'];
        if (token != null) {
          await setJwtToken(token);
          print('🔑 LOGIN SUCCESS: Token sauvegardé (${token.length} chars)');
        } else {
          print('⚠️ LOGIN: Aucun token reçu du serveur');
        }
      } else {
        print('❌ LOGIN FAILED: ${response.data['message']}');
      }

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Erreur inattendue lors de la connexion: $e');
    }
  }

  /// Déconnexion
  Future<ApiResponse> logout() async {
    try {
      final response = await _dio.post('/api/logout');
      await clearJwtToken();
      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      await clearJwtToken(); // Clear token même en cas d'erreur
      return _handleDioError(e);
    } catch (e) {
      await clearJwtToken();
      return ApiResponse.error('Erreur lors de la déconnexion: $e');
    }
  }

  /// Scanner un QR code et enregistrer la présence
  Future<ApiResponse> scanQRCode({
    required String qrCode,
    required int supervisorId,
    String eventType = 'auto',
  }) async {
    try {
      final response = await _dio.post(
        '/api/staff-attendance/scan-qr',
        data: {
          'staff_qr_code': qrCode,
          'supervisor_id': supervisorId,
          'event_type': eventType,
        },
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Erreur inattendue: $e');
    }
  }

  /// Obtenir les présences du jour
  Future<ApiResponse> getDailyAttendances({
    DateTime? date,
    String? staffType,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};

      if (date != null) {
        queryParams['date'] = date.toIso8601String().split('T')[0];
      }

      if (staffType != null) {
        queryParams['staff_type'] = staffType;
      }

      final response = await _dio.get(
        '/api/staff-attendance/daily',
        queryParameters: queryParams,
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Erreur inattendue: $e');
    }
  }

  /// Générer un QR code pour un personnel
  Future<ApiResponse> generateQRCode(int userId) async {
    try {
      final response = await _dio.post(
        '/api/staff-attendance/generate-qr',
        data: {'user_id': userId},
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Erreur inattendue: $e');
    }
  }

  /// Vérifier la connexion au serveur
  Future<bool> checkConnection() async {
    try {
      // Essayer d'abord l'endpoint de test simple
      final response = await _dio.get('/api/test');
      return response.statusCode == 200;
    } catch (e) {
      // Si ça échoue, essayer la racine
      try {
        final response = await _dio.get('/');
        return response.statusCode == 200;
      } catch (e2) {
        if (dotenv.env['DEBUG_MODE'] == 'true') {
          print('❌ Connection failed: $e2');
        }
        return false;
      }
    }
  }

  /// Tester l'endpoint sans authentification
  Future<ApiResponse> testEndpointNoAuth() async {
    try {
      final response = await _dio.post(
        '/api/test/scan-qr-no-auth',
        data: {
          'staff_qr_code': 'TEST_QR_CODE',
          'supervisor_id': 1,
          'test_data': 'Test depuis Flutter ${DateTime.now()}',
        },
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Erreur test endpoint: $e');
    }
  }

  /// Tester l'authentification JWT
  Future<ApiResponse> testJWTAuth() async {
    try {
      final response = await _dio.post(
        '/api/test/scan-qr-with-debug-auth',
        data: {'test_data': 'Test JWT depuis Flutter ${DateTime.now()}'},
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Erreur test JWT: $e');
    }
  }

  /// Tester l'endpoint staff attendance avec debug
  Future<ApiResponse> testStaffAttendanceWithDebug({
    required String qrCode,
    required int supervisorId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/test/staff-attendance-debug',
        data: {
          'staff_qr_code': qrCode,
          'supervisor_id': supervisorId,
          'event_type': 'entry',
        },
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Erreur test staff attendance: $e');
    }
  }

  /// Extraire l'user_id du JWT token
  int? getCurrentUserId() {
    if (_jwtToken == null) return null;

    try {
      // Décoder le JWT (format: header.payload.signature)
      final parts = _jwtToken!.split('.');
      if (parts.length != 3) return null;

      // Décoder la partie payload (base64)
      final payload = parts[1];
      // Ajouter padding si nécessaire
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = json.decode(decoded);

      // Récupérer l'user_id depuis le claim 'sub'
      final sub = claims['sub'];
      return sub != null ? int.tryParse(sub.toString()) : null;
    } catch (e) {
      print('❌ Erreur décodage JWT: $e');
      return null;
    }
  }

  /// Supprimer les scans d'aujourd'hui pour un utilisateur (pour les tests)
  Future<ApiResponse> clearTodayScans({
    int? userId,
    String? date,
    bool clearAll = false,
  }) async {
    try {
      final data = <String, dynamic>{
        if (date != null) 'date': date,
        if (clearAll) 'clear_all': true,
        if (!clearAll && userId != null) 'user_id': userId,
      };

      final response = await _dio.delete(
        '/api/staff-attendance/clear-today-scans',
        data: data,
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return ApiResponse.error('Erreur suppression scans: $e');
    }
  }

  /// Gestion des erreurs Dio
  ApiResponse _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiResponse.error(
          'Délai d\'attente dépassé. Vérifiez votre connexion.',
          errorCode: 408,
        );

      case DioExceptionType.connectionError:
        return ApiResponse.error(
          'Impossible de se connecter au serveur.',
          errorCode: 503,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final responseData = e.response?.data;

        String message = 'Erreur serveur';

        if (responseData is Map<String, dynamic>) {
          message = responseData['message'] ?? message;
        }

        // Messages d'erreur spécifiques selon le code de statut
        switch (statusCode) {
          case 401:
            message = 'Authentification requise. Veuillez vous connecter.';
            // Si c'est une erreur d'auth, effacer le token
            clearJwtToken();
            break;
          case 404:
            message = 'QR Code non trouvé ou personnel inexistant';
            break;
          case 403:
            message = 'Accès non autorisé pour ce personnel';
            break;
          case 422:
            message =
                'Données invalides: ${responseData?['message'] ?? 'Erreur de validation'}';
            break;
          case 429:
            message = 'Scan trop récent. Attendez quelques secondes.';
            break;
          case 400:
            message = responseData?['message'] ?? 'Données invalides';
            break;
          case 500:
            message = 'Erreur serveur interne. Réessayez plus tard.';
            break;
        }

        return ApiResponse.error(message, errorCode: statusCode);

      default:
        return ApiResponse.error(
          'Erreur de connexion: ${e.message}',
          errorCode: 500,
        );
    }
  }
}

/// Extensions pour faciliter l'usage
extension ApiResponseExtension on ApiResponse {
  StaffMember? get staffMember {
    if (data?['staff_member'] != null) {
      return StaffMember.fromJson(data!['staff_member']);
    }
    return null;
  }

  StaffAttendance? get attendance {
    if (data?['attendance'] != null) {
      return StaffAttendance.fromJson(data!['attendance']);
    }
    return null;
  }

  String? get eventType => data?['event_type'];
  String? get scanTime => data?['scan_time'];
  double? get dailyWorkTime => data?['daily_work_time']?.toDouble();
}
