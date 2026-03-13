import 'dart:convert';
import 'package:flutter/material.dart';

/// 补剂分类
enum SupplementCategory {
  vitamin,      // 维生素
  mineral,      // 矿物质
  protein,      // 蛋白质
  aminoAcid,    // 氨基酸
  herb,         // 草本/植物
  probiotic,    // 益生菌
  omega,        // 鱼油/Omega
  joint,        // 关节保健
  preworkout,   // 运动前补剂
  other,        // 其他
}

extension SupplementCategoryExtension on SupplementCategory {
  String get label {
    switch (this) {
      case SupplementCategory.vitamin:
        return '维生素';
      case SupplementCategory.mineral:
        return '矿物质';
      case SupplementCategory.protein:
        return '蛋白质';
      case SupplementCategory.aminoAcid:
        return '氨基酸';
      case SupplementCategory.herb:
        return '草本';
      case SupplementCategory.probiotic:
        return '益生菌';
      case SupplementCategory.omega:
        return '鱼油';
      case SupplementCategory.joint:
        return '关节';
      case SupplementCategory.preworkout:
        return '运动';
      case SupplementCategory.other:
        return '其他';
    }
  }

  Color get color {
    switch (this) {
      case SupplementCategory.vitamin:
        return const Color(0xFFFF9500); // 橙色
      case SupplementCategory.mineral:
        return const Color(0xFF007AFF); // 蓝色
      case SupplementCategory.protein:
        return const Color(0xFF34C759); // 绿色
      case SupplementCategory.aminoAcid:
        return const Color(0xFF5856D6); // 紫色
      case SupplementCategory.herb:
        return const Color(0xFF30B0C7); // 青色
      case SupplementCategory.probiotic:
        return const Color(0xFFFF2D55); // 粉色
      case SupplementCategory.omega:
        return const Color(0xFFFF3B30); // 红色
      case SupplementCategory.joint:
        return const Color(0xFFFFCC00); // 黄色
      case SupplementCategory.preworkout:
        return const Color(0xFFAF52DE); // 深紫
      case SupplementCategory.other:
        return const Color(0xFF8E8E93); // 灰色
    }
  }
}

/// 补剂模型
class Supplement {
  final int? id;
  final String name;
  final String dosage;
  final String form;
  final String frequency;
  final List<String> timing;
  final int maxDaily;
  final int? stock;
  final String? notes;
  final DateTime createdAt;
  final bool isActive;
  final SupplementCategory category;

  Supplement({
    this.id,
    required this.name,
    required this.dosage,
    required this.form,
    required this.frequency,
    required this.timing,
    required this.maxDaily,
    this.stock,
    this.notes,
    DateTime? createdAt,
    this.isActive = true,
    this.category = SupplementCategory.other,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'form': form,
      'frequency': frequency,
      'timing': jsonEncode(timing),
      'maxDaily': maxDaily,
      'stock': stock,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'category': category.index,
    };
  }

  factory Supplement.fromMap(Map<String, dynamic> map) {
    return Supplement(
      id: map['id'] as int?,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      form: map['form'] as String,
      frequency: map['frequency'] as String,
      timing: List<String>.from(jsonDecode(map['timing'] as String)),
      maxDaily: map['maxDaily'] as int,
      stock: map['stock'] as int?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isActive: map['isActive'] == 1,
      category: map['category'] != null 
          ? SupplementCategory.values[map['category'] as int] 
          : SupplementCategory.other,
    );
  }

  Supplement copyWith({
    int? id,
    String? name,
    String? dosage,
    String? form,
    String? frequency,
    List<String>? timing,
    int? maxDaily,
    int? stock,
    String? notes,
    DateTime? createdAt,
    bool? isActive,
    SupplementCategory? category,
  }) {
    return Supplement(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      timing: timing ?? this.timing,
      maxDaily: maxDaily ?? this.maxDaily,
      stock: stock ?? this.stock,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'Supplement(id: $id, name: $name, dosage: $dosage)';
  }
}

/// 摄入记录模型
class IntakeLog {
  final int? id;
  final int supplementId;
  final DateTime date;
  final DateTime time;
  final int quantity;
  final IntakeStatus status;
  final String? notes;

  IntakeLog({
    this.id,
    required this.supplementId,
    required this.date,
    required this.time,
    required this.quantity,
    this.status = IntakeStatus.taken,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplementId': supplementId,
      'date': date.toIso8601String().split('T')[0],
      'time': time.toIso8601String(),
      'quantity': quantity,
      'status': status.index,
      'notes': notes,
    };
  }

  factory IntakeLog.fromMap(Map<String, dynamic> map) {
    return IntakeLog(
      id: map['id'] as int?,
      supplementId: map['supplementId'] as int,
      date: DateTime.parse(map['date'] as String),
      time: DateTime.parse(map['time'] as String),
      quantity: map['quantity'] as int,
      status: IntakeStatus.values[map['status'] as int],
      notes: map['notes'] as String?,
    );
  }

  IntakeLog copyWith({
    int? id,
    int? supplementId,
    DateTime? date,
    DateTime? time,
    int? quantity,
    IntakeStatus? status,
    String? notes,
  }) {
    return IntakeLog(
      id: id ?? this.id,
      supplementId: supplementId ?? this.supplementId,
      date: date ?? this.date,
      time: time ?? this.time,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

/// 服用状态
enum IntakeStatus {
  taken,    // 已服用
  missed,   // 漏服
  skipped,  // 跳过
}

/// 提醒设置模型
class Reminder {
  final int? id;
  final int supplementId;
  final String time;  // HH:mm 格式
  final bool isEnabled;
  final String? sound;

  Reminder({
    this.id,
    required this.supplementId,
    required this.time,
    this.isEnabled = true,
    this.sound,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplementId': supplementId,
      'time': time,
      'isEnabled': isEnabled ? 1 : 0,
      'sound': sound,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      supplementId: map['supplementId'] as int,
      time: map['time'] as String,
      isEnabled: map['isEnabled'] == 1,
      sound: map['sound'] as String?,
    );
  }
}
