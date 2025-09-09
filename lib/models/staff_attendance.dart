class StaffAttendance {
  final int? id;
  final int userId;
  final int supervisorId;
  final int? schoolYearId;
  final DateTime attendanceDate;
  final DateTime scannedAt;
  final String scannedQrCode;
  final bool isPresent;
  final String eventType; // 'entry', 'exit', 'auto'
  final String staffType;
  final int lateMinutes;
  final double? workHours;
  final int? earlyDepartureMinutes;
  final String? notes;

  StaffAttendance({
    this.id,
    required this.userId,
    required this.supervisorId,
    this.schoolYearId,
    required this.attendanceDate,
    required this.scannedAt,
    required this.scannedQrCode,
    required this.isPresent,
    required this.eventType,
    required this.staffType,
    this.lateMinutes = 0,
    this.workHours,
    this.earlyDepartureMinutes,
    this.notes,
  });

  factory StaffAttendance.fromJson(Map<String, dynamic> json) {
    return StaffAttendance(
      id: json['id'],
      userId: json['user_id'],
      supervisorId: json['supervisor_id'],
      schoolYearId: json['school_year_id'],
      attendanceDate: DateTime.parse(json['attendance_date']),
      scannedAt: DateTime.parse(json['scanned_at']),
      scannedQrCode: json['scanned_qr_code'],
      isPresent: json['is_present'] == 1 || json['is_present'] == true,
      eventType: json['event_type'],
      staffType: json['staff_type'],
      lateMinutes: json['late_minutes'] ?? 0,
      workHours: json['work_hours']?.toDouble(),
      earlyDepartureMinutes: json['early_departure_minutes'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'supervisor_id': supervisorId,
      'school_year_id': schoolYearId,
      'attendance_date': attendanceDate.toIso8601String().split('T')[0],
      'scanned_at': scannedAt.toIso8601String(),
      'scanned_qr_code': scannedQrCode,
      'is_present': isPresent,
      'event_type': eventType,
      'staff_type': staffType,
      'late_minutes': lateMinutes,
      'work_hours': workHours,
      'early_departure_minutes': earlyDepartureMinutes,
      'notes': notes,
    };
  }
}