import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/employee.dart';
import '../models/attendance.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'presence_cpb.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        qr_code TEXT UNIQUE NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT NOT NULL,
        date TEXT NOT NULL,
        arrival_time TEXT,
        departure_time TEXT,
        FOREIGN KEY (employee_id) REFERENCES employees (id)
      )
    ''');

    await _insertSampleEmployees(db);
  }

  Future<void> _insertSampleEmployees(Database db) async {
    final sampleEmployees = [
      {'id': '1', 'name': 'Jean Dupont', 'qr_code': 'EMP001'},
      {'id': '2', 'name': 'Marie Martin', 'qr_code': 'EMP002'},
      {'id': '3', 'name': 'Pierre Durand', 'qr_code': 'EMP003'},
    ];

    for (final employee in sampleEmployees) {
      await db.insert('employees', employee);
    }
  }

  Future<Employee?> getEmployeeByQrCode(String qrCode) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'qr_code = ?',
      whereArgs: [qrCode],
    );

    if (maps.isEmpty) return null;
    return Employee.fromMap(maps.first);
  }

  Future<Attendance?> getTodayAttendance(String employeeId) async {
    final db = await database;
    final today = DateTime.now();
    final todayStr = DateTime(today.year, today.month, today.day).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'employee_id = ? AND date = ?',
      whereArgs: [employeeId, todayStr],
    );

    if (maps.isEmpty) return null;
    return Attendance.fromMap(maps.first);
  }

  Future<int> insertOrUpdateAttendance(Attendance attendance) async {
    final db = await database;
    
    final existing = await getTodayAttendance(attendance.employeeId);
    
    if (existing != null) {
      return await db.update(
        'attendance',
        attendance.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    } else {
      return await db.insert('attendance', attendance.toMap());
    }
  }
}