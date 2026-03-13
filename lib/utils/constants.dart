import 'package:flutter/material.dart';
import '../models/supplement.dart';

/// 应用常量
class AppConstants {
  // 补剂分类选项
  static const List<Map<String, dynamic>> categories = [
    {'value': SupplementCategory.vitamin, 'label': '维生素', 'icon': 0xe5e1},
    {'value': SupplementCategory.mineral, 'label': '矿物质', 'icon': 0xe3e7},
    {'value': SupplementCategory.protein, 'label': '蛋白质', 'icon': 0xe5e4},
    {'value': SupplementCategory.aminoAcid, 'label': '氨基酸', 'icon': 0xe3f3},
    {'value': SupplementCategory.herb, 'label': '草本', 'icon': 0xe3e4},
    {'value': SupplementCategory.probiotic, 'label': '益生菌', 'icon': 0xe3f0},
    {'value': SupplementCategory.omega, 'label': '鱼油', 'icon': 0xe3ed},
    {'value': SupplementCategory.joint, 'label': '关节', 'icon': 0xe3e3},
    {'value': SupplementCategory.preworkout, 'label': '运动', 'icon': 0xe3f6},
    {'value': SupplementCategory.other, 'label': '其他', 'icon': 0xe5d3},
  ];
  // 剂型选项
  static const List<String> forms = [
    '胶囊',
    '片剂',
    '软胶囊',
    '粉剂',
    '液体',
    '咀嚼片',
    '滴剂',
  ];

  // 频率选项
  static const List<String> frequencies = [
    '每日1次',
    '每日2次',
    '每日3次',
    '每周1次',
    '每周2次',
    '每周3次',
    '隔日1次',
    '按需服用',
  ];

  // 服用时间选项
  static const List<String> timingOptions = [
    '早上',
    '早餐后',
    '午餐前',
    '午餐后',
    '晚餐前',
    '晚餐后',
    '睡前',
  ];

  // 默认最大服用量
  static const int defaultMaxDaily = 3;
}

/// ============================================================
/// 高级质感白底黑字配色方案
/// ============================================================
/// 
/// 设计理念：
/// - 以纯白色为基底，营造干净极简的视觉效果
/// - 使用不同层级的灰色来创建层次感和深度
/// - 通过微妙的阴影和边框来增强质感
/// - 点缀色仅用于关键交互和状态指示

class AppColors {
  // ========== 主色调 ==========
  /// 纯黑 - 用于主要文字
  static const Color black = Color(0xFF000000);
  
  /// 纯白 - 用于背景
  static const Color white = Color(0xFFFFFFFF);
  
  // ========== 灰度层级 ==========
  /// 最深灰 - 主要文字
  static const Color gray900 = Color(0xFF1A1A1A);
  
  /// 深灰 - 次要文字
  static const Color gray800 = Color(0xFF2D2D2D);
  
  /// 中深灰
  static const Color gray700 = Color(0xFF404040);
  
  /// 中灰
  static const Color gray600 = Color(0xFF525252);
  
  /// 中浅灰
  static const Color gray500 = Color(0xFF737373);
  
  /// 浅灰 - 辅助文字
  static const Color gray400 = Color(0xFF999999);
  
  /// 更浅灰
  static const Color gray300 = Color(0xFFB3B3B3);
  
  /// 超浅灰
  static const Color gray200 = Color(0xFFD9D9D9);
  
  /// 极浅灰 - 分隔线
  static const Color gray100 = Color(0xFFE6E6E6);
  
  /// 最浅灰 - 背景
  static const Color gray50 = Color(0xFFF5F5F5);
  
  /// 微灰 - 悬浮背景
  static const Color gray25 = Color(0xFFFAFAFA);
  
  // ========== 品牌/强调色 ==========
  /// 主强调色 - 纯黑（极简风格）
  static const Color primary = Color(0xFF000000);
  
  /// 次要强调色 - 深灰
  static const Color secondary = Color(0xFF333333);
  
  /// 成功色 - 柔和绿
  static const Color success = Color(0xFF22C55E);
  
  /// 警告色 - 琥珀色
  static const Color warning = Color(0xFFF59E0B);
  
  /// 危险色 - 柔和红
  static const Color danger = Color(0xFFEF4444);
  
  /// 信息色 - 柔和蓝
  static const Color info = Color(0xFF3B82F6);
  
  // ========== 背景色 ==========
  /// 页面背景 - 纯白
  static const Color background = Color(0xFFFFFFFF);
  
  /// 卡片背景 - 纯白
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  /// 悬浮背景 - 极浅灰
  static const Color hoverBackground = Color(0xFFF5F5F5);
  
  /// 选中背景
  static const Color selectedBackground = Color(0xFFEEEEEE);
  
  /// 按压背景
  static const Color pressedBackground = Color(0xFFE0E0E0);
  
  /// 输入框背景
  static const Color inputBackground = Color(0xFFF5F5F5);
  
  // ========== 文字色 ==========
  /// 主要文字
  static const Color textPrimary = Color(0xFF1A1A1A);
  
  /// 次要文字
  static const Color textSecondary = Color(0xFF737373);
  
  /// 辅助文字
  static const Color textTertiary = Color(0xFF999999);
  
  /// 禁用文字
  static const Color textDisabled = Color(0xFFB3B3B3);
  
  /// 反色文字（用于深色背景）
  static const Color textInverse = Color(0xFFFFFFFF);
  
  // ========== 边框色 ==========
  /// 主边框
  static const Color border = Color(0xFFE6E6E6);
  
  /// 深边框
  static const Color borderStrong = Color(0xFFD1D1D1);
  
  /// 浅边框
  static const Color borderLight = Color(0xFFF0F0F0);
  
  /// 聚焦边框
  static const Color borderFocus = Color(0xFF1A1A1A);
  
  // ========== 阴影色 ==========
  /// 轻阴影
  static Color shadowLight = Colors.black.withOpacity(0.04);
  
  /// 中阴影
  static Color shadowMedium = Colors.black.withOpacity(0.08);
  
  /// 重阴影
  static Color shadowHeavy = Colors.black.withOpacity(0.12);
  
  // ========== 状态色 ==========
  /// 已完成/已服用
  static const Color taken = Color(0xFF22C55E);
  
  /// 漏服
  static const Color missed = Color(0xFFEF4444);
  
  /// 待处理/未服用
  static const Color pending = Color(0xFFF59E0B);
  
  /// 进行中
  static const Color inProgress = Color(0xFF3B82F6);
  
  // ========== 渐变预设 ==========
  /// 卡片渐变 - 微妙的高级感
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFFAFAFA),
    ],
  );
  
  /// 主按钮渐变
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF000000),
    ],
  );
  
  /// 完成状态渐变
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF22C55E),
      Color(0xFF16A34A),
    ],
  );
}

/// ============================================================
/// 文字样式 - 精致的字体层级
/// ============================================================

class AppTextStyles {
  // ========== 展示型 ==========
  /// 超大标题 - 用于主要标题
  static const TextStyle displayLarge = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.1,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );
  
  // ========== 标题型 ==========
  /// 页面大标题
  static const TextStyle largeTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.2,
  );
  
  static const TextStyle title1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );
  
  static const TextStyle title2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static const TextStyle title3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static const TextStyle headline = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
    height: 1.4,
  );
  
  // ========== 正文型 ==========
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
    height: 1.5,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static const TextStyle callout = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle subhead = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle footnote = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0,
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0.1,
    height: 1.3,
  );
  
  static const TextStyle caption2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0.1,
    height: 1.3,
  );
  
  // ========== 特殊样式 ==========
  /// 标签文字
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.2,
  );
  
  /// 按钮文字
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.2,
    height: 1.25,
  );
  
  /// 大按钮文字
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    letterSpacing: 0.2,
    height: 1.25,
  );
  
  /// 数字/统计文字
  static const TextStyle statistic = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.1,
  );
}

/// ============================================================
/// 间距系统
/// ============================================================

class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;
  static const double section = 48;
}

/// ============================================================
/// 圆角系统
/// ============================================================

class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double round = 100;
}

/// ============================================================
/// 阴影系统 - 精致的层次感
/// ============================================================

class AppShadows {
  /// 极轻阴影 - 用于卡片默认状态
  static BoxShadow get extraLight => BoxShadow(
    color: Colors.black.withOpacity(0.03),
    blurRadius: 8,
    offset: const Offset(0, 2),
    spreadRadius: 0,
  );
  
  /// 轻阴影
  static BoxShadow get light => BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 12,
    offset: const Offset(0, 4),
    spreadRadius: 0,
  );
  
  /// 中阴影 - 用于悬浮卡片
  static BoxShadow get medium => BoxShadow(
    color: Colors.black.withOpacity(0.06),
    blurRadius: 16,
    offset: const Offset(0, 6),
    spreadRadius: -2,
  );
  
  /// 重阴影 - 用于模态框
  static BoxShadow get heavy => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 24,
    offset: const Offset(0, 8),
    spreadRadius: -4,
  );
  
  /// 按钮阴影
  static BoxShadow get button => BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 12,
    offset: const Offset(0, 4),
    spreadRadius: -2,
  );
  
  /// 内阴影 - 用于输入框
  static List<BoxShadow> get inner => [
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
      spreadRadius: -1,
    ),
  ];
  
  /// 卡片阴影组合
  static List<BoxShadow> get card => [
    extraLight,
  ];
  
  /// 悬浮卡片阴影组合
  static List<BoxShadow> get cardHover => [
    medium,
  ];
}

/// ============================================================
/// 边框样式
/// ============================================================

class AppBorders {
  /// 轻边框
  static BorderSide get light => const BorderSide(
    color: AppColors.border,
    width: 1,
  );
  
  /// 强边框
  static BorderSide get strong => const BorderSide(
    color: AppColors.borderStrong,
    width: 1,
  );
  
  /// 深边框
  static BorderSide get dark => const BorderSide(
    color: AppColors.gray300,
    width: 1,
  );
  
  /// 圆角矩形边框
  static BoxBorder get rounded => Border.all(
    color: AppColors.border,
    width: 1,
  );
  
  /// 底部分隔线
  static Border get bottomDivider => Border(
    bottom: light,
  );
  
  /// 全边框容器
  static BoxDecoration get outlined => BoxDecoration(
    border: rounded,
    borderRadius: BorderRadius.circular(AppRadius.lg),
  );
}
