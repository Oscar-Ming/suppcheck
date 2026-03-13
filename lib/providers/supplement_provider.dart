import 'package:flutter/foundation.dart';
import '../models/supplement.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// 补剂状态管理
class SupplementProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService.instance;
  final NotificationService _notifications = NotificationService.instance;

  List<Supplement> _supplements = [];
  Map<int, List<IntakeLog>> _todayLogs = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Supplement> get supplements => _supplements;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 获取今日记录
  List<IntakeLog> getTodayLogs(int supplementId) {
    return _todayLogs[supplementId] ?? [];
  }

  /// 计算今日某补剂已服用数量
  int getTodayTakenCount(int supplementId) {
    final logs = _todayLogs[supplementId] ?? [];
    return logs
        .where((log) => log.status == IntakeStatus.taken)
        .fold(0, (sum, log) => sum + log.quantity);
  }

  /// 检查今日是否还能服用
  ({bool canTake, String? message}) canTakeSupplement(Supplement supplement) {
    final takenCount = getTodayTakenCount(supplement.id!);
    
    if (takenCount >= supplement.maxDaily) {
      return (
        canTake: false,
        message: '今日已达到最大服用量 (${supplement.maxDaily})',
      );
    }

    // 检查2小时内是否服用过
    final logs = _todayLogs[supplement.id!] ?? [];
    if (logs.isNotEmpty) {
      final lastLog = logs.reduce((a, b) => a.time.isAfter(b.time) ? a : b);
      final diff = DateTime.now().difference(lastLog.time);
      if (diff.inHours < 2) {
        return (
          canTake: false,
          message: '距离上次服用仅 ${diff.inMinutes} 分钟，建议间隔2小时',
        );
      }
    }

    return (canTake: true, message: null);
  }

  /// 加载所有补剂
  Future<void> loadSupplements() async {
    _setLoading(true);
    try {
      _supplements = await _db.getAllSupplements();
      await _loadTodayLogs();
      _error = null;
    } catch (e) {
      _error = '加载补剂失败: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// 加载今日记录
  Future<void> _loadTodayLogs() async {
    _todayLogs = {};
    for (final supplement in _supplements) {
      final logs = await _db.getIntakeLogsByDateAndSupplement(
        _selectedDate,
        supplement.id!,
      );
      _todayLogs[supplement.id!] = logs;
    }
  }

  /// 添加补剂
  Future<void> addSupplement(Supplement supplement) async {
    _setLoading(true);
    try {
      final id = await _db.createSupplement(supplement);
      
      // 为每个服用时间创建提醒
      for (final time in supplement.timing) {
        final reminder = Reminder(
          supplementId: id,
          time: _parseTime(time),
        );
        await _db.createReminder(reminder);
        
        // 设置本地通知
        await _notifications.scheduleDailyReminder(
          id: id * 100 + supplement.timing.indexOf(time),
          title: '服用提醒',
          body: '该服用 ${supplement.name} 了',
          time: reminder.time,
          payload: 'supplement_$id',
        );
      }
      
      await loadSupplements();
    } catch (e) {
      _error = '添加补剂失败: $e';
      _setLoading(false);
    }
  }

  /// 更新补剂
  Future<void> updateSupplement(Supplement supplement) async {
    _setLoading(true);
    try {
      await _db.updateSupplement(supplement);
      
      // 更新提醒
      await _updateReminders(supplement);
      
      await loadSupplements();
    } catch (e) {
      _error = '更新补剂失败: $e';
      _setLoading(false);
    }
  }

  /// 删除补剂
  Future<void> deleteSupplement(int id) async {
    _setLoading(true);
    try {
      await _db.deleteSupplement(id);
      
      // 取消相关提醒
      await _notifications.cancelReminder(id * 100);
      await _notifications.cancelReminder(id * 100 + 1);
      
      await loadSupplements();
    } catch (e) {
      _error = '删除补剂失败: $e';
      _setLoading(false);
    }
  }

  /// 记录服用
  Future<IntakeLog> recordIntake(
    Supplement supplement,
    int quantity, {
    String? notes,
  }) async {
    final validation = canTakeSupplement(supplement);
    if (!validation.canTake) {
      throw Exception(validation.message);
    }

    final log = IntakeLog(
      supplementId: supplement.id!,
      date: _selectedDate,
      time: DateTime.now(),
      quantity: quantity,
      status: IntakeStatus.taken,
      notes: notes,
    );

    final id = await _db.addIntakeLog(log);
    final logWithId = IntakeLog(
      id: id,
      supplementId: log.supplementId,
      date: log.date,
      time: log.time,
      quantity: log.quantity,
      status: log.status,
      notes: log.notes,
    );
    
    // 更新库存
    if (supplement.stock != null) {
      final newStock = supplement.stock! - quantity;
      await _db.updateSupplement(
        supplement.copyWith(stock: newStock < 0 ? 0 : newStock),
      );
    }

    await _loadTodayLogs();
    notifyListeners();
    return logWithId;
  }

  /// 撤销服用记录
  Future<void> undoIntake(Supplement supplement, IntakeLog log) async {
    if (log.id != null) {
      await _db.deleteIntakeLog(log.id!);
      
      // 恢复库存
      if (supplement.stock != null) {
        final newStock = supplement.stock! + log.quantity;
        await _db.updateSupplement(
          supplement.copyWith(stock: newStock),
        );
      }
      
      await _loadTodayLogs();
      notifyListeners();
    }
  }

  /// 获取今日所有记录（按时间排序）
  List<IntakeLog> getTodayAllLogs() {
    final List<IntakeLog> allLogs = [];
    _todayLogs.forEach((supplementId, logs) {
      allLogs.addAll(logs);
    });
    allLogs.sort((a, b) => b.time.compareTo(a.time));
    return allLogs;
  }

  /// 获取连续打卡天数
  Future<int> getConsecutiveDays() async {
    final logs = await _db.getAllIntakeLogs();
    if (logs.isEmpty) return 0;

    // 按日期分组，检查每天是否有服用记录
    final Set<String> datesWithRecords = {};
    for (final log in logs) {
      if (log.status == IntakeStatus.taken) {
        datesWithRecords.add(log.date.toIso8601String().split('T')[0]);
      }
    }

    if (datesWithRecords.isEmpty) return 0;

    // 从昨天开始往前数
    int consecutiveDays = 0;
    final today = DateTime.now();
    final todayStr = today.toIso8601String().split('T')[0];
    
    // 如果今天有记录，包含今天
    DateTime checkDate = datesWithRecords.contains(todayStr) ? today : today.subtract(const Duration(days: 1));
    
    while (true) {
      final dateStr = checkDate.toIso8601String().split('T')[0];
      if (datesWithRecords.contains(dateStr)) {
        consecutiveDays++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return consecutiveDays;
  }

  /// 标记漏服
  Future<void> recordMissed(Supplement supplement) async {
    final log = IntakeLog(
      supplementId: supplement.id!,
      date: _selectedDate,
      time: DateTime.now(),
      quantity: 0,
      status: IntakeStatus.missed,
    );

    await _db.addIntakeLog(log);
    await _loadTodayLogs();
    notifyListeners();
  }

  /// 切换日期
  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await _loadLogsForDate(date);
    notifyListeners();
  }

  /// 加载指定日期的记录
  Future<void> _loadLogsForDate(DateTime date) async {
    _todayLogs = {};
    for (final supplement in _supplements) {
      final logs = await _db.getIntakeLogsByDateAndSupplement(
        date,
        supplement.id!,
      );
      _todayLogs[supplement.id!] = logs;
    }
  }

  /// 获取指定日期的记录
  List<IntakeLog> getLogsForDate(DateTime date) {
    if (isSameDay(date, _selectedDate)) {
      final List<IntakeLog> allLogs = [];
      _todayLogs.forEach((supplementId, logs) {
        allLogs.addAll(logs);
      });
      return allLogs;
    }
    return [];
  }

  /// 获取指定日期某补剂的服用数量
  int getTakenCountForDate(int supplementId, DateTime date) {
    if (isSameDay(date, _selectedDate)) {
      return getTodayTakenCount(supplementId);
    }
    return 0;
  }

  /// 更新提醒设置
  Future<void> _updateReminders(Supplement supplement) async {
    // 取消旧提醒
    for (int i = 0; i < 5; i++) {
      await _notifications.cancelReminder(supplement.id! * 100 + i);
    }

    // 删除旧提醒数据
    final oldReminders = await _db.getRemindersBySupplement(supplement.id!);
    for (final r in oldReminders) {
      await _db.deleteReminder(r.id!);
    }

    // 创建新提醒
    for (final time in supplement.timing) {
      final reminder = Reminder(
        supplementId: supplement.id!,
        time: _parseTime(time),
      );
      await _db.createReminder(reminder);

      await _notifications.scheduleDailyReminder(
        id: supplement.id! * 100 + supplement.timing.indexOf(time),
        title: '服用提醒',
        body: '该服用 ${supplement.name} 了',
        time: reminder.time,
      );
    }
  }

  /// 解析时间字符串为 HH:mm
  String _parseTime(String timeStr) {
    // 处理 "早餐后"、"晚上8点" 等描述性时间
    final timeMap = {
      '早上': '08:00',
      '早餐后': '08:30',
      '中午': '12:00',
      '午餐后': '12:30',
      '晚上': '20:00',
      '睡前': '21:30',
    };

    for (final entry in timeMap.entries) {
      if (timeStr.contains(entry.key)) {
        return entry.value;
      }
    }

    // 尝试匹配 HH:mm 格式
    final regex = RegExp(r'(\d{1,2}):(\d{2})');
    final match = regex.firstMatch(timeStr);
    if (match != null) {
      return '${match.group(1)!.padLeft(2, '0')}:${match.group(2)}';
    }

    return '08:00'; // 默认时间
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// 获取统计数据
  Future<Map<String, dynamic>> getStatistics(DateTime start, DateTime end) async {
    return await _db.getStatistics(start, end);
  }

  /// 获取某补剂的服用率
  Future<double> getSupplementAdherence(int supplementId) async {
    return await _db.getSupplementAdherenceRate(supplementId);
  }

  /// 导出所有数据
  Future<Map<String, dynamic>> exportData() async {
    return await _db.exportData();
  }

  /// 导入数据
  Future<void> importData(Map<String, dynamic> data, {bool merge = true}) async {
    await _db.importData(data, merge: merge);
    await loadSupplements();
  }

  /// 获取所有提醒设置
  Future<List<Map<String, dynamic>>> getAllReminders() async {
    final reminders = await _db.getAllEnabledReminders();
    final List<Map<String, dynamic>> result = [];
    
    for (final reminder in reminders) {
      final supplement = await _db.getSupplement(reminder.supplementId);
      if (supplement != null) {
        result.add({
          'reminder': reminder,
          'supplement': supplement,
        });
      }
    }
    
    return result;
  }

  /// 切换提醒开关
  Future<void> toggleReminder(int reminderId, bool isEnabled) async {
    // 这里需要添加更新提醒的方法到数据库服务
    await loadSupplements();
  }
}
