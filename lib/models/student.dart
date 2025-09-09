class Student {
  final int id;
  final String studentNumber;
  final String firstName;
  final String lastName;
  final String? name; // Champ legacy pour compatibilité
  final String? subname; // Champ legacy pour compatibilité
  final DateTime? dateOfBirth;
  final String? placeOfBirth;
  final String gender; // 'M' ou 'F'
  final String? parentName;
  final String? parentPhone;
  final String? parentEmail;
  final String? motherName;
  final String? motherPhone;
  final String? address;
  final int classSeriesId;
  final int schoolYearId;
  final int order;
  final bool isActive;
  final String? photo;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Relations
  final ClassSeries? classSeries;
  final SchoolYear? schoolYear;

  Student({
    required this.id,
    required this.studentNumber,
    required this.firstName,
    required this.lastName,
    this.name,
    this.subname,
    this.dateOfBirth,
    this.placeOfBirth,
    required this.gender,
    this.parentName,
    this.parentPhone,
    this.parentEmail,
    this.motherName,
    this.motherPhone,
    this.address,
    required this.classSeriesId,
    required this.schoolYearId,
    required this.order,
    this.isActive = true,
    this.photo,
    this.createdAt,
    this.updatedAt,
    this.classSeries,
    this.schoolYear,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      studentNumber: json['student_number'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      name: json['name'],
      subname: json['subname'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth'])
          : null,
      placeOfBirth: json['place_of_birth'],
      gender: json['gender'] ?? 'M',
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      parentEmail: json['parent_email'],
      motherName: json['mother_name'],
      motherPhone: json['mother_phone'],
      address: json['address'],
      classSeriesId: json['class_series_id'],
      schoolYearId: json['school_year_id'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      photo: json['photo'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
      classSeries: json['class_series'] != null 
          ? ClassSeries.fromJson(json['class_series'])
          : null,
      schoolYear: json['school_year'] != null 
          ? SchoolYear.fromJson(json['school_year'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_number': studentNumber,
      'first_name': firstName,
      'last_name': lastName,
      'name': name,
      'subname': subname,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'place_of_birth': placeOfBirth,
      'gender': gender,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'parent_email': parentEmail,
      'mother_name': motherName,
      'mother_phone': motherPhone,
      'address': address,
      'class_series_id': classSeriesId,
      'school_year_id': schoolYearId,
      'order': order,
      'is_active': isActive,
      'photo': photo,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'class_series': classSeries?.toJson(),
      'school_year': schoolYear?.toJson(),
    };
  }

  String get fullName => '$lastName $firstName';
  String get displayName => name ?? fullName;
  String get displaySubname => subname ?? firstName;
  
  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month || 
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String get genderDisplay => gender == 'M' ? 'Masculin' : 'Féminin';
  
  Student copyWith({
    int? id,
    String? studentNumber,
    String? firstName,
    String? lastName,
    String? name,
    String? subname,
    DateTime? dateOfBirth,
    String? placeOfBirth,
    String? gender,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    String? motherName,
    String? motherPhone,
    String? address,
    int? classSeriesId,
    int? schoolYearId,
    int? order,
    bool? isActive,
    String? photo,
    DateTime? createdAt,
    DateTime? updatedAt,
    ClassSeries? classSeries,
    SchoolYear? schoolYear,
  }) {
    return Student(
      id: id ?? this.id,
      studentNumber: studentNumber ?? this.studentNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      name: name ?? this.name,
      subname: subname ?? this.subname,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      placeOfBirth: placeOfBirth ?? this.placeOfBirth,
      gender: gender ?? this.gender,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      motherName: motherName ?? this.motherName,
      motherPhone: motherPhone ?? this.motherPhone,
      address: address ?? this.address,
      classSeriesId: classSeriesId ?? this.classSeriesId,
      schoolYearId: schoolYearId ?? this.schoolYearId,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      classSeries: classSeries ?? this.classSeries,
      schoolYear: schoolYear ?? this.schoolYear,
    );
  }

  @override
  String toString() {
    return 'Student{id: $id, studentNumber: $studentNumber, fullName: $fullName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ClassSeries {
  final int id;
  final String name;
  final String? description;
  final int classId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Relations
  final SchoolClass? schoolClass;

  ClassSeries({
    required this.id,
    required this.name,
    this.description,
    required this.classId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.schoolClass,
  });

  factory ClassSeries.fromJson(Map<String, dynamic> json) {
    return ClassSeries(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      classId: json['class_id'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
      schoolClass: json['school_class'] != null 
          ? SchoolClass.fromJson(json['school_class'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'class_id': classId,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'school_class': schoolClass?.toJson(),
    };
  }
}

class SchoolClass {
  final int id;
  final String name;
  final String? description;
  final int levelId;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Relations
  final Level? level;

  SchoolClass({
    required this.id,
    required this.name,
    this.description,
    required this.levelId,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.level,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      levelId: json['level_id'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
      level: json['level'] != null 
          ? Level.fromJson(json['level'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'level_id': levelId,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'level': level?.toJson(),
    };
  }
}

class Level {
  final int id;
  final String name;
  final String? abbreviation;
  final String? description;
  final int sectionId;
  final int order;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Relations
  final Section? section;

  Level({
    required this.id,
    required this.name,
    this.abbreviation,
    this.description,
    required this.sectionId,
    required this.order,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.section,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      name: json['name'] ?? '',
      abbreviation: json['abbreviation'],
      description: json['description'],
      sectionId: json['section_id'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
      section: json['section'] != null 
          ? Section.fromJson(json['section'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'description': description,
      'section_id': sectionId,
      'order': order,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'section': section?.toJson(),
    };
  }
}

class Section {
  final int id;
  final String name;
  final String? description;
  final String? color;
  final String? icon;
  final int order;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Section({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.icon,
    required this.order,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      color: json['color'],
      icon: json['icon'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'color': color,
      'icon': icon,
      'order': order,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class SchoolYear {
  final int id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final bool isCurrent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SchoolYear({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.isCurrent = false,
    this.createdAt,
    this.updatedAt,
  });

  factory SchoolYear.fromJson(Map<String, dynamic> json) {
    return SchoolYear(
      id: json['id'],
      name: json['name'] ?? '',
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isActive: json['is_active'] ?? true,
      isCurrent: json['is_current'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'is_current': isCurrent,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class StudentAttendance {
  final int? id;
  final int studentId;
  final int schoolYearId;
  final DateTime attendanceDate;
  final String eventType; // 'entry' ou 'exit'
  final bool isPresent;
  final DateTime scannedAt;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Relations
  final Student? student;

  StudentAttendance({
    this.id,
    required this.studentId,
    required this.schoolYearId,
    required this.attendanceDate,
    required this.eventType,
    required this.isPresent,
    required this.scannedAt,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.student,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      id: json['id'],
      studentId: json['student_id'],
      schoolYearId: json['school_year_id'],
      attendanceDate: DateTime.parse(json['attendance_date']),
      eventType: json['event_type'] ?? 'entry',
      isPresent: json['is_present'] ?? false,
      scannedAt: DateTime.parse(json['scanned_at']),
      notes: json['notes'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'])
          : null,
      student: json['student'] != null 
          ? Student.fromJson(json['student'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'school_year_id': schoolYearId,
      'attendance_date': attendanceDate.toIso8601String().split('T')[0],
      'event_type': eventType,
      'is_present': isPresent,
      'scanned_at': scannedAt.toIso8601String(),
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'student': student?.toJson(),
    };
  }
}
