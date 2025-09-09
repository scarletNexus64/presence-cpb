class Employee {
  final String id;
  final String name;
  final String qrCode;
  final DateTime? arrivalTime;
  final DateTime? departureTime;

  Employee({
    required this.id,
    required this.name,
    required this.qrCode,
    this.arrivalTime,
    this.departureTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'qr_code': qrCode,
      'arrival_time': arrivalTime?.toIso8601String(),
      'departure_time': departureTime?.toIso8601String(),
    };
  }

  factory Employee.fromMap(Map<String, dynamic> map) {
    return Employee(
      id: map['id'],
      name: map['name'],
      qrCode: map['qr_code'],
      arrivalTime: map['arrival_time'] != null 
          ? DateTime.parse(map['arrival_time'])
          : null,
      departureTime: map['departure_time'] != null 
          ? DateTime.parse(map['departure_time'])
          : null,
    );
  }
}