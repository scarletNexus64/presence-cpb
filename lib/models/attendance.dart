class Attendance {
  final int? id;
  final String employeeId;
  final DateTime date;
  final DateTime? arrivalTime;
  final DateTime? departureTime;

  Attendance({
    this.id,
    required this.employeeId,
    required this.date,
    this.arrivalTime,
    this.departureTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employee_id': employeeId,
      'date': date.toIso8601String(),
      'arrival_time': arrivalTime?.toIso8601String(),
      'departure_time': departureTime?.toIso8601String(),
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: map['id'],
      employeeId: map['employee_id'],
      date: DateTime.parse(map['date']),
      arrivalTime: map['arrival_time'] != null 
          ? DateTime.parse(map['arrival_time'])
          : null,
      departureTime: map['departure_time'] != null 
          ? DateTime.parse(map['departure_time'])
          : null,
    );
  }
}