class ApiResponse {
  final bool success;
  final String message;
  final dynamic data; // Changé de Map<String, dynamic>? à dynamic pour accepter List et Map
  final int? errorCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errorCode: json['error_code'],
    );
  }

  factory ApiResponse.error(String message, {int? errorCode}) {
    return ApiResponse(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  factory ApiResponse.success(String message, {dynamic data}) { // Changé aussi ici
    return ApiResponse(
      success: true,
      message: message,
      data: data,
    );
  }

  // Méthodes helper pour faciliter l'utilisation
  List<dynamic> get dataAsList => data is List ? data as List<dynamic> : [];
  Map<String, dynamic> get dataAsMap => data is Map ? data as Map<String, dynamic> : {};
  bool get hasListData => data is List && (data as List).isNotEmpty;
  bool get hasMapData => data is Map && (data as Map).isNotEmpty;
}
