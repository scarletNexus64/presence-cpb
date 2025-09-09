class StaffMember {
  final int id;
  final String name;
  final String role;
  final String staffType;
  final String? qrCode;

  StaffMember({
    required this.id,
    required this.name,
    required this.role,
    required this.staffType,
    this.qrCode,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'],
      name: json['name'],
      role: json['role'] ?? '',
      staffType: json['staff_type'] ?? 'teacher',
      qrCode: json['qr_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'staff_type': staffType,
      'qr_code': qrCode,
    };
  }
}