import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/supplement.dart';

/// 数据库服务 - 单例模式
/// Web 平台使用内存存储，移动端使用 SQLite
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  static Database? _database;
  
  // Web 平台内存存储
  final List<Map<String, dynamic>> _supplementsMemory = [];
  final List<Map<String, dynamic>> _intakeLogsMemory = [];
  final List<Map<String, dynamic>> _remindersMemory = [];
  int _nextId = 1;

  DatabaseService._internal();

  bool get _isWeb => kIsWeb;

  Future<Database> get database async {
    if (_isWeb) throw UnsupportedError('Web 平台不使用 SQLite');
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    if (_isWeb) {
      // Web 平台：初始化内存数据
      return;
    }
    await database;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'suppcheck.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建补剂表
    await db.execute('''
      CREATE TABLE supplements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        form TEXT NOT NULL,
        frequency TEXT NOT NULL,
        timing TEXT NOT NULL,
        maxDaily INTEGER NOT NULL,
        stock INTEGER,
        notes TEXT,
        createdAt TEXT NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1,
        category INTEGER DEFAULT 9
      )
    ''');

    // 创建摄入记录表
    await db.execute('''
      CREATE TABLE intake_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplementId INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (supplementId) REFERENCES supplements (id) ON DELETE CASCADE
      )
    ''');

    // 创建提醒表
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        supplementId INTEGER NOT NULL,
        time TEXT NOT NULL,
        isEnabled INTEGER NOT NULL DEFAULT 1,
        sound TEXT,
        FOREIGN KEY (supplementId) REFERENCES supplements (id) ON DELETE CASCADE
      )
    ''');

    // 创建索引优化查询
    await db.execute(
      'CREATE INDEX idx_intake_logs_date ON intake_logs(date)',
    );
    await db.execute(
      'CREATE INDEX idx_intake_logs_supplement ON intake_logs(supplementId)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 添加 category 字段
      await db.execute('ALTER TABLE supplements ADD COLUMN category INTEGER DEFAULT 9');
    }
  }

  // ==================== Web 平台内存存储辅助方法 ====================
  
  int _generateId() {
    return _nextId++;
  }

  // ==================== 补剂 CRUD ====================

  /// 创建补剂
  Future<int> createSupplement(Supplement supplement) async {
    if (_isWeb) {
      final id = _generateId();
      final map = supplement.toMap();
      map['id'] = id;
      _supplementsMemory.add(map);
      return id;
    }
    
    final db = await database;
    return await db.insert('supplements', supplement.toMap());
  }

  /// 获取所有补剂
  Future<List<Supplement>> getAllSupplements() async {
    if (_isWeb) {
      return _supplementsMemory
          .where((m) => m['isActive'] == 1)
          .map((m) => Supplement.fromMap(m))
          .toList();
    }
    
    final db = await database;
    final maps = await db.query(
      'supplements',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => Supplement.fromMap(m)).toList();
  }

  /// 获取单个补剂
  Future<Supplement?> getSupplement(int id) async {
    if (_isWeb) {
      final map = _supplementsMemory.firstWhere(
        (m) => m['id'] == id,
        orElse: () => {},
      );
      return map.isEmpty ? null : Supplement.fromMap(map);
    }
    
    final db = await database;
    final maps = await db.query(
      'supplements',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Supplement.fromMap(maps.first);
  }

  /// 更新补剂
  Future<int> updateSupplement(Supplement supplement) async {
    if (_isWeb) {
      final index = _supplementsMemory.indexWhere((m) => m['id'] == supplement.id);
      if (index >= 0) {
        _supplementsMemory[index] = supplement.toMap();
        return 1;
      }
      return 0;
    }
    
    final db = await database;
    return await db.update(
      'supplements',
      supplement.toMap(),
      where: 'id = ?',
      whereArgs: [supplement.id],
    );
  }

  /// 删除补剂（软删除）
  Future<int> deleteSupplement(int id) async {
    if (_isWeb) {
      final index = _supplementsMemory.indexWhere((m) => m['id'] == id);
      if (index >= 0) {
        _supplementsMemory[index]['isActive'] = 0;
        return 1;
      }
      return 0;
    }
    
    final db = await database;
    return await db.update(
      'supplements',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 彻底删除补剂
  Future<int> hardDeleteSupplement(int id) async {
    if (_isWeb) {
      _supplementsMemory.removeWhere((m) => m['id'] == id);
      return 1;
    }
    
    final db = await database;
    return await db.delete(
      'supplements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 摄入记录 CRUD ====================

  /// 添加摄入记录
  Future<int> addIntakeLog(IntakeLog log) async {
    if (_isWeb) {
      final id = _generateId();
      final map = log.toMap();
      map['id'] = id;
      _intakeLogsMemory.add(map);
      return id;
    }
    
    final db = await database;
    return await db.insert('intake_logs', log.toMap());
  }

  /// 获取某日所有记录
  Future<List<IntakeLog>> getIntakeLogsByDate(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    
    if (_isWeb) {
      return _intakeLogsMemory
          .where((m) => m['date'] == dateStr)
          .map((m) => IntakeLog.fromMap(m))
          .toList();
    }
    
    final db = await database;
    final maps = await db.query(
      'intake_logs',
      where: 'date = ?',
      whereArgs: [dateStr],
      orderBy: 'time DESC',
    );
    return maps.map((m) => IntakeLog.fromMap(m)).toList();
  }

  /// 获取某日某补剂的记录
  Future<List<IntakeLog>> getIntakeLogsByDateAndSupplement(
    DateTime date,
    int supplementId,
  ) async {
    final dateStr = date.toIso8601String().split('T')[0];
    
    if (_isWeb) {
      return _intakeLogsMemory
          .where((m) => m['date'] == dateStr && m['supplementId'] == supplementId)
          .map((m) => IntakeLog.fromMap(m))
          .toList();
    }
    
    final db = await database;
    final maps = await db.query(
      'intake_logs',
      where: 'date = ? AND supplementId = ?',
      whereArgs: [dateStr, supplementId],
    );
    return maps.map((m) => IntakeLog.fromMap(m)).toList();
  }

  /// 获取某补剂某日已服用数量
  Future<int> getTodayTakenCount(int supplementId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    
    if (_isWeb) {
      final logs = _intakeLogsMemory.where((m) => 
        m['supplementId'] == supplementId && 
        m['date'] == dateStr && 
        m['status'] == 0);
      var total = 0;
      for (final log in logs) {
        total += (log['quantity'] as int? ?? 0);
      }
      return total;
    }
    
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(quantity) as total 
      FROM intake_logs 
      WHERE supplementId = ? AND date = ? AND status = 0
    ''', [supplementId, dateStr]);
    return result.first['total'] as int? ?? 0;
  }

  /// 删除某条记录
  Future<int> deleteIntakeLog(int id) async {
    if (_isWeb) {
      _intakeLogsMemory.removeWhere((m) => m['id'] == id);
      return 1;
    }
    
    final db = await database;
    return await db.delete(
      'intake_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 获取所有摄入记录
  Future<List<IntakeLog>> getAllIntakeLogs() async {
    if (_isWeb) {
      return _intakeLogsMemory.map((m) => IntakeLog.fromMap(m)).toList();
    }
    
    final db = await database;
    final maps = await db.query(
      'intake_logs',
      orderBy: 'date DESC, time DESC',
    );
    return maps.map((m) => IntakeLog.fromMap(m)).toList();
  }

  // ==================== 统计查询 ====================

  /// 获取日期范围的服用统计
  Future<Map<String, dynamic>> getStatistics(
    DateTime start,
    DateTime end,
  ) async {
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];
    
    if (_isWeb) {
      final filtered = _intakeLogsMemory.where((m) {
        final date = m['date'] as String;
        return date.compareTo(startStr) >= 0 && date.compareTo(endStr) <= 0;
      });
      
      final totalRecords = filtered.length;
      final takenCount = filtered.where((m) => m['status'] == 0).length;
      final missedCount = filtered.where((m) => m['status'] == 1).length;
      
      return {
        'totalRecords': totalRecords,
        'takenCount': takenCount,
        'missedCount': missedCount,
      };
    }
    
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalRecords,
        SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) as takenCount,
        SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as missedCount
      FROM intake_logs 
      WHERE date BETWEEN ? AND ?
    ''', [startStr, endStr]);

    return result.first;
  }

  /// 获取某补剂的服用率（过去30天）
  Future<double> getSupplementAdherenceRate(int supplementId) async {
    if (_isWeb) {
      // Web 简化计算
      final logs = _intakeLogsMemory.where((m) => 
        m['supplementId'] == supplementId && m['status'] == 0);
      return logs.isEmpty ? 0.0 : 0.85; // 模拟数据
    }
    
    final db = await database;
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    final startStr = start.toIso8601String().split('T')[0];
    final endStr = end.toIso8601String().split('T')[0];

    final result = await db.rawQuery('''
      SELECT 
        COUNT(DISTINCT date) as daysWithRecords
      FROM intake_logs 
      WHERE supplementId = ? AND date BETWEEN ? AND ? AND status = 0
    ''', [supplementId, startStr, endStr]);

    final daysWithRecords = result.first['daysWithRecords'] as int? ?? 0;
    return daysWithRecords / 30.0;
  }

  // ==================== 提醒 CRUD ====================

  /// 创建提醒
  Future<int> createReminder(Reminder reminder) async {
    if (_isWeb) {
      final id = _generateId();
      final map = reminder.toMap();
      map['id'] = id;
      _remindersMemory.add(map);
      return id;
    }
    
    final db = await database;
    return await db.insert('reminders', reminder.toMap());
  }

  /// 获取补剂的所有提醒
  Future<List<Reminder>> getRemindersBySupplement(int supplementId) async {
    if (_isWeb) {
      return _remindersMemory
          .where((m) => m['supplementId'] == supplementId)
          .map((m) => Reminder.fromMap(m))
          .toList();
    }
    
    final db = await database;
    final maps = await db.query(
      'reminders',
      where: 'supplementId = ?',
      whereArgs: [supplementId],
    );
    return maps.map((m) => Reminder.fromMap(m)).toList();
  }

  /// 获取所有启用的提醒
  Future<List<Reminder>> getAllEnabledReminders() async {
    if (_isWeb) {
      return _remindersMemory
          .where((m) => m['isEnabled'] == 1)
          .map((m) => Reminder.fromMap(m))
          .toList();
    }
    
    final db = await database;
    final maps = await db.query(
      'reminders',
      where: 'isEnabled = ?',
      whereArgs: [1],
    );
    return maps.map((m) => Reminder.fromMap(m)).toList();
  }

  /// 更新提醒
  Future<int> updateReminder(Reminder reminder) async {
    if (_isWeb) {
      final index = _remindersMemory.indexWhere((m) => m['id'] == reminder.id);
      if (index >= 0) {
        _remindersMemory[index] = reminder.toMap();
        return 1;
      }
      return 0;
    }
    
    final db = await database;
    return await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  /// 删除提醒
  Future<int> deleteReminder(int id) async {
    if (_isWeb) {
      _remindersMemory.removeWhere((m) => m['id'] == id);
      return 1;
    }
    
    final db = await database;
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== 数据备份/恢复 ====================

  /// 导出所有数据为 JSON
  Future<Map<String, dynamic>> exportData() async {
    if (_isWeb) {
      return {
        'version': 1,
        'exportTime': DateTime.now().toIso8601String(),
        'supplements': _supplementsMemory,
        'intakeLogs': _intakeLogsMemory,
        'reminders': _remindersMemory,
      };
    }
    
    final db = await database;
    
    final supplements = await db.query('supplements');
    final intakeLogs = await db.query('intake_logs');
    final reminders = await db.query('reminders');

    return {
      'version': 1,
      'exportTime': DateTime.now().toIso8601String(),
      'supplements': supplements,
      'intakeLogs': intakeLogs,
      'reminders': reminders,
    };
  }

  /// 从 JSON 导入数据（合并模式）
  Future<void> importData(Map<String, dynamic> data, {bool merge = true}) async {
    if (!merge) {
      // 清空现有数据
      if (_isWeb) {
        _supplementsMemory.clear();
        _intakeLogsMemory.clear();
        _remindersMemory.clear();
      } else {
        final db = await database;
        await db.delete('reminders');
        await db.delete('intake_logs');
        await db.delete('supplements');
      }
    }

    // 导入补剂
    final supplements = data['supplements'] as List<dynamic>?;
    if (supplements != null) {
      for (final map in supplements) {
        final supplement = Supplement.fromMap(Map<String, dynamic>.from(map));
        if (merge) {
          // 检查是否已存在同名补剂
          final existing = await _getSupplementByName(supplement.name);
          if (existing == null) {
            await createSupplement(supplement.copyWith(id: null));
          }
        } else {
          await createSupplement(supplement.copyWith(id: null));
        }
      }
    }

    // 导入摄入记录
    final intakeLogs = data['intakeLogs'] as List<dynamic>?;
    if (intakeLogs != null) {
      for (final map in intakeLogs) {
        final log = IntakeLog.fromMap(Map<String, dynamic>.from(map));
        await addIntakeLog(log.copyWith(id: null));
      }
    }
  }

  /// 根据名称获取补剂
  Future<Supplement?> _getSupplementByName(String name) async {
    if (_isWeb) {
      final map = _supplementsMemory.firstWhere(
        (m) => m['name'] == name && m['isActive'] == 1,
        orElse: () => {},
      );
      return map.isEmpty ? null : Supplement.fromMap(map);
    }
    
    final db = await database;
    final maps = await db.query(
      'supplements',
      where: 'name = ? AND isActive = ?',
      whereArgs: [name, 1],
    );
    if (maps.isEmpty) return null;
    return Supplement.fromMap(maps.first);
  }

  /// 关闭数据库
  Future<void> close() async {
    if (_isWeb) return;
    final db = await database;
    await db.close();
    _database = null;
  }
}
